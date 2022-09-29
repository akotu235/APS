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
    [CmdletBinding(SupportsShouldProcess, HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/APSUpdater/Update-APS.md")]
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVFxqr27hSfa+O+sXyGR/vw+m
# 3GSgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBRWrsZIFoDjWcZo2l8Rok8lDSzCMjANBgkqhkiG9w0BAQEFAASCAgAOkulg
# zCOJ1VhBHbaWGobDR9otmqxfabFKKjjOAI9iN26OpHv4rjRGHNgnX9fy465DARde
# M6EstKS8WBmm1WM+4n72dzZFEn+CQ9n3fzY9SfKb6FXrnIwbgfvSQJJ0YDW2yvLT
# Hk79nIxLKDZibLKeLCfpVG4mSsEhMk1BioE5OlKt7FFHWsIES5B/mDyAhB7saZfM
# +jksJjGn0nawWBOYMss3KFP/ODHA0XJwYKNAU4GRS91oIOsin0+ssKYvklqLqKKu
# 86huodEco0tNfcAAwFkbuR5hV19ohxd1ZRHebqQOcPmrnPQCA/heX9lgMTN8S3ha
# +YAriZecILa3wMO4ZI4UQVzWCUt9+rBTq5LZLjbvXBYm0N9j2ZohHjPVYFNo0Fmw
# i7o9Du927YcnwWq5ULNVM0vvTxCH54/yDK1LJDA8QsPHRa7IztR5SwN6XJeOMREY
# kW6DLacmu5pXe43iRhEsz6m1PY6j2WDalucU/JonjmpBoD3aEdDIkuYlZAJZkfRI
# DS0Uf+O0aKVQzZCFEps5Ajlkk7q5kGBenQxHBmqYDVl2u6KVNFE8Zu7kQ5q0SL49
# XGE4vz4+BwRT70UL9sRcb/qiMIgn8/x0HaHAmieUUXhWDbKlRJDsTOmZ7Lh2/inF
# wXPaouGcVKxgURmGyCS1U6yrXl0uwhbbf1Kf9g==
# SIG # End signature block
