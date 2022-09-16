<#
.SYNOPSIS
Shows location information based on the network.
.DESCRIPTION
If given without parameters, the ``Get-Geolocation`` cmdlet will return all data retrieved from ip-api.com such as: country, region, city, zip code, co-ordinates, timezone, isp name and ip addres
.PARAMETER City
Returns the city name of your location.
.EXAMPLE
Get-Geolocation
.EXAMPLE
Get-Geolocation -City
#>
function Get-Geolocation{
    [CmdletBinding()]
    param(
        [switch]$City
    )
    try{
        $Response = Invoke-WebRequest -Uri http://ip-api.com/json/ -DisableKeepAlive -UseBasicParsing
    }
    catch{
        $Response =  @{}
        $Response.Add('StatusDescription', "Cannot retrieve data.")
        $Response.Add('StatusCode', "0")
    }
    if($Response.StatusCode -like "200"){
        $GeolocationData = $Response.Content | ConvertFrom-Json
        if($City){
            return $GeolocationData.city
        }
        else{
            return $GeolocationData
        }
    }
    else{
        return $null
    }
}