<#
.SYNOPSIS
Updates APS.
.DESCRIPTION
Downloads and installs the latest APS from the github repository.
.EXAMPLE
Update-APS
#>
function Update-APS{
    $APS_Base = (Get-Module APS).ModuleBase
    $APS_Version = (Get-Content "$APS_Base\aps.psd1" | Select-String "ModuleVersion =")
    $Client = New-Object System.Net.WebClient
    $Client.DownloadFile("https://raw.githubusercontent.com/akotu235/APS/master/aps.psd1","$APS_Base\current")
    $APS_Current_Version = (Get-Content "$APS_Base\current" | Select-String "ModuleVersion =")
    rm -Force "$APS_Base\current"
    if($APS_Version -notlike $APS_Current_Version){
        Import-Module ScriptsSigner
        $Client.DownloadFile("https://github.com/akotu235/APS/archive/refs/heads/master.zip","$APS_Base\APS-master.zip")
        Expand-Archive -Path "$APS_Base/APS-master.zip" -DestinationPath $APS_Base
        cp -Force "$APS_Base\APS-master\aps.ps*" $APS_Base
        cp -Recurse -Force "$APS_Base\APS-master\Modules" $APS_Base
        rm -Force -Recurse "$APS_Base\APS-master*"
        Add-Signature $APS_Base
    }
    else{
        Write-Host "APS is up to date"
    }    
}


# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUai/xZ6AjA8XaTjaoRqRHKZ1S
# 0kSgggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
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
# CQQxFgQUraiDCi/lON5Q835ZlekbUU5He+QwDQYJKoZIhvcNAQEBBQAEggEAm1kN
# J0yMOzSppgCw9vsbeotBi75zSMQkmM5djQmPXErrZ3l9gAeHMRYS0+ZQ1zTDTyYu
# Ea2XhGPwggAWJzs9Bqymv7ZYJlyv0Nzy6v747/05+8ahw7H55hEdVGwe6K72iyq+
# Rz33UewLC5JzTMv3DhA8guWqu1Mkp4X0a4q+xqI/bXOyULZBD38K1i2GB0YlgSA3
# Ubtf8zDNeTutnzEi6bmf4bIrvFZsemkYIjiJ1qpKBy4pDpGfeIMBVnTQkEqXEQ07
# 1Tqg/d14l3m+5a940cQ8QQ2e09wlpPdVIBqW6Jgydq+DBz3iv3xKiQO56eee4hek
# LRv1lMH8DcCEESNANg==
# SIG # End signature block
