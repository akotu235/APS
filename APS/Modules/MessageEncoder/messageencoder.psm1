<#
.SYNOPSIS
Generates public and private key for encryption.
.DESCRIPTION
Generates a pair of RSA keys with a length of 4096 bits.
.PARAMETER Name
Enter the name of the certificate.
.EXAMPLE
New-EncryptionKey "CertificateName"
#>
function New-EncryptionKey{
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )
    $store = "cert:\CurrentUser\My"
    $params = @{
        CertStoreLocation = $store
        Subject = "CN=APS_$Name"
        KeyLength = 4096
        KeyAlgorithm = "RSA"
        KeyUsage = "DataEncipherment"
        Type = "DocumentEncryptionCert"
        NotAfter = (Get-Date).AddYears(10)
    }
    $cert = New-SelfSignedCertificate @params
    $keysDir = "$HOME\.keys"
    $privateKey = "$keysDir\My\$Name.pfx"
    $publicKey = "$keysDir\My\$Name.pub.cer"
    mkdir "$keysDir\My" -Force >> $null
    $keyPassword = (Read-Host -AsSecureString -Prompt "Create a key password")
    Export-PfxCertificate -FilePath $privateKey -Cert $cert -Password $keyPassword
    Export-Certificate -FilePath $publicKey -Cert $cert
    explorer.exe "$keysDir\My"
    $cert | Remove-Item
    try{
        Import-PfxCertificate -FilePath $privateKey -CertStoreLocation $store -Password $keyPassword -ProtectPrivateKey VSM
    }
    catch{
        Import-PfxCertificate -FilePath $privateKey -CertStoreLocation $store -Password $keyPassword
    }
    Get-ChildItem Cert:\CurrentUser\CA | Where-Object Subject -Like "CN=APS_$Name" | Remove-Item
}

<#
.SYNOPSIS
Encrypts the message.
.DESCRIPTION
Encrypts the message with the indicated rsa public key and copies it to the clipboard.
.PARAMETER Name
Enter your message.
.EXAMPLE
Protect-Message "<secret>"
#>
function Protect-Message{
    [OutputType([String])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $storageCA = Get-ChildItem Cert:\CurrentUser\CA -DocumentEncryptionCert | Where-Object Subject -Like "CN=APS_*"
    if($storageCA){
        $storageCA | ForEach-Object {
                Move-Item -Path Cert:\CurrentUser\CA\$($_.Thumbprint) -Destination Cert:\CurrentUser\My
            }
    }
    $encryptionCerts = Get-ChildItem Cert:\CurrentUser\My -DocumentEncryptionCert
    if($encryptionCerts.Count -eq 0){
        Write-Output "No encryption certificates"
    }
    else{
        Write-Output "Installed certificates:"
        $encryptionCerts | ForEach-Object {$_.Subject.TrimStart("CN=APS_")}
        $CN = Read-Host -Prompt "Enter the name of the encryption certificate"
        if($CN -notlike "CN=APS_*"){
            $CN = "CN=APS_$CN"
        }
        $cipher = $Message | Protect-CmsMessage -To $CN
        Write-Output "Cipher:" -ForegroundColor Green
        $cipher = "`"$($cipher.Replace("`r`n",";").Replace("`n",";").TrimStart("-----BEGIN CMS-----").TrimEnd("-----END CMS-----"))`""
        $cipher
        Set-Clipboard -Value $cipher
    }
}

<#
.SYNOPSIS
Decrypts the message.
.DESCRIPTION
Decrypts the message if the appropriate private key is installed.
.PARAMETER Name
Enter an decrypted message.
.EXAMPLE
Unprotect-Message "<decrypted message>"
#>
function Unprotect-Message{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $Message = "-----BEGIN CMS-----$($Message.Trim('"'))-----END CMS-----".Replace(";","`r`n")
    try{
        $decryptedMessage = ($Message | Unprotect-CmsMessage)
        Write-Host "Decrypted message:" -ForegroundColor Green
        $decryptedMessage
    }
    catch{
        Write-Host "No proper key to read this message" -ForegroundColor Red
    }
}




# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUu0UiNAmexKIOBnmR7pCoQWMd
# byOgggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
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
# CQQxFgQUWuBbgFG5AUIhyTI2l7rBMBdrJbcwDQYJKoZIhvcNAQEBBQAEggEAGw96
# lictoga48zYD+zlPLvp1CHuKq0tO73+pNU9Kmwgl2XiMIi918TzdaPyvUkIYh5Wn
# mGZk/676ZySgT8NDqVz7rcSFaynb6zOhWtzhIqHm8s8OAZYFgDLY1BA8ot9Q4amb
# tjsfEQWwpjTI4htFWYov2ap6+/9J9TDy7/FCFyB8EcvCtPCIVtgRhTsz1ABqZOp4
# X7j5yiGty1bywShxcVok3GXzoDO8j1HAIWgEdE5OlgNXLyGaKEIji/Y0NaRqKUvC
# pyxFlX9ZBcvu8IINg638/HwKLZjrjrTMrefZPaY5EG84TYq890h0MTkegpBOQq8s
# JQNvScIfJD+rbnVSzA==
# SIG # End signature block