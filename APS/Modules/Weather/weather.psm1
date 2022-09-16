<#
.SYNOPSIS
Shows the current weather.
.DESCRIPTION
Gets current weather data from openweathermap.org.
.PARAMETER City
Defines for which city the weather data is to be displayed.
.PARAMETER Detailed
Shows detailed data.
.PARAMETER Data
Returns the original object taken from openweathermap.org.
.PARAMETER Units
Determines the units of displayed results. Valid values are standard, metric and imperial.
.PARAMETER RestoreDefaultSettings
Restores default settings.
.PARAMETER SetDefaultCity
Specifies the default city.
.PARAMETER SetUnits
Specifies the default units.
.PARAMETER Geolocalization
Defines the settings for retrieving location data based on the network. Valid values are enable and disable.
.PARAMETER SetAppId
Specifies the AppId.
.EXAMPLE
pogoda Tarnobrzeg
.EXAMPLE
Get-Weather Krakow -Detailed -Units standard
#>
function Get-Weather{
    [OutputType([System.String])]
    [CmdletBinding(DefaultParameterSetName = 'NoParameter')]
    param(
        [Parameter(ParameterSetName='Default', Position=0)]
        [Parameter(ParameterSetName='Detailed', Position=0)]
        [Parameter(ParameterSetName='Data', Position=0)]
        [System.String]$City,
        [Parameter(ParameterSetName='Detailed')]
        [switch]$Detailed,
        [Parameter(ParameterSetName='Data')]
        [switch]$Data,
        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='Detailed')]
        [Parameter(ParameterSetName='Data')]
        [ValidateSet('standard','metric','imperial')]
        [System.String]$Units,
        [Parameter(ParameterSetName='DefaultSettings')]
        [switch]$RestoreDefaultConfig,
        [Parameter(ParameterSetName='Settings')]
        [System.String]$SetDefaultCity,
        [Parameter(ParameterSetName='Settings')]
        [ValidateSet('standard','metric','imperial')]
        [System.String]$SetUnits,
        [Parameter(ParameterSetName='Settings')]
        [ValidateSet('enable','disable')]
        [System.String]$Geolocalization,
        [Parameter(ParameterSetName='Settings')]
        [System.String]$SetAppId
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
    if($SetUnits){
        Write-Verbose "Setting default units."
        Set-ConfigField $PSScriptRoot "Units" $SetUnits
        $Units = $SetUnits
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
        [System.String]$Units,
        [Parameter(Mandatory=$true)]
        [ValidateSet(“T”,”V”)]
        [System.String]$Size
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