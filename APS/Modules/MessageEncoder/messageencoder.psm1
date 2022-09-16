<#
.SYNOPSIS
Generates public and private key for encryption.
.DESCRIPTION
Generates a 4096-bit RSA key pair and places them in the appropriate certificate stores. The keys are also saved in the ``$HOME\.keys`` location, and the private key is password protected. The public key is used to encrypt the message using the ``Protect-Message`` cmdlet and the corresponding private key is used to decrypt it using the ``Unprotect-Message`` cemdlet.
.PARAMETER Name
Specifies the name of the certificate. This name will be used by users who encrypt the message with the public key.
.EXAMPLE
New-EncryptionKey "CertificateName"
#>
function New-EncryptionKey{
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory=$true)]
        [System.String]$Name
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
.PARAMETER Message
Specifies the message to encrypt.
.EXAMPLE
Protect-Message "<secret>"
#>
function Protect-Message{
    [OutputType([System.String])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.String]$Message
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
Specify an encrypted message.
.EXAMPLE
Unprotect-Message "<encrypted message>"
#>
function Unprotect-Message{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.String]$Message
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