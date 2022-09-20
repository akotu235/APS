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
    $keyPassword = Read-Password
    Export-PfxCertificate -FilePath $privateKey -Cert $cert -Password $keyPassword -Force
    Export-Certificate -FilePath $publicKey -Cert $cert -Force
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
function Read-Password{
    return Read-Host -AsSecureString -Prompt "Create a key password"
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
        Write-Host "No encryption certificates!" -ForegroundColor Red
    }
    else{
        Write-Output "Installed certificates:"
        $encryptionCerts | ForEach-Object {$_.Subject.TrimStart("CN=APS_")}
        $cipher = $Message | Protect-CmsMessage -To $(Read-Key)
        Write-Host "Cipher:" -ForegroundColor Green
        $cipher = "`"$($cipher.Replace("`r`n",";").Replace("`n",";").TrimStart("-----BEGIN CMS-----").TrimEnd("-----END CMS-----"))`""
        Set-Clipboard -Value $cipher
        return $cipher
    }
}
function Read-Key{
    $CN = Read-Host -Prompt "Enter the name of the encryption certificate"
    if($CN -notlike "CN=APS_*"){
        $CN = "CN=APS_$CN"
    }
    return $CN
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

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUrwrazIR2RbCERpSaK9aCHkJk
# 5/2gggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBRjYsbJe/+zhIm700KvHKmdsfIN4jANBgkqhkiG9w0BAQEFAASCAgCj++Tu
# p17ahXH+YxLQidalNQXrbmXkq+yqDhPi3PLJ6u7/96lPFrgjAEHkigqN4Ym8X55H
# 2bm6hjYAmagxJV/JofKpa/V6y+s/6cziztUhe9sv8Dc4yeP2kOVHgDLVnHJJxjMY
# 00gwd5RQnE6LrfTqqJ6VNfIh3MzGJPx3fB/+hWB6lFqahi/Ri9MJ13Pitfygx9y3
# keq/TaYm+q4wy2qy6pjwvL4GSl7e3qsjBfHIT4MXl0lg7aXW+7pD1JxS31lU6y+h
# 8Cp0gG6nuKQBWRA1SLReESJ6rUnRO2c+Injkn+i5vyWa0Y9Mwn3f2quglYBc3Ke2
# 8qq6CoRz3nSwarNfJRWFTWXjvfkOdNSD1D/oDpqOyzsNqlvSlnqjWciUl463neZX
# lqGI9luhozZJtvRK99PBir4ojvG+2qfNa6rxw2VB6qrkQNv11PJw3mp33VbEUlN2
# Yqw6AaoyvfvIRsEZYWISXRZcvUOReTKGdhJ61b/gpwN0AV2wNY5Zq7FUPur1vjXU
# MSuvtWxlcXMFSLvYSu2idGd/H1G2h1A0TkU1ucikkkz5wTL1KNcp5mXHM47tlfjD
# ukmbW4nBqL3C5FDLliMakoherX/CMZZ35A8UBYHtWPHDcwJSnEVY5diMU5gMSCmr
# ATS8wwUFStcDtY0nAri28HXMbIWkgB3N4ikaGg==
# SIG # End signature block
