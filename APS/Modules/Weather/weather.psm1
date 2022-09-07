<#
.SYNOPSIS
Shows the weather.
.DESCRIPTION
Gets current weather data from openweathermap.org.
.PARAMETER City
Enter the city name.
.PARAMETER Units
Display data in given units (standard, metric or imperial).
.PARAMETER Detailed
Show more details.
.PARAMETER Data
Returns a weather object.
.PARAMETER Geolocalization
If enabled, it automatically detects city from ip address.
.PARAMETER RestoreDefaultSettings
Restores default settings.
.PARAMETER SetDefaultUnits
Sets the default units.
.PARAMETER SetDefaultCity
Sets the default city.
.PARAMETER SetAppId
Setup AppId.
.EXAMPLE
pogoda Tarnobrzeg
.EXAMPLE
Get-Weather Krakow -Detailed -Units standard
#>
function Get-Weather{
    [OutputType([String])]
    [CmdletBinding()]
    param(
        [string]$City,
        [switch]$Detailed,
        [switch]$Data,
        [ValidateSet(“standard”,”metric”,”imperial”)]
        [string]$Units,
        [switch]$RestoreDefaultConfig,
        [string]$SetDefaultCity,
        [string]$SetAppId,
        [ValidateSet(“standard”,”metric”,”imperial”)]
        [string]$SetDefaultUnits  ,
        [ValidateSet(“enable”,”disable”)]
        [string]$Geolocalization
    )
    if($RestoreDefaultConfig){
        Remove-Config $PSScriptRoot
    }else{
        Write-Verbose "Loading configuration."
        $Config = Get-Config $PSScriptRoot
    }
    if(!$Config){
        Write-Verbose "Generating default configuration."
        $Config = New-Object PSObject -Property @{
            AppId = Read-Host -Prompt "Enter API key from api.openweathermap.org"
            City = "$(Get-Geolocation -City)"
            Units = "metric"
            Geolocalization = "enable"
        }
        Save-Config $PSScriptRoot $Config
    }
    if($SetDefaultCity){
        Write-Verbose "Setting default city."
        Set-ConfigField $PSScriptRoot "City" $SetDefaultCity
        $City = $SetDefaultCity
    }
    if($SetAppId){
      Write-Verbose "Changing AppId."
      Set-ConfigField $PSScriptRoot "AppId" $SetAppId
      $AppId = $SetAppId
    }
    if($SetDefaultUnits){
        Write-Verbose "Setting default units."
        Set-ConfigField $PSScriptRoot "Units" $SetDefaultUnits
        $Units = $SetDefaultUnits
    }
    if($Geolocalization -like "enable"){
        Write-Verbose "Enabling geolocalization."
        Set-ConfigField $PSScriptRoot "Geolocalization" "enable"
    }elseif($Geolocalization -like "disable"){
        Write-Verbose "Disabling Geolocalization."
        Set-ConfigField $PSScriptRoot "Geolocalization" "disable"
    }
    if(!$City){
        if($Config.Geolocalization -like "enable"){
            Write-Verbose "Determining the location."
            if(!($City = (Get-Geolocation -City))){
                Write-Verbose "Loading City name from config."
                $City=$Config.City
            }
        }
        else{
            Write-Verbose "Loading City name from config."
            $City=$Config.City
        }
    }
    if(!$Units){
        Write-Verbose "Loading Units from configuration."
        $Units=$Config.Units
    }
    if(!$AppId){
        Write-Verbose "Loading AppId from configuration."
        $AppId=$Config.AppId
    }
    $uri="api.openweathermap.org/data/2.5/weather?q=$City&appid=$AppId&units=$Units"
    try{
        $Response = Invoke-WebRequest -Uri $uri -UseBasicParsing
    }catch{
        $Response =  @{}
        $Response.Add('StatusDescription', "Cannot retrieve data.")
        $Response.Add('StatusCode', "0")
    }
    if($Response.StatusCode -like "200"){
        $WeatherData = $Response.Content | ConvertFrom-Json
        if($detailed){
            Write-Verbose "Creating an object with weather data."
            [pscustomobject]$WeatherObj = [ordered] @{
                City="$($WeatherData.name), $($WeatherData.sys.country)";
                Coords="$($WeatherData.coord.lat), $($WeatherData.coord.lon)";
                Description="$($WeatherData.weather.description)";
                Temperature="$($WeatherData.main.temp) $(Get-UnitSymbol $Units "T")";
                "Feels like"="$($WeatherData.main.feels_like) $(Get-UnitSymbol $Units "T")";
                Min="$($WeatherData.main.temp_min) $(Get-UnitSymbol $Units "T")";
                Max="$($WeatherData.main.temp_max) $(Get-UnitSymbol $Units "T")";
                Humidity="$($WeatherData.main.humidity) %";
                Pressure="$($WeatherData.main.pressure) hPa";
                "Cloud cover"="$($WeatherData.clouds.all) %";
                Wind="$($WeatherData.wind.speed) $(Get-UnitSymbol $Units "V")";
                Direction="$($WeatherData.wind.deg) °";
                Visibility="$($WeatherData.visibility) m";
            }
            return $WeatherObj
        }
        elseif($Data){
            return $WeatherData
        }
        else{
            [int]$t=$WeatherData.main.temp
            return "$($WeatherData.name) $t $(Get-UnitSymbol $Units "T")"
        }
    }
    else{
        Write-Warning $Response.StatusDescription
    }
}

function Get-UnitSymbol{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet(“standard”,”metric”,”imperial”)]
        [string]$Units,
        [Parameter(Mandatory=$true)]
        [ValidateSet(“T”,”V”)]
        [string]$Size
    )
    if($Size -like "T"){
        if($Units -like "metric"){
            return "°C"
        }
        elseif($Units -like ”imperial”){
            return "°F"
        }
        elseif($Units -like ”standard”){
            return "K"
        }
    }
    elseif($Size -like "V"){
        if($Units -like ”imperial”){
            return "mph"
        }
        else{
            return "m/s"
        }
    }
}
Set-Alias "pogoda" Get-Weather