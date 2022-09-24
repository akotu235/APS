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
    [CmdletBinding(DefaultParameterSetName = 'Temperature')]
    param(
        [Parameter(ParameterSetName='Temperature', Position=0)]
        [Parameter(ParameterSetName='Detailed', Position=0)]
        [Parameter(ParameterSetName='Data', Position=0)]
        [System.String]$City,
        [Parameter(ParameterSetName='Detailed')]
        [switch]$Detailed,
        [Parameter(ParameterSetName='Data')]
        [switch]$Data,
        [Parameter(ParameterSetName='Temperature')]
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
                Direction="$($WeatherData.wind.deg) $([char]176)";
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
        [ValidateSet("standard","metric","imperial")]
        [System.String]$Units,
        [Parameter(Mandatory=$true)]
        [ValidateSet("T","V")]
        [System.String]$Size
    )
    if($Size -like "T"){
        if($Units -like "metric"){
            return "$([char]176)C"
        }
        elseif($Units -like "imperial"){
            return "$([char]176)F"
        }
        elseif($Units -like "standard"){
            return "K"
        }
    }
    elseif($Size -like "V"){
        if($Units -like "imperial"){
            return "mph"
        }
        else{
            return "m/s"
        }
    }
}
Set-Alias "pogoda" Get-Weather

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUR9dk2EdR1VAN7E3rQ4B07AJ1
# Fw2gggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
# AQsFADATMREwDwYDVQQDDAhha290dSBDQTAeFw0yMjA5MjAxOTQ4MDFaFw0zMjA5
# MjAxOTU4MDFaMBMxETAPBgNVBAMMCGFrb3R1IENBMIICIjANBgkqhkiG9w0BAQEF
# AAOCAg8AMIICCgKCAgEAvGcae/FCZugTbghxO7Qv9wQKvRvp9/WvJyJci/SIsPr1
# /Mf5wfBTJ3aCvyjFvHfcsDH4NdHZubHO531tc1NHCDh+Ztkr5hbOdl3x46nEXm6u
# e4Fiw23SB02dU3dAnFvNSGEE5jhQDOApGX/u7xEW4ZXrvMC5yLCBa3Kva1abPx5b
# owvQlHhiSsn039/K2xSNhR+x4QcgEIo9JYdcob0f7ZY3AhXT+f1PNyYe075SY+t2
# y1YMlPlq4THolVUB4yB5MknAOG7IoxFt0U9vXhMSjbb06LZ/I/2RpAJd/qcaC/aX
# CBvKYQbbmEqMqKutic/Q23cQU2jcuRxyy+Y5QphALwdkQGIuvOOIQCak/ZKa6k5S
# 5U3zcMSbGOFF1BHdLSmcUnicsuvMM4uOT0zF/yzuSv5fSo3t6W5VHa+1Ct8ygt3/
# Byq2dLPskUPn0khR3/PaC8Px0k6TpcL1auKeb/uObvckBH/NVvQebtFuXMFXCayw
# ZFQx2dGfqb20Q5ZDNw5u8PtrSAeTaqZ7shrcsHbi59ztASvNjapdnhosQ26ir5bD
# Urzn7Fm/R/tZ9wpCuZ6i2LErckKGMW0Lk1ku0HJv83q/rr0vkrbEXUWx6eaaXwQj
# IacKX8IvED/HN1gQ9WfkvLmQurF9ZUfJQDC/WNrIwYw4advSARKs/4WE+HmN1g0C
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSUHb/MW3YJQEoACPnV20ZgngOGCDANBgkqhkiG9w0BAQsFAAOCAgEA
# C6pw+UgUjitD9crDEpEPIcmC/Eiif7DnMI2xG1aS8drSFkTvJdmG1yI4gUigjncb
# LfDSLbUIwAUfaM6V1zPb/ec0dg0Nkn+Za1fpuIXxuPKtvrqr9FLfc70D3AphNrDD
# rFEd3c1ykLed7lllMYaLXkfWDRlxhhpP+LR9qbgvTxFbWk/7yA7kJrwEaDgfqqME
# QEE9xZDEIN/f1ycTnh0qmUwYoHDEKbOet/OgiILjzqIjplnaaKJIzFjmfDDK8JY+
# 0tl3hnyFHkPVe9sKTIEVhjc8XlaaCDDTEPTiWvB3TPMLZCqcwqQ4WdcWpS0Dp1Ms
# XvRVv8NkcDMPzFpgqFpkkrkqt94IESUycaAQe+czlurf/KiQjzAjVvhZFspqbBi8
# 83AZ9+mBQhtQqgzcZYSF2LAPbfTXCPw8daT/hOrUaU72YrA4ON64ZRYvcaj9u1AN
# +pxo8TY+YNak+tVByU3sfLfFwbJMJi63be1yo1yLc3b/d3DrJz3AIY82LrtdQcT3
# tj3QnyvVHpFvtzKZxO5hSgaTksmRBYJZ6cYcBgW69l8UpppiyAtzKo4AvD1XXlc6
# ehYjdBVms5F9spAWjwzXg9lWQSsul7V6WB7/PIaTF4hsZ9IylRl4FnBwcJbTdjXi
# E8oA77fIHMj6jOyxEeP6WGzjDYxBnLKyV/lVqk7WkqkxggLIMIICxAIBATAnMBMx
# ETAPBgNVBAMMCGFrb3R1IENBAhBhg/J9QEELqkT+sB86yVc7MAkGBSsOAwIaBQCg
# eDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEE
# AYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJ
# BDEWBBRJ9EijfwlLCBMEsJ9LTxYAf9Xt2TANBgkqhkiG9w0BAQEFAASCAgCRqq0v
# tGfzii9GoMost08vipwjbDzNwXDZzV377VIVZUvwGy/9gyJludkj89LhdcwBwjIV
# uUi+hs2ND6GI82NIhidZ3nlgDR1Y8Bp+yI0UAtVcSFnehD+x3XrV1OzxR58JDy/p
# W07eJABkwtpXc8EwHdBcZic28BGa2wsTX4vuoXhnlKhqesOqnyn2hjYnVes44t3V
# 3SHkW+WB5afsTpQ4mGhdVOl3d1O4LFn0IEviAqNPvl8UhjNlxR35bxkGkU/2W4rU
# 8qz8rW2nBorHSyUxbb6bed2hNAN7ntDQWiQVArkJy2TUSsFlQ1WNsApEC7TQYeWY
# T/mWYewwXWl+ym1Fu/cPFjGygPo0SgvtaDVYCDgqPIqqANu5RFhyk4n2d3KgRKmS
# dyPfDtiT6O1QinAt2XS3aobdQjiA92rV5L9ceHLSSUlAopliDaOxT782jSSv/M/T
# 3h7ZYBEoB5CGQNFa1j8nyXsq/Cbj4Q0voZtgp6mq8VLDmcOd74Qdwt+Y8/TeYPwo
# KsG4WiWsdg9rDdZelmF2CePXsg4q90UIkbiFeMriek/SUD69XHhyaT3u+XMXsQ0S
# sM/x0TXkPvX0wVOFbQ5zMA+ZtOuCjXD9ik+8p79uCwVR+8Y1yE/pc5tOKnXYkENd
# f4MbPsoC04a0POaaGhD6Q+caiK7ACLxGwOncPg==
# SIG # End signature block
