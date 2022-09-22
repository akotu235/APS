param(
    [switch]$Installed,
    [switch]$UpdateSignatures
)
$PSModulePath = $Env:PSModulePath
Set-ExecutionPolicy AllSigned -Scope Process -Force -Confirm:$false
if([boolean](Get-Module APS)){
    $modules = 'APS '
    $modules += (Get-ChildItem "$((Get-Module APS).ModuleBase)\Modules").Name
    $modules = $modules.Split()
    $modules | ForEach-Object {
        Get-Module $_ | Remove-Module
    }
}
if(-not $installed){
    $APSBase = Convert-Path "$PSScriptRoot\.."
    $modulesPath = "$APSBase\APS\Modules"
    $Env:PSModulePath = "$APSBase;$modulesPath"
}
else{
    $modulesPath = ($Env:PSModulePath.Split(';') | ForEach-Object {if($_ -like "*\APS\*"){$_}}) -join ";"
    $APSBase = $modulesPath.TrimEnd('\Modules')
}
$modules = 'APS '
$modules += (Get-ChildItem $modulesPath).Name
$modules = $modules.Split()
$modules | ForEach-Object {
    Get-Module $_ | Remove-Module
    try{Import-Module $_ -ErrorAction SilentlyContinue}catch{}
    if([boolean](Get-Module $_)){
        Write-Host "$_ " -ForegroundColor Green
        Get-Module $_ | Remove-Module
    }
    else{
        if($UpdateSignatures){
            Add-Signature -File "$APSBase\APS$(if($_ -like "APS"){"\aps.psm1"}else{"\Modules\$_"})" >> $null
            try{Import-Module $_ -ErrorAction SilentlyContinue}catch{}
            if([boolean](Get-Module $_)){
                Write-Host "$_ " -ForegroundColor Cyan
                Get-Module $_ | Remove-Module
            }
            else{
                Write-Host "$_ " -ForegroundColor Magenta
            }
        }
        else{
            Write-Host "$_ " -ForegroundColor Red
        }
    }
}
$Env:PSModulePath = $PSModulePath


# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUL8tnhbQ7val7mJk17c07kT8w
# AI6gggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBT95HbjO+7PhB9aZXmOZsSXqiDDPDANBgkqhkiG9w0BAQEFAASCAgBkMw0G
# NJfUIec45pvZTjYN4cGxjppbtaSgEY+QAP1z9IWLhDteZSkkH6lLw7vyyqRleklx
# HkfFag333sP/pp1+2IxNINRkGOAhAhwQWacDDg43ApgApB1piiLaVsO2tQWoi4pU
# NU7RFqafglA06DhSEreukQOvnFdui0K/VmnO7NpmB2XtBYD5n0QW55lWg0FPwvom
# qo7Jhpg7Zwyu08gPW5xh5qEYrR0DdkU3E4m1mG5eM62S+fUQAFvL4Fkp57LhSqk8
# eu6P8j71pFEBKNdX/d640UW52agQC7TnnTrA1l83hEGgx05meTc6pmL5gWcC1TW5
# o7K+jaTjAipfbkUqg4/ZF4+ykXGKf3IywqoxXPBi7YpZPAITSKlAWspsDGkxUqv4
# okv2T4kjUx3m5/HK9bdBMyGXbGhHYWAittmpA88WLwKKffyOO38nhs/SuesqnTuX
# zFMl//XkjjPgCCQExwRymYi2hC405e5rM85n+npdewoQwK1kgcoQ/CQCZKrE5oeZ
# vQ2IKR5n3TIPtSnp6INRzpuCfm2YF+l7hBP3F69I11lcKEUl8obkq4btqHbQ3rHo
# 1z7au6DAyVM5pWhM03FiWLHWh4/OPzRxx79qCzlmPjN4IA/92knI2TXIIinTudBl
# Psb7jb2m+m+jBHItdW61Y7mAiuuJ9uTf4aT6sw==
# SIG # End signature block
