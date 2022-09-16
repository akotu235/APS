<#
.SYNOPSIS
Run as administrator.
.DESCRIPTION
Opens a new powershell session as administrator and executes the script block specified in the parameter.
.PARAMETER ScriptBlock
Specifies the commands to run as administrator. Enclose the commands in braces (``{ }``) to create a script block.
.PARAMETER NoExit
Does not exit after running commands.
.EXAMPLE
Confirm-Admin -ScriptBlock {Start-Service sshd}
#>
function Confirm-Admin{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [System.String]$ScriptBlock,
        [switch]$NoExit = $true
    )
    #Script block prepare
    $Module = Convert-Path "$PSScriptRoot\..\..\aps.psm1"
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
                    cd `'$PWD`'
                    $(if($PSCommandPath){'Set-Variable PSCommandPath -Value $PSCommandPath'})
                    $ScriptBlock
                }"
    if((Test-Admin) -eq $false){
        Start-Process powershell.exe -Verb RunAs -ArgumentList ("-noprofile $(if($NoExit){"-noexit "})-command " + $Command)
    }
    else{
        try{
            & $ScriptBlock
        }
        catch{
            Start-Process powershell.exe -Verb RunAs -ArgumentList ("-noprofile $(if($NoExit){"-noexit "})-command " + $Command)
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
Installs and configures OpenSSH.
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
Secures SSH.
.DESCRIPTION
Configures pubkey authentication.
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
            Move-Item -Force C:\ProgramData\ssh\sshd_config C:\ProgramData\ssh\sshd_config.bak
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
        [System.String]$Name = ""
    )
    return "$PSScriptRoot\$Name"
}

<#
.SYNOPSIS
Creates a new code signing certificate.
.DESCRIPTION
Creates and secures a script signing certificate and places it in the appropriate certificate store.
.EXAMPLE
New-CodeSigningCert
#>
function New-CodeSigningCert{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [System.String]$Name = "PowerShell Local CA"
    )
    while(Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert | Where-Object Subject -Like "CN=$Name"){
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
    $ConfirmedPassword = (Read-Host -AsSecureString -Prompt "Confirm the certificate password")
    $CertPasswordAsPlainText = [System.Net.NetworkCredential]::new("", $CertPassword).Password
    $ConfirmedPasswordAsPlainText = [System.Net.NetworkCredential]::new("", $ConfirmedPassword).Password
    while($CertPasswordAsPlainText -notlike $ConfirmedPasswordAsPlainText){
        Write-Warning "Passwords are not the same"
        $CertPassword = (Read-Host -AsSecureString -Prompt "Create a certificate password")
        $ConfirmedPassword = (Read-Host -AsSecureString -Prompt "Confirm the certificate password")
        $CertPasswordAsPlainText = [System.Net.NetworkCredential]::new("", $CertPassword).Password
        $ConfirmedPasswordAsPlainText = [System.Net.NetworkCredential]::new("", $ConfirmedPassword).Password
    }
    Export-PfxCertificate -Cert $Cert -FilePath $CertPath -Password $CertPassword
    &$CertPath
    #cleaning after completion
    Write-Warning "After completing the wizard, press enter to continue.."
    Read-Host >> $null
    Remove-Item -Force $exported
    Remove-Item -Force $CertPath
    Write-Output "Done."
}
Set-Alias -Name "sudo" -Value Confirm-Admin