<#
.SYNOPSIS
Run as administrator.
.DESCRIPTION
Opens a new powershell session as administrator and executes the script block specified in the parameter.
.PARAMETER ScriptBlock
Enter the script block to run as administrator.
.PARAMETER CommandPath
Sets the variable $PSCommandPath which Contains the full path and file name of the script that invoked the current command. The value of this property is populated only when the caller is a script.
.PARAMETER NoExit
If set, do not close powershell window after task execution.
.EXAMPLE
Confirm-Admin -ScriptBlock {Start-Service sshd}
#>
function Confirm-Admin{
    [CmdletBinding()] 
    param(
        [Parameter(Mandatory=$true)]
        [string]$ScriptBlock,
        [string]$CommandPath,
        [switch]$NoExit = $true
    )
    
    #Script block prepare
    $Module = Convert-Path "$PSScriptRoot\..\..\aps.psm1"
    if($CommandPath){
        $Command="& {
                        try{
                            Import-Module -Name $Module
                        }
                        catch{
                            try{
                                Set-ExecutionPolicy Bypass -Scope Process -Force
                                Import-Module -Name $Module
                            }
                            catch{
                                Write-Error 'Cannot find the APS module'
                            }
                        }
                        cd $PWD
                        Set-Variable PSCommandPath -Value $CommandPath
                        $ScriptBlock
                   }"
    }
    else{
        $Command="& {
                        try{
                            Import-Module -Name $Module
                        }
                        catch{
                            try{
                                Set-ExecutionPolicy Bypass -Scope Process -Force
                                Import-Module -Name $Module
                            }
                            catch{
                                Write-Error 'Cannot find the APS module'
                            }
                        }
                        cd $PWD
                        $ScriptBlock
                   }"
    }
    
    if((Test-Admin) -eq $false){
        if($NoExit){
            Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -command ' + $Command)
        }
        else{
            Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -command ' + $Command)
        }
    }
    else{
        try{
            & $ScriptBlock
        }
        catch{
            if($NoExit){
                Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -command ' + $Command)
            }
            else{
                Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -command ' + $Command)
            }
        }
    }
}

<#
.SYNOPSIS
Checks if the user is an administrator.
.DESCRIPTION
If the current user is an administrator it returns true else returns false.
.EXAMPLE
Test-Admin
#>
function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

<#
.SYNOPSIS
Installs and configures OpenSSH
.DESCRIPTION
Installs OpenSSH.Client.
Installs OpenSSH.Server.
Starts the service.
Set service automatic startup type.
Configures firewall.
.EXAMPLE
sudo Install-SSH
#>
function Install-SSH {
    $obj=Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
    if($obj.State -like "Installed"){
        Write-Output "$($obj.Name) already installed."
    }
    else {
        Add-WindowsCapability -Online -Name $obj.Name
        Write-Output "$($obj.Name) installed."
    }
    $obj=Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
    if($obj.State -like "Installed"){
        Write-Output "$($obj.Name) already installed."
    }
    else{
        Add-WindowsCapability -Online -Name $obj.Name
        Write-Output "$($obj.Name) installed."
    }
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
    #Confirm the Firewall rule is configured.
    if(!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
        Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    }
    else {
        Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
    }
}

<#
.SYNOPSIS
Secures SSH
.DESCRIPTION

.EXAMPLE
Protect-SSH
#>
function Protect-SSH{
    ssh-keygen -t ed25519
    Confirm-Admin -NoExit {
        #Allow ssh-agent to be automatic started.
        Get-Service ssh-agent | Set-Service -StartupType Automatic
        # Start the service
        Start-Service ssh-agent
        if(Test-Path C:\ProgramData\ssh\sshd_config){
            mv -Force C:\ProgramData\ssh\sshd_config C:\ProgramData\ssh\sshd_config.bak
        }
        #configuration settings 
        Get-Content (Get-AutoConfigurationPath "sshd_config") | Set-Content C:\ProgramData\ssh\sshd_config
        exit
    }
    Get-Content ~\.ssh\id_ed25519.pub | Set-Content ~\.ssh\authorized_keys
    #Load key file into ssh-agent
    ssh-add "$HOME\.ssh\id_ed25519"
    Invoke-Item $HOME"\.ssh" 
}

function Get-AutoConfigurationPath{ 
    param(
        [string]$Name = ""
    )
    return (Get-Module AutoConfiguration).ModuleBase+"\"+$name
}

<#
.SYNOPSIS
Creates a new code signing certificate.
.DESCRIPTION

.EXAMPLE
New-CodeSigningCert
#>
function New-CodeSigningCert{
    [CmdletBinding()] 
    param(
        [string]$Name = "PowerShell Local CA"
    )
    while(Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert | where Subject -Like "CN=$Name"){
        $Name = Read-Host -Prompt "A certificate with this name already exists, please enter a different name"
    }
    $Params = @{
        Subject = "CN="+$Name
        Type = "CodeSigningCert" 
        KeySpec = "Signature" 
        KeyUsage = "DigitalSignature"
        FriendlyName = "Code signing"
        NotAfter = (Get-Date).AddYears(5)
        CertStoreLocation = 'Cert:\CurrentUser\My'
        HashAlgorithm = 'sha256'
    }
    $Cert = New-SelfSignedCertificate @Params

    #Add to trusted certification root 
    $exported = Get-AutoConfigurationPath "exported_cert.cer"
    Export-Certificate -Cert $Cert -FilePath $exported
    Confirm-Admin -NoExit {
        $exported = Get-AutoConfigurationPath "exported_cert.cer"
        if(Import-Certificate -FilePath $exported -CertStoreLocation Cert:\LocalMachine\Root){
            exit
        }
    }
   
    #Securing a personal certificate
    $CertPath = Get-AutoConfigurationPath "$Name.pfx"
    $CertPassword = (Read-Host -AsSecureString -Prompt "Create a certificate password")
    Export-PfxCertificate -Cert $Cert -FilePath $CertPath -Password $CertPassword 
    &$CertPath

    #cleaning after completion
    Write-Warning "After completing the wizard, press enter to continue.." 
    Read-Host >> $null
    rm -Force $exported
    rm -Force $CertPath
    Write-Output "Done."
}

Set-Alias -Name "sudo" -Value Confirm-Admin
# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJ6NflC2ak84mOWZ5EhqzgjaV
# PTugggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
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
# CQQxFgQUyeuKSFtJEu1HKlCm3NQr6kvwTc0wDQYJKoZIhvcNAQEBBQAEggEAcdMJ
# MDk9WBbNxUH4iZKpDJ0BEVzokTbgNUbLCV7Y13h67YcOwyvccZ0N3+ag58Xftfrm
# 4ApXwPHyBxPQI68atGkk8grQwXPCH0ueon+jm5LMhhiOPGaGH+raLn4E+PZk0AGQ
# FzSvqOVcTOtrOYcClyZ17TODjst04mJXIy0luEwf5JmMQqXiTxQT6ULwFMiTcQ94
# 0CQtYjrRhRZa+gpY0e9r9HPMnxwYCHjIKps69nD7wIMpXuaCn00GfxdWybNecc68
# 8adOirL506g0Lzju8AqY5UR2tL0JqJaYDEUutO1d+onezYT6H//lU9keevryG/Sh
# mbRdPsn/Ckdifv9wgw==
# SIG # End signature block
