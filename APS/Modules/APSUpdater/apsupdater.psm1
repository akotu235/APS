<#
.SYNOPSIS
Updates APS.
.DESCRIPTION
Downloads and installs the latest APS from the PowerShell Gallery.
.PARAMETER Force
Forces the command to run without asking for user confirmation.
.EXAMPLE
Update-APS
#>
function Update-APS{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$Force,
        [switch]$KeepPreviousVersion
    )
    $APS_Module = Get-Module APS
    if(($APS_Module.Version) -lt (Get-APSCurrentVersion) -or $Force){
        Import-Module ScriptsSigner
        $APS_Base = $APS_Module.ModuleBase | Split-Path
        Update-Module APS -Force:$Force -Confirm:$false
        if(-not $KeepPreviousVersion){
            Uninstall-Module APS -Force -RequiredVersion $APS_Module.Version -Confirm:$false -ErrorAction SilentlyContinue
        }
        Add-Signature $APS_Base >> $null
    }
    else{
        Write-Host "APS is up to date" -ForegroundColor DarkGreen
    }
}

<#
.SYNOPSIS
Gets the latest APS version number from the PowerShell Gallery.
#>
function Get-APSCurrentVersion{
    $url = "https://www.powershellgallery.com/packages/APS/?dummy=$(Get-Random)"
    $request = [System.Net.WebRequest]::Create($url)
    $request.AllowAutoRedirect=$false
    try{
        $response = $request.GetResponse()
        $version = $response.GetResponseHeader("Location").Split("/")[-1] -as [Version]
        $response.Close()
        $response.Dispose()
        return $version
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}
# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+q4JVHY77/g2CB8scDMgr7NJ
# VG6gggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBRzWzM03bz7sgJoKeKhhuhbjQBEKDANBgkqhkiG9w0BAQEFAASCAgAcwBeA
# VnIYBrb+mTIfSLBJn+1XQwEaHADS6iz9ZTjRZtCOxCpQ5X8BbuDojCruA5z6ftJn
# W0tWalXTKM8ub0M4BVORaj7zGBJGOoOsoUN1cVOkKPGHQKak/SCwO0Bie4Q0v4d5
# NVJ+CCl9PsEz604nEYg0BflcQXn31plwI0HQpbdN+7Zy3zQGmz3NmTCj0HaMmvHT
# NeSoFwmnOK4/dtXIaDoHjgPp3y0UVnwHxTAEl98dW3ymrTmYGMqL2W6baaNn3J6s
# p1et19wUvBIe5eUyuF+gxkCKDDfHt8bINuzvQd0jdUAlD/KiqOPz7/9QfHq3PReH
# Z0e1jNLTZV7d+XpyqWzDIFFsZz6cwT2qitngb6mA3gqOn2yjZfMH44+ZGpLjR3AA
# 4CQvohdiKVRIt6f1N9kapUC0ydUSGVYy/LeG/LqfPLNzxk1Od+fZNJyyyGvde2/F
# zlh3DcPVGv6kocdVaVG6yzasqinvtNKvrlroQcsSogYpJVkG8OMDifmE0Sw7hT9V
# UzGYGEDqOJPA+qrfdh0eJiZjKIZRrg2XWzr0boCQFxHfGnsC9lne4YQgyBNpHIZP
# hkukG92now2fi/Q31fSpCtY99YOoB+29xJG5eJH/Luw6aObjYWgI8Iy7FdEr+Wuq
# Trwm2rBFJjHyhFzJEaucAl7Y80TTjoeJG4Mksw==
# SIG # End signature block
