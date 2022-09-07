<#
.SYNOPSIS
Shows the locations based on the network.
.DESCRIPTION
Gets data from ip-api.com.
.PARAMETER City
Returns the city of your location.
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