<#
.SYNOPSIS
Updates APS.
.DESCRIPTION
Downloads and installs the latest APS from the PowerShell Gallery.
.PARAMETER Force
Forces the command to run without asking for user confirmation.
.PARAMETER KeepPreviousVersion
Determines whether to keep the previous version. By default, it is removed.
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
    $currentVersionNumber = Get-APSCurrentVersion
    $moduleBase = "$($APS_Module.ModuleBase)\..\$($currentVersionNumber.ToString())"
    if(($APS_Module.Version) -lt $currentVersionNumber -or $Force){
        Update-Module APS -Force:$Force -Confirm:$false
        if(-not $KeepPreviousVersion){
            Get-ChildItem "$moduleBase\.." | ForEach-Object {
                if(($currentVersionNumber.ToString()) -notlike $_){
                    Remove-Item ($_.FullName) -Recurse -Force
                }
            }
        }
        Get-ChildItem -Path $moduleBase -Recurse | Where-Object -Property Extension -Match ".psm?1" | ForEach-Object {
            $content = Get-Content -Path $_.FullName
            $content | ForEach-Object {$_.replace('`n','`r`n')}
            Set-Content -Path $_.FullName -Value $content
        }
        Remove-Module -Name APS -Force -ErrorAction SilentlyContinue
        (Get-ChildItem "$moduleBase\Modules").Name | ForEach-Object {Remove-Module -Name $_ -Force -ErrorAction SilentlyContinue }
        Import-Module APS
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoDnASzBLLFHE8njABSTY7yrq
# VZagggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBTlblez05KcnG/waNP9141DHkX/FDANBgkqhkiG9w0BAQEFAASCAgBlTPd8
# N+55IH3iX2/WzbQHLDwTGdFiVW336I2kAAf1E5/p0EYDMckIR+HP74dk/qZ+gr2J
# PxCfaJaEzIUMVso4ooZZdH2aRBQb/9vL94JHGjy7pqt6ghVlHZOdg29hgpTOfsJS
# 9g6MkHm6v4xjvo4261BnMdZqPnotWJQCRpici6DTM/DPyMCwfULHOjoLnv3w9SAo
# MP2Sm91z5AJ/vQq+LRN3Jzu31fgiHxObdWQqc1Lojm2SmNejEp0zjgnEuzFdVoJZ
# mOQp2xYuUyxEBZ+i0LicDBHJFjrxA3bMhL4wiRab5ZyTaredQQV4t0lHxq5PH2Fg
# 71UW1qlyig6a61A6C2cMObGzYN0rkbYYbSlt1X023jiHZn91g/F66pNZ4RLuBzwP
# tqe6Hek1NpRpINmsupmxR8vbBe/IA5qR81hOdx8bV3DeZwxZqiKD2BSMbIe+IU8H
# Mrnflc55x6ua8lr2R6ZGCqcr1WDWAtGfgNzc50XLQhc5rDdH8ZkjU7/XYLFT+8wW
# KszsgGNEkQMW2sb0UFURUiDswSC4VaWhcoxtTJT3ym9nO/gLYfWFdaUeRc6CaaY5
# uYcidnMFoQDFZh0s6GtNnoZAY4e1XZl3Cu93HexOQYpCwHVEm6Ewr431EiTzDgYR
# 6QH0xjZ+6KL7BWqkHBLAnC4LNmnftBPbRX8tOw==
# SIG # End signature block
