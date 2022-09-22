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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1J0dunVXTIqQ5w+9SDSs68uE
# ABKgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBRvI6qRNbzVR9v8knNxXvb+SjqcnDANBgkqhkiG9w0BAQEFAASCAgCAsjzb
# nwt1bU+8TdoAaBxrCVTCsfpwuVkXS1FsHdWEPzdAY8sXK+pqVU15IMCdIEqR8LZt
# J7iBYRWVRyJwArm/wFyBC4Fr5PKCn49S8iwQDnLZBkPqgdJVbIiNrcp/nt2of1rS
# S60eU+2SFF4j4Onh+dUnVidkEwTP0kmzVMmPmZ31WkhkrNh+MrDyzJPbY+8yAwAR
# 6S/mcreNY98mbMeoxXg0xmvkClCgfbASjgSUJgVSH3iApxn0rFtK7gUUMpxmvHoq
# cD+rdEN8XFgV6KgUYBqc1/kucHH1YPyJDmr9nQxPCS7jD1lWyszEcgxUk/Q45R8+
# X0aLt9gR8tRW3lZ741XWnn5YR1EgOl/dMfs1qwbk7AXhFTkWHo/pAfaZ1YoV83pB
# 0l56Qg3+C35aovU1oB7zVo16vHDLTGmEnezjX29uI19ZsLod4NoKfklyozPJ2S42
# WYjLEe5yffiGP7ltNzdMlN3GEHFnrz6kUXdcx6C0sYZAgKKBvYiOQWpgQJIjXLni
# SPYjn2uJdNXHUpAwP12CYJSyD1SXaXkpmwUK8Ipo2WJvH1CGmqZdENSHO3GiH/Mr
# scgrux72O5urBA2tht563TTq0QyBGqQufSFZyz7QuLML33r2kYLir1IbjKRXfmNr
# jckoSMsDgVn7tXKB5UXRkK0AWzG0/aIC9zY5OQ==
# SIG # End signature block
