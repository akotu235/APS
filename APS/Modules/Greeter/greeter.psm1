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
            Write-Host "    _     ___   ___ `n   /_\   | _ \ / __|`n  / _ \  |  _/ \__ \`n /_/ \_\ |_|   |___/v.$((Import-Clixml "$PSScriptRoot\..\..\PSGetModuleInfo.xml").Version)`n"
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUH3pym6j2zTWWa5+nMyV13H+/
# z0ygggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBRwl2GOr+PQZ03bFvnfUfgCjOD2ZTANBgkqhkiG9w0BAQEFAASCAgBBzywQ
# zjJfFiFGuAOwOd/PetG6Ywv2s4rZgFWaufaiRtz4JIGQhgx5rLekEpVLmCYZ+YfI
# gH6cQVT5zx/Vl7Ye6unDozMvYDjceLCPNh9ABkj6PFJ8ElS7RgHzUHerl5oiFeqg
# /arcctOxDtHPQR4dU8hoHr6ehaE/wJ95cQoXCJksZG26rVdTwPRFqCv2t3dGic7i
# wqN2+zjBNd/1atwoch1MX3eKKrQWwzaZh8yXg3LSiHOPnBrMU+FQ83xab46K9SFF
# Tk3nun0hWZ5e9BvyAMCKOeliVY9p8Nkn+J0LNWbD6ySwYtvwYmhdLLqEYPexIm4H
# mckewlkpmAmhom8av8zqASok9ijIhFwNdsKUQr7kHu7NEHPgq1ESZ/XHU0Xx6+es
# go+21X+2+UNq2FwqQT6vSONjWamGGPAjIGD1f28oew0/tHXWxoR9c21GcI2zA+gC
# lDs5TF/RZVk0nCnxMra2CjeHbKEIptNAqiWXVSg7LeX6ZSSKLBfjqv2wkw8//EG0
# HTOeql8qqcJ0zbebPD8ChL7KswK6569CZookRpHHsts2rCEOqs7p/f52U1Q2Y/pu
# V8p7MyL+3iNVr2teDt8NxNmqFuQ1aQYXe04NSr+PKBnUW4wWCuhoW63nDG0I+66o
# rupm2W6Azkheoz+4mGzPc6HeAjLludUeQScQ0A==
# SIG # End signature block
