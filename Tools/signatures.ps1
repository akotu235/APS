Param(
    [switch]$UpdateSignatures,
    [switch]$Installed
)
Set-ExecutionPolicy AllSigned -Scope Process -Force -Confirm:$false
if(-not $installed){
    $APSBase = Convert-Path "$PSScriptRoot\..\APS"
    $modulesPath = "$APSBase\Modules"
    $APSBase
    $modulesPath
}
else{
    $APSBase = (Get-Module APS).ModuleBase
    $modulesPath = "$APSBase\Modules"
}
$modules = "$((Get-Item $APSBase).FullName);"
$modules += (Get-ChildItem $modulesPath).FullName -join ";"
$modules = $modules.Split(';')
$modules | ForEach-Object {
    if($_.Split("\")[-1] -notmatch "\d+\.\d+\.\d+"){
        $moduleName = $_.Split("\")[-1]
    }
    else{
        $moduleName = $_.Split("\")[-2]
    }
    $invalidFiles = @()
    $authenticodeSignature = Get-ChildItem $_ | Where-Object Extension -Match ".psm?1" | Get-AuthenticodeSignature
    $authenticodeSignature | ForEach-Object {
        if($_.Status -notlike "Valid"){
            $invalidFiles += $_.Path
        }
    }
    if(-not [boolean]$invalidFiles.Count){
        Write-Host $moduleName -ForegroundColor Green
    }
    else{
        if($UpdateSignatures){
            $signingErrors = @()
            $invalidFiles | ForEach-Object {Add-Signature -File $_ >> $null}
            $invalidFiles | Get-AuthenticodeSignature | ForEach-Object {
                if($_.Status -notlike "Valid"){
                    $signingErrors += $_.Path
                }
            }
            if([boolean]$signingErrors){
                Write-Host $moduleName -ForegroundColor Magenta
                $signingErrors | ForEach-Object {
                    Write-Host " -$($_.Split('\')[-1])" -ForegroundColor DarkMagenta
                }
            }
            else{
                Write-Host $moduleName -ForegroundColor Cyan
            }
        }
        else{
            Write-Host $moduleName -ForegroundColor Red
            $invalidFiles | ForEach-Object {
                    Write-Host " -$($_.Split('\')[-1])" -ForegroundColor DarkRed
                }
        }
    }
}

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUaLByxRGGPjRJhWtWY9esm4f0
# NvWgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBQcUJUO/6SflYDtgQzbsnI8LG/w7jANBgkqhkiG9w0BAQEFAASCAgBknX7x
# xl6tRXKEVHAzEDOCRronOJArSv2J+pc4EhjYUMwTFZVpD6oThbVOaDgy43iv8Hfc
# vYQM3smYF04vG9ShZ3Iwxl1POnEjMwFEbajzKZ/M1TS59hb0LDLXf+fG16DsCGso
# KN6ChkBCTh4QHUQZB2aeWKnCD4A8BHZJx2d1SgumHpipNwBMjJjUgPyJMegzHJWj
# ZAfq8ygyc6VebllScsove+/gTtgC3EWyWSej3v/RcP/i+IhutElsQn9YwdCfujzR
# +NM+2lgMPImy667CfefePaBXH+le010izFjvh//FLghdiiWVFBpwVK4u7Xr2yrcA
# jcX67XaML03aGLzBZmRLIrQ1SlxxwOMRujE44yOkrDWlRbxEbdFMVJy1YMC3ywyk
# 9QX+GDTXffjxhjX3FyigoaQws34LdTGlAs3XVr2yUKN1NDnk8nxx1oCSq/hrHmjv
# dNaMBuwOwZtfcx/ytiNd2+vYShE6THtlfgktuRMlwDJ4CZZ7rxZ96B7xsE17F+vO
# 6F1Ob7VQ0XWA+uIGlQFmD/zhVRaablCb5/CYXY1YYrsChhTyGJz5NRFkYkLzAfCA
# JPDHWv0D8xu5YGdcDGtOcCNUUCh9rl/QdNX5CkMn4BH5aHBdnYzMFqSm7OSYahFZ
# yiNY0xiYu1f8Au5vMwqCfp1ewnbNlx7sf5N1FA==
# SIG # End signature block
