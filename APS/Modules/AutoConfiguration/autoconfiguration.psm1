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
# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUboQh7hB5UguDFgGtFIDPy/6I
# DfagggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBQldO1zMsLX3Lai4s/ylZcXsrCIojANBgkqhkiG9w0BAQEFAASCAgBmRqro
# WYhmp5OrzkCCzFyDYb9gxwcAaROdHHVlF4BKvPWdJXVRc5RWCZpzq2NemiD4Updt
# rYhEozbxdTTvadBm/qOKs7SeD+jk++PUitz16/0U0MbFBpsMtAl1Hr/2/MF5XOm0
# BFVad+xzXq/B9QwnUAaoMpb6QBj3mwsmIyUuclmiaQsD2RMa53bdkBdPMnLJHu5p
# tJx0KLkEdFohKKhnPUO0HAcIHYM1/mkKLZb/YkFHWxu6Vn/wlvfS9bqYbGz5Il3j
# EXTt0ElnFX8qrLE09IXssWknBKZscgesfZIppPdIbod+2oYWrhfi2MvbddhHDH/3
# GlF7kErXRHxF6OHvRZIa1xNAsqByH6+7qkAXFgH0x2//cuxtuM4geoZCqWgrXCOA
# o7sKdmYFvb0MW5o1UclzYi8A8wl6ugHDRnOptA9Th7o7tVWtC4Hde3k55ES9lRZO
# hoXMNE4DPY1RvPA1trinOcEAnqKf0ulIq4KexW9+S0fwHyhqVJmZFlfF2YrzcXVb
# pyNJwr60HjEiCYOphzWgOp0I6xMp+ntSOwkUzGZNRxN2m3lmrCyppOPYvl4ASIIO
# Jo0j6Q3UacX2364vg5FItHUdpJIIYmrHZBn0SrB2i+N49AKN8CT0+ZEtjEgZol2w
# fZh424s39iR2/ohi/O4ruO5E9Q+S/nb4M16zIg==
# SIG # End signature block
