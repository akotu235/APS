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
        [System.String]$ScriptBlock,
        [switch]$NoExit = $true
    )
    $Module = Convert-Path "$PSScriptRoot\..\.."
    $Command="& {
                    try{
                        Import-Module $Module
                    }
                    catch{
                        try{
                            Set-ExecutionPolicy Bypass -Scope Process -Force
                            Import-Module $Module
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
        Get-Service ssh-agent | Set-Service -StartupType Automatic
        Start-Service ssh-agent
        if(Test-Path C:\ProgramData\ssh\sshd_config){
            Move-Item -Force C:\ProgramData\ssh\sshd_config C:\ProgramData\ssh\sshd_config.bak
        }
        Get-Content "$PSScriptRoot\sshd_config" | Set-Content C:\ProgramData\ssh\sshd_config
        exit
    }
    Get-Content ~\.ssh\id_ed25519.pub | Set-Content ~\.ssh\authorized_keys
    ssh-add "$HOME\.ssh\id_ed25519"
    Invoke-Item $HOME"\.ssh"
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
        KeyLength = 4096
        KeyAlgorithm = "RSA"
        FriendlyName = "Code signing"
        NotAfter = (Get-Date).AddYears(10)
        CertStoreLocation = 'Cert:\CurrentUser\My'
        HashAlgorithm = 'sha256'
    }
    $cert = New-SelfSignedCertificate @Params
    if(-not (Test-Path "$Home\.certs\")){
        New-Item -ItemType Directory -Path "$Home\.certs" >> $null
    }
    $certsPath = ("$Home\.certs" | Resolve-Path).Path
    $pubCertPath = "`'$certsPath\$Name.cer`'"
    Export-Certificate -Cert $cert -FilePath "$certsPath\$Name.cer" >> $null
    $pubCertPath = "`'$certsPath\$Name.cer`'"
    $command = "if(Import-Certificate -FilePath $pubCertPath -CertStoreLocation Cert:\LocalMachine\Root){exit}"
    Confirm-Admin -NoExit $command
    $certPath = "$certsPath\$Name.pfx"
    $certPassword = Read-Password -Prompt "Create a certificate password"
    Export-PfxCertificate -Cert $cert -FilePath $certPath -Password $certPassword >> $null
    &$certPath
}
function Read-Password{
    [CmdletBinding()]
    param(
        [System.String]$Prompt = "Create a password",
        [ValidateRange(0,32)]
        [int]$MinimumLength = 0,
        [switch]$UppercaseAndLowercaseRequired,
        [switch]$NumberRequired,
        [switch]$SpecialCharacterRequired
    )
    while(-not $passwordAccepted){
        $password = (Read-Host -AsSecureString -Prompt $Prompt)
        $confirm = (Read-Host -AsSecureString -Prompt "Confirm the password")
        $passwordAsPlainText = [System.Net.NetworkCredential]::new("", $password).Password
        $confirmAsPlainText = [System.Net.NetworkCredential]::new("", $confirm).Password
        $passwordAccepted = Test-Password -Password $passwordAsPlainText -MinimumLength $MinimumLength -UppercaseAndLowercaseRequired:$UppercaseAndLowercaseRequired -NumberRequired:$NumberRequired -SpecialCharacterRequired:$SpecialCharacterRequired
        if($passwordAsPlainText -notlike $confirmAsPlainText){
            Write-Warning "passwords must be the same"
            $passwordAccepted = $false
        }
    }
    return $password
}
function Test-Password{
    [CmdletBinding()]
    param(
        [System.String]$Password,
        [ValidateRange(0,32)]
        [int]$MinimumLength = 0,
        [switch]$UppercaseAndLowercaseRequired,
        [switch]$NumberRequired,
        [switch]$SpecialCharacterRequired
    )
    [boolean]$isCorrect = $true
    if($Password.Length -lt $MinimumLength){
        Write-Warning "minimum password length: $MinimumLength"
        $isCorrect = $false
    }
    if($UppercaseAndLowercaseRequired){
        if($Password -cnotmatch "[a-z]" -or $Password -cnotmatch "[A-Z]"){
            Write-Warning "uppercase and lowercase required"
            $isCorrect = $false
        }
    }
    if($NumberRequired){
        if($Password -cnotmatch "[0-9]"){
            Write-Warning "number required"
            $isCorrect = $false
        }
    }
    if($SpecialCharacterRequired){
        $sch = $Password -replace "[a-z1-9]"
        if(-not $sch){
            Write-Warning "special character required"
            $isCorrect = $false
        }
    }
    return $isCorrect
}
Set-Alias -Name "sudo" -Value Confirm-Admin