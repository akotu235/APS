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
        [switch]$NoExit
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

<#
.SYNOPSIS
Reads the password from the user.
.DESCRIPTION
Reads a password of input from the console. Cmdlet displays asterisks (``*``) in place of the characters that the user types as input. The output of the ``Read-Password`` cmdlet is a SecureString object (System.Security.SecureString). The password is read until the password requirements are met.
.PARAMETER Prompt
Specifies the text of the prompt. Type a string. If the string includes spaces, enclose it in quotation marks. PowerShell appends a colon (``:``) to the text that you enter.
.PARAMETER MinimumLength
Specifies the minimum length of a password.
.PARAMETER UppercaseAndLowercaseRequired
Specifies whether uppercase or lowercase letters are required.
.PARAMETER NumberRequired
Specifies whether a digit is required.
.PARAMETER SpecialCharacterRequired
Specifies whether special characters are required.
.EXAMPLE
Read-Password -MinimumLength -UppercaseAndLowercaseRequired -NumberRequired -SpecialCharacterRequired
#>
function Read-Password{
    [OutputType([System.Security.SecureString])]
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
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param(
        [System.String]$Pass,
        [ValidateRange(0,32)]
        [int]$MinimumLength = 0,
        [switch]$UppercaseAndLowercaseRequired,
        [switch]$NumberRequired,
        [switch]$SpecialCharacterRequired
    )
    [boolean]$isCorrect = $true
    if($Pass.Length -lt $MinimumLength){
        Write-Warning "minimum password length: $MinimumLength"
        $isCorrect = $false
    }
    if($UppercaseAndLowercaseRequired){
        if($Pass -cnotmatch "[a-z]" -or $Pass -cnotmatch "[A-Z]"){
            Write-Warning "uppercase and lowercase required"
            $isCorrect = $false
        }
    }
    if($NumberRequired){
        if($Pass -cnotmatch "[0-9]"){
            Write-Warning "number required"
            $isCorrect = $false
        }
    }
    if($SpecialCharacterRequired){
        $sch = $Pass -replace "[a-z1-9]"
        if(-not $sch){
            Write-Warning "special character required"
            $isCorrect = $false
        }
    }
    return $isCorrect
}
Set-Alias -Name "sudo" -Value Confirm-Admin

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUh70QVJP+AsiSUxD4emr1KD7O
# TAmgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBQyMq7bZXIluaptHAg+uUIcR/cLWTANBgkqhkiG9w0BAQEFAASCAgBwDCd5
# HeA8117Y563hXVw99IvJbbdmD5IPFrw7hISEW6OEf7Q45IAdmcpPIdzkjsQIST+i
# aR60/DTiXTOIbSp/EVjQp/TlIpfVoL6L8vcFx3hcXjLhWw48+N27yTpP/xFitVjG
# CkH/+kmK2wClPL/Y9+0rY6QI5BJPb1ZkHvtUtAl0k2m8jSwVXovcyEestbH3D+yM
# zcOiWuRAW5msRXGO1SjlsmAQXSvgeUH36dwkQ825mmODOF2b+pEGWJa9rta4j72D
# ALzUM7V1+DB54ND47R0/6PXKmDLUQYBoTPjnbV46F/oMNH3FrN8TZSImGtDOSzyT
# t9uGOq81icR+Gmcy/fuLT8K91YY5Ux/TzhKQNClDnaNfqc/A7k4EVMU5aS19MrTl
# nJkZ3/AoChEpDLEnzLZsiDeNTu/LBQuITBgRqyACKKWENY+LQ2s5BJxseS21pVoA
# WjC6HqOZraQAA+LMtkvkSE2N8nHndFxxzWClXbifMMiC1jjUC7Q3b7TcIDY0EtEo
# bztyxSFWKb0ThIkdywoU41pBkPpjU56qLeIee/YnpI80r8NFR9t1pEvILD2JnQbd
# HNDMP0pF/THXiNFZtseBzjiSI4TJFbp7GX10MhnvFOEIX0wsVQPCcar69Tk6vZ9j
# ymwiqk6vMSEfkN0s4k1hViMAho5q4r7S6WzvAg==
# SIG # End signature block
