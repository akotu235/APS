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

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUxl3xo9t8gSIuuG24f9Dr/3Sn
# ytCgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBTWRNPC4HjVEm8ah4eVE986iiHS1TANBgkqhkiG9w0BAQEFAASCAgBZdUa+
# zyBQ7Rj/KteHRnbjfW8VoOEEtmtmkwBPMTJsenupmHf1KlMwcdebLutGc3a5mqOp
# sHrt6lwwsKwGVGTc3cekbi/nopqzLBOBolTVa7EZ80uOh8fZoCGOm6kwaYg2HXgN
# B84p2iOan9QRUz9CI75IRhNWdSEd4156JLIDnGtw4fAMNvs5kyGjijDuTYWb3bI+
# 5RnDe/LFqfBXQL/rk+0m1SCUXORNH8OQHpakEnv+HCaGyh7yanAGaEtCjQj+WyQV
# cFcU7Spz9EeEhsi0kydk8vRCpV8NrORMNdOKgkkmpPCMkux1MN6ukZ7wVsxW0XKA
# rqIYpyL49he6eMangR7YYtEuxeSwXt/0yOiR0H9bBZiPYe/QYP8pHew09JZhGO0W
# /deG0jV42y+i+/kE/aTs8XwvLYHxKleUKdozsvtC3f2t0GU85ZhIodJqiYzEW6n6
# p+mPh59hZhXwWvDg7IA82SnVHDQjwD/sObPnCB3GsRuzFO6qbkQcXpQFtvQgcW3o
# X/sJIwLoG+WQs/ERen15pMFK/DjggpRhdcBB+Na7B2cvT7TnrFLv65kSxowdTZda
# jViK4O76jl3TOcrs1zwwQQNOE7+IWVdvLYRzc8nMAJ2xJoFJ9/+2ki84gPfaBGyr
# R2dU7eXESmZkexF7tXEfOIKzEwFRG1zRJZRGfA==
# SIG # End signature block
