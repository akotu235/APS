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
    [CmdletBinding(HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/Geolocalization/Get-Geolocation.md")]
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

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUG4SzJdnK3aSYKMc0BuLkhYSi
# WCigggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBQ1XnKTeT9iSc/IGEmkVpK53zokUzANBgkqhkiG9w0BAQEFAASCAgAEKVkN
# H/FOcvpW7FtSxXQAPpVOz9Z2t0jrU9mvFkal9uWf8HiuARqmK9ezNt7oAuKhvk+E
# mPgESadnr+9nEiYqKbSwA2iStsKoCZVUeT25omXxpDHUCbniMZEtWxTt67bi9UWi
# saLpjbE1FnYmMay83khF/NeDTk6iQYqrpWW/QZknx02uJj0R8DGAsfeYmVkmkBQF
# TGNkSfyYxZyG024Z1XQI7eD/qbf+3oIEYG+bgD45ygIZiXdomppK+MJNkA5ifwJ3
# a3F8RVa80tp+9DBlzIz0qQCgD+iYqgEqK0RwvVlhFcvK1mpWQUbhsVkiiombep78
# 360qfwQV7xrks6Gl+VVQUoyYRjOM6GJ4DPKO4zgxgTdErEdzajx/VHEHlKZV2zIb
# zLlGO+nDM3qAJPQPAEqZTZ8rGaSPQJRYfsSVw+nEz20b/eeH5S4YG4myAdSXE4MM
# eVnorfa/dIpofgyYaMsuEmih27LNuVjDuUO+eu45k/Uyqtnh5cT7U6KnpWU+LVE+
# 1Vcq8p75ZFsGVwIfmMvk0I77ZBZKM86qKE/AkmHGsCq3K8MbzR5MUQKAFssm/AmJ
# 9jY3LhKNW54PLw/SPooOq+FomqP9wsmxwHKJrazH86uCouvk4TgoKXzs8VK9yqNJ
# dlokbQ+9zFrpHz+4pCtDE891qjrcoABowydyXw==
# SIG # End signature block
