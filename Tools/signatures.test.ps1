param(
    [switch]$Installed
)
$PSModulePath = $Env:PSModulePath
Set-ExecutionPolicy AllSigned -Scope Process -Force -Confirm:$false
if(-not $installed){
    Import-Module APS
    $APSBase = (Get-Module APS).ModuleBase
    $Env:PSModulePath = ($Env:PSModulePath.Split(';') | ForEach-Object {if($_ -notlike "$APSBase*"){$_}}) -join ";"
    $APSProjectBase = Convert-Path "$PSScriptRoot\..\APS"
    $Env:PSModulePath = "$Env:PSModulePath;$APSProjectBase;$APSProjectBase\Modules"
}
Get-Module APS | Remove-Module
Import-Module APS
$moduleBase = (Get-Module APS).ModuleBase
$modules = 'APS '
$modules += (Get-ChildItem "$moduleBase\Modules").Name
$modules = $modules.Split()
$modules | ForEach-Object {
    Get-Module $_ | Remove-Module
    try{
        Import-Module $_ -ErrorAction SilentlyContinue
    }
    catch{}
    if([boolean](Get-Module $_)){
        Write-Host "$_ " -ForegroundColor Green
        Get-Module $_ | Remove-Module
    }
    else{
        Write-Host "$_ " -ForegroundColor Red
    }
}
$Env:PSModulePath = $PSModulePath

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdZAF3bIPpHUcSf615rPs7jIo
# YG+gggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBT7865cxyjSIU3cPHu6v+AQXPVWuzANBgkqhkiG9w0BAQEFAASCAgBoLnYw
# qh5FB23azNkYGRYSDDaJ8o4Q+T3hjMEEnoy37EsJP+0oDCnoo/AMX5mnDVotMC6g
# jLgqGNz2oF9+Y2Xm4pNtC+Rc2Mc4dopFWbNFlktJCHKTL/Aj+PVQQBCAe9BW8c9/
# ieBTSMqpsbDI64P/CHqkv7Kr0ulY4KdM7X8zCNv4zpS1ulQmrjt709eWcUbHoD+H
# dr3Kdx4KVHAO0r6Tj6SSJryBlZVntMHpOMIaUMtdY92EJPXRkZyyby0ihJmhS+Pi
# EF8za25QlemzW8SKqFGAqbmKnD+wThGcsULCFkHU6ym6Z5uvOsVwcA9jwe6Exl+d
# qJy+gwMiG4vN7Nb1DQoZi3G80xCCR22hoLTo2vB1Y9Dbv4J6d3wHYPjaM8rw17GN
# qM+FpNsulgEmge4m0B4NZAUjKw5TGt/x4pZhfX7HDDAp7M/2z4uUg1kk916WZs1g
# reTgQQ+h+ur36EuoFYyKvjG3fUxzvtd6PhxBdxIhP4D1m7dFiSJMUrXd/ZwPZ2C3
# IOStVMu5AoRE3IQxHEJljp210elT0CVtvY7p5i+k0k+TuaL/+PufVl8LEqKUouVJ
# zUyNP1iMXP5/+PkjNkNxVOqYySIs1Op53crO+PSkI+prsp+XWGmUc6ByuwTjhdUj
# MPk3TXnjBn7+uPgvWPvIDN08osebvJ+LI4+yng==
# SIG # End signature block
