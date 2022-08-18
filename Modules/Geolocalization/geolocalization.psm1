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
# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7xnZwWDSxixPryLeM2PCl3KJ
# Es+gggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
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
# CQQxFgQUfwQp8GbszQjKoK6NSZ97cqJdAokwDQYJKoZIhvcNAQEBBQAEggEAXwGs
# KIr8YyEbnDj19+utrfonl2azAzRx58qv8Z8ANq70C++KmGX5zlfKHyBj58J9YuMS
# jnMKhE8Tw7e/ejn5jT7rbsNpkEUK2EhFNzDhWyjdhnHCXsfkkaBpxHwT9syGdGFF
# dRgKa3lPgBgazR3ltWN7e4AcmHng3eC0yHpegnYshNaBm02EXnULQsEQMVN8xYq+
# H84tueAdqSggizLBdje/3i0dxoMfMOXv3tDS7VJrsu5v3bb4kcQjufkt5lATa6Rp
# vdAguAwcik1z8fjmdAMgiFvgrbSt8BGfk0f3YG7gCzZlkC5e212i/C3+kuhGHu2+
# ZrKvz+q+j9+mTSV4gw==
# SIG # End signature block
