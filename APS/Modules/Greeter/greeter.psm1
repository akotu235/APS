<#
.SYNOPSIS
Displays greeting information.
.DESCRIPTION
Displays information selected in a configuration file.
.EXAMPLE
Show-APSGreeting
#>
function Show-APSGreeting{
    [CmdletBinding(HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/Greeter/Show-APSGreeting.md")]
    param()
    if(-not ($Config = Get-Config $PSScriptRoot)){
        $Config = Set-APSGreeting -Default
    }
    if($Config.EnableAPSGreeting){
        if($Config.Clear){
            Clear-Host
        }
        if($Config.APSLogo){
            try{
                $version = (Import-Clixml "$PSScriptRoot\..\..\PSGetModuleInfo.xml").Version
            }
            catch{
                $version = (Get-Content "$PSScriptRoot\..\..\APS.psd1" | Select-String "ModuleVersion = ").ToString().Trim().TrimStart("ModuleVersion = ").Trim("'")
            }
            Write-Host "    _     ___   ___ `n   /_\   | _ \ / __|`n  / _ \  |  _/ \__ \`n /_/ \_\ |_|   |___/" -NoNewline
            if($version){
                Write-Host "v.$version" -ForegroundColor DarkGray
            }
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
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName="NoParameter", HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/Greeter/Set-APSGreeting.md")]
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlsfYKQLURH2b2MN7BjkOi3Xz
# srigggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBS7WBnkZ7nDW0e1CPs/AxvBJ13w+zANBgkqhkiG9w0BAQEFAASCAgAHMu9y
# ZGcS5oF5iqBz6mxLx+aiIeJYGHGHSnLne6CvuROzfXZpyaOW/DsvNlCZD8uoabRJ
# 4eevniYHztAjUfiXVASkxcG9+J287RnDqMi/M9jmZir/hpOYhSlFI+2dTZZa1/Bq
# j2QDfVBi/bMyLk4tX+XI+/3bJ8o1e7zHMMnWoO2IjEo+9cw0B8WMVjOc/XobmlTW
# tLVOsHway9TzU+d5RmQBQOzQW3zye4CMBLeY0PnBveKkQoYDaoAkvv7/G5UKdBYX
# ztbBVw0m3kX6HDFwCVzwvnC/3EUbz30U1fJYA3JoBOS5eV/9QLEF173hxWAs6qp+
# 64VAqdSebQ72j8cT4F9iMEDj/5DCTYU+BZrJS/eFhJ6TxDLkLMWqor8XAode4/Y3
# DGIINZ7pVeErpTIpmsirFj6fKNdaRCOoj/qbv99pvcr0+Zxi4/AAHL/W4dX5RSin
# UGBi0SLDBpZpnay3gub0XfHl1jI2fo4QKYTFV1Qjhv1X62GbxSBqbLy+Hr1UimQh
# 3OP7lXkCiBKx+kJyWtvFe63yXig569ZSMiz4RODob7AMF2isCLAKodx+VRFxyGDB
# ZvfOAovV+F0L1B8Yu8WJ+ufx0ZQ6t5VeDMfKOD7kCBXT5z0iVMD1ebOQ/Ix1Itby
# 7acEXR17rnjw4UKfoT67Zw2SHSpS0tsiDLsZuQ==
# SIG # End signature block
