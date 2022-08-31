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
    [CmdletBinding()] 
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    $store = "cert:\CurrentUser\My"

    $params = @{
        CertStoreLocation = $store
        Subject = "CN=$Name"
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

    Import-PfxCertificate -FilePath $privateKey -CertStoreLocation $store -Password $keyPassword -ProtectPrivateKey VSM
}

<#
.SYNOPSIS
Encrypts the message.
.DESCRIPTION
Encrypts the message with the indicated rsa public key and copies it to the clipboard.
.PARAMETER Name
Enter your message.
.EXAMPLE
Protect-Message "secret"
#>
function Protect-Message{
    [CmdletBinding()] 
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    $encryptionCerts = Get-ChildItem Cert:\CurrentUser\CA -DocumentEncryptionCert
            
    if($encryptionCerts.Count -eq 0){
        Write-Host "No encryption certificates"
    }
    else{
        Write-Host "Installed certificates:"
        $encryptionCerts | foreach {$_.Subject.TrimStart("CN=")}
        $CN = Read-Host -Prompt "Enter the name of the encryption certificate"
        if($CN -notlike "CN=*"){
            $CN = "CN=$CN"
        }

        $cipher = $Message  | Protect-CmsMessage -To $CN
        Write-Host "Cipher:" -ForegroundColor Green
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
Enter an encrypted message.
.EXAMPLE
Protect-Message "secret"
#>
function Unprotect-Message{
    [CmdletBinding()] 
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    Write-Host "Decrypted message:" -ForegroundColor Green
    $Message | Unprotect-CmsMessage
}
# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUe19t/bCCUmsJPyTY1BjA61pY
# dGqgggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
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
# CQQxFgQU5HmcCx17XK1h0yJwkhdVlUYcGtwwDQYJKoZIhvcNAQEBBQAEggEAcIlp
# kVK0489YUpmMWGYFtfa2SKwOO/4VF2OuAl56lmbZ6+qQc70e8gkZmCtkkb+t2QN3
# OdtSeIfzyTxU0PIUjHXUB/89vJYVr40LtGLG2OZ0FERl8AIrzSTgja6ha235V4Vr
# c1MU8mZiMgzZsisyhKXHwL+ahRR/78k8/YiYit4wWHbNmKwSsbG0SIzHMd9b8eO0
# 0dwev2zYbkzOL4ZD8EtjTpiYEbL6bvPDWDhlGiSHZK7BAPJ4ofPEtzVhAcHeaZnN
# 5aDGLUF9hw1CnrhgpyhRqTrxei1ufJi3NuvABykoMLF/GshTeiubGPuPucsKPixb
# NhY0Ikmr2If9yOwVew==
# SIG # End signature block
