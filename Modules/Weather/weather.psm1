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
            AppId = "e734800c9dc90fda039ba3d4ce67422a"
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
        [string]$Size=”T”
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
# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+n1PA7hzsg0Uq6ri/TswFxf2
# 0EOgggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
# AQsFADAeMRwwGgYDVQQDDBNQb3dlclNoZWxsIGFrb3R1IENBMB4XDTIyMDIwMTEz
# MDExMloXDTI3MDIwMTEzMTExM1owHjEcMBoGA1UEAwwTUG93ZXJTaGVsbCBha290
# dSBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ5Jah2xqCyY33yT
# xhz7JjIQofP86RYwn5arpiQfKz87xvKTzOcVm9Pf3jrpKkcUnGL7PKqGDAX6HL5r
# GQ7/2RPlnH7cSYIM9vYYmR7vgUUgQACsYVOO5UcrlDT9ga387gd7YInmSn/icot3
# b2gvCf1Ok3OT05d8Vu4PzzYXNRvc6pIgnQ++ENakvB6LLSoso3OuZZoFhHpufD0/
# 8ac21gw9ZeweFtQzy8BAkMbPCSSymiYduLPF4XEb1vo2w3fHDl/LYCfrJWOHTELS
# IjpRLJQYbJnewBZ1x6jXRB0dTbUrO3C5UPoKXYPMIMi5Slvk1XPDHeXLOXAb4ZTO
# EHV325kCAwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUF
# BwMDMB0GA1UdDgQWBBR1hk5NfI7NaI/MFxkS4z6wB5uaszANBgkqhkiG9w0BAQsF
# AAOCAQEABoUXCtmgDOiK6QjrzONCSE+7NbYrwzPonxGY0PNvmxf5Y6CcCK0Nga8v
# ImAZM9cXAGOUZE0wZQUODHW4OxbW1kgzS4OvOQZZUeSPNG7OLxttYkF5+5Pfs8RY
# AxkI0XYP3JId4Fx5E8ByMGx7wOpyVcLOCU+DEpEf21tHa4xQ5RGeKTcE7hRROLpg
# g50DeoiSAeAmAH2K2l2uCPb+fP+MeEFH9THGPYJbWozU9Zq90Az3HCEn2dkPXKof
# ZfBOJt3/WwSWGtYZqf0cAooTcKlO1TrreAmh4uuslfM7F579xKqX8ou1JzRQ2n/M
# WRajsdVGAXYebpyYbjiGjNKoGzWS8DGCAdMwggHPAgEBMDIwHjEcMBoGA1UEAwwT
# UG93ZXJTaGVsbCBha290dSBDQQIQfziWHbCKBoRNGa23h81cKTAJBgUrDgMCGgUA
# oHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0B
# CQQxFgQUTBZVmnV4sTs+K/ULPM1BZDr7m20wDQYJKoZIhvcNAQEBBQAEggEAivFT
# +plNWYzKu5VzXcI8+w+M3FnlctrMDUr8fjnpF1G3er7R8lDJOD4w/N30ORox7GXV
# UWy4CRTJLXEc56krG6l62ccHHQwx0d/J9SLKy8u2ehQaFKlh9dLBTzvFn1Y+3Uxc
# VDsoJq129PkkyBcRCV7IGyk1qeHFB0cViohFqK170wdrnG5dKNQNUnzK2kPyfufR
# Q4CSPtXjimt1jv6bo/f5Liu+BP7QxZQoiMtE7m/eoZzifUOJobsZC+Cd6TK3TYWb
# 2kqDzSSE9NRXbyGCrdRE3GxXmcefKruya4NbtOY7Y5lwDwpa09+jLXEDolTn6h0F
# 1cLqPpnz+G22vO2aug==
# SIG # End signature block
