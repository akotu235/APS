<#
.SYNOPSIS
Updates APS.
.DESCRIPTION
Downloads and installs the latest APS from the github repository.
.EXAMPLE
Update-APS
#>
function Update-APS{
    [CmdletBinding()] 
    param(
        [switch]$Force
    )
    $APS_Base = (Get-Module APS).ModuleBase
    $APS_Version = (Get-Content "$APS_Base\aps.psd1" | Select-String "ModuleVersion =")
    $Client = New-Object System.Net.WebClient
    $Client.DownloadFile("https://raw.githubusercontent.com/akotu235/APS/master/aps.psd1","$APS_Base\current")
    $APS_Current_Version = (Get-Content "$APS_Base\current" | Select-String "ModuleVersion =")
    rm -Force "$APS_Base\current"
    if($APS_Version -notlike $APS_Current_Version -or $Force){
        Import-Module ScriptsSigner
        $Client.DownloadFile("https://github.com/akotu235/APS/archive/refs/heads/master.zip","$APS_Base\APS-master.zip")
        Expand-Archive -Path "$APS_Base/APS-master.zip" -DestinationPath $APS_Base
        cp -Force "$APS_Base\APS-master\aps.ps*" $APS_Base
        cp -Recurse -Force "$APS_Base\APS-master\Modules" $APS_Base
        rm -Force -Recurse "$APS_Base\APS-master*"
        Add-Signature $APS_Base >> $null
    }
    else{
        Write-Host "APS is up to date" -ForegroundColor DarkGreen
    }    
}




# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUShY/QRwpdJL6Dk3qH0swnCsE
# H/qgggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
# AQsFADAeMRwwGgYDVQQDDBNQb3dlclNoZWxsIGFrb3R1IENBMB4XDTIyMDIwMTEz
# MDExMloXDTI3MDIwMTEzMTExM1owHjEcMBoGA1UEAwwTUG93ZXJTaGVsbCBha290
# dSBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ5Jah2xqCyY33yT
# xhz7JjIQofP86RYwn5arpiQfKz87xvKTzOcVm9Pf3jrpKkcUnGL7PKqGDAX6HL5r
# GQ7/2RPlnH7cSYIM9vYYmR7vgUUgQACsYVOO5UcrlDT9ga387gd7YInmSn/icot3
# b2gvCf1Ok3OT05d8Vu4PzzYXNRvc6pIgnQ++ENakvB6LLSoso3OuZZoFhHpufD0/
# 8ac21gw9ZeweFtQzy8BAkMbPCSSymiYduLPF4XEb1vo2w3fHDl/LYCfrJWOHTELS
# IjpRLJQYbJnewBZ1x6jXRB0dTbUrO3C5UPoKXYPMIMi5Slvk1XPDHeXLOXAb4ZTO
# EHV325kCAwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUF
# BwMDMB0GA1UdDgQWBBR1hk5NfI7NaI/MFxkS4z6wB5uaszANBgkqhkiG9w0BAQsF
# AAOCAQEABoUXCtmgDOiK6QjrzONCSE+7NbYrwzPonxGY0PNvmxf5Y6CcCK0Nga8v
# ImAZM9cXAGOUZE0wZQUODHW4OxbW1kgzS4OvOQZZUeSPNG7OLxttYkF5+5Pfs8RY
# AxkI0XYP3JId4Fx5E8ByMGx7wOpyVcLOCU+DEpEf21tHa4xQ5RGeKTcE7hRROLpg
# g50DeoiSAeAmAH2K2l2uCPb+fP+MeEFH9THGPYJbWozU9Zq90Az3HCEn2dkPXKof
# ZfBOJt3/WwSWGtYZqf0cAooTcKlO1TrreAmh4uuslfM7F579xKqX8ou1JzRQ2n/M
# WRajsdVGAXYebpyYbjiGjNKoGzWS8DGCAdMwggHPAgEBMDIwHjEcMBoGA1UEAwwT
# UG93ZXJTaGVsbCBha290dSBDQQIQfziWHbCKBoRNGa23h81cKTAJBgUrDgMCGgUA
# oHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0B
# CQQxFgQU6xf3x5OLCYmxT3bcV4gy704+B1YwDQYJKoZIhvcNAQEBBQAEggEAdqRH
# vIC84K2j5IUd8kx5i6LHageaxAqXDHVYGcvA5FAsrOUs9N4abgBbqYa6paK/4pr0
# 62HKtypOJpcfgIPCTTR4+UGLYyMb4TaqpbHmBCIZ+OG8IGZjGCLsj2fzHDOiBRUT
# ZqfblB9XQfbE6K2c5Kjor+mhDwD5ik4yMtSoZUdmwYAeeyT0jH4iLedQcWosKM6C
# 1bM+5esJ55hh0hr6mFT8rM6QLP7X1ra0K6vaggwLnjhsY7cZFUCEOOsn0OkICLNn
# 6yKr1IPrg289N1peTKCz1ugtxwSMkubqCPUpH/ki1yYmNXOQJABgLnCoqT4k1yzn
# KK+cj+WlHGzH7uXT7w==
# SIG # End signature block
