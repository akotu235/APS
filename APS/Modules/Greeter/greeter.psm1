<#
.SYNOPSIS
Displays greeting information.
.DESCRIPTION
Displays information selected in a configuration file.
.EXAMPLE
Show-APSGreeting
#>
function Show-APSGreeting{
    if(-not ($Config = Get-Config $PSScriptRoot)){
        $Config = Set-APSGreeting -Default
    }
    if($Config.EnableAPSGreeting){
        if($Config.Clear){
            Clear-Host
        }
        if($Config.APSLogo){
            try{$version = "v.$((Import-Clixml "$PSScriptRoot\..\..\PSGetModuleInfo.xml").Version)"}catch{}
            Write-Host "    _     ___   ___ `n   /_\   | _ \ / __|`n  / _ \  |  _/ \__ \`n /_/ \_\ |_|   |___/" -NoNewline
            Write-Host $version -ForegroundColor DarkGray
        }
        if($Config.Date){
            Write-Host "Hi! It is $(Get-Date -Format g)"
        }
        if($Config.Weather){
            Write-Host $(Get-Weather)
        }
        if($Config.UserName){
            Write-Host "You are working as " -NoNewline
            if(Test-Admin){
                Write-Host "$env:UserName" -ForegroundColor Red
            }
            else{
                Write-Host "$env:UserName"
            }
        }
        Write-Host ""
    }
}

<#
.SYNOPSIS
Saves in the configuration file which information is to be displayed using the ``Show-APSGreeting`` function.
.DESCRIPTION
The ``Set-APSGreeting`` cmdlet running without parameters will help the user select the items to display.
.PARAMETER Default
Restores the default settings.
.PARAMETER Disable
Disables ``Show-APSGreeting`` functions.
.EXAMPLE
Set-APSGreeting
#>
function Set-APSGreeting{
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName="NoParameter")]
    param(
        [Parameter(ParameterSetName='Default')]
        [switch]$Default,
        [Parameter(ParameterSetName='Disable')]
        [switch]$Disable
    )
    if($Default){
        $Config = New-Object PSObject -Property @{
            EnableAPSGreeting = $true
            Clear = $true
            APSLogo = $true
            Date = $true
            UserName = $true
            Weather = $true
        }
        return (Save-Config $PSScriptRoot $Config)
    }
    elseif($Disable){
        Set-ConfigField $PSScriptRoot "EnableAPSGreeting" $false
    }
    else{
        $clear = Read-Host "Do you want to clear the screen?(yes)"
        $logo = Read-Host "Do you want to see the APS logo?(yes)"
        $date = Read-Host "Do you want to see the date and time?(yes)"
        $username = Read-Host "Do you want to see the username?(yes)"
        $weather = Read-Host "Do you want to see the weather?(yes)"
        $Config = New-Object PSObject -Property @{
            EnableAPSGreeting = $true
            Clear = $($clear.ToLower() -notlike "n*")
            APSLogo = $($logo.ToLower() -notlike "n*")
            Date = $($date.ToLower() -notlike "n*")
            UserName = $($username.ToLower() -notlike "n*")
            Weather = $($weather.ToLower() -notlike "n*")
        }
        Save-Config $PSScriptRoot $Config
    }
}






# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUghBUtKkXpbP+dbOLMIdQ+0qT
# 1RegggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBRzid3g5qxWg66Pur/XPAIHvPre6zANBgkqhkiG9w0BAQEFAASCAgCq0mdp
# YHaDcu5gXQeyFMH1wNR0aXWMS+VpLY6Il1RBfi8igZVIOkXQfTqM91cioFRPh7OQ
# nfLzOgA+NfO/Osc2aJaZH02y8MtWb6T65EjSIYC5HxBw15MSZonNarnXvBfSZzVC
# tJjbtBdNwVGoD5f/Ndk3ng9ErN3b7YF94+Df5xe7czkrwSXgwoa7Z5p8W1wmQqYT
# UsRXeEVJl2qgRASXpZjqLbPU+9LjwLr2YcTpKSuV1DOw2hgP8+7esgmRGhQ1ncZT
# ZK6pfc+qZHjU2t75aXmRh0K+S2QTgC49MqUig/R2Qx/hPiCi1FfPqQ7d3uanRGfR
# 0X3+PTGr5SpdWawHaj/t01HGYC7i129S5YJKDAhhGo79yQ4HPQ9RuUq+Kq2P8OZy
# 1LMU1bYdDhAA8+R4FkO/CUSP4gsdWCB97tjWgJIfKKUwmyf4NVgnmmmSJXasYgRE
# Sq2ILomcZyr+XXWWupg0td9xnbRDkYcJSciibNlTDKmDtQHXvG1R2PGSfcYMP52T
# 3+GE7Ym/sTfimbehFKf4VpQS5Ky2dnYv1+gQVIztKMy88z9wnh8bS8wco3K38QKV
# suyj/IosIBSdGKNJCI2QoCMRxqqVYnAVL+B/7SXXXKWjydGh18sB9g/aMGi2yE9H
# ptMnJgjiJVM8TSwsjqOqsUq7Ipegavl82r46zA==
# SIG # End signature block
