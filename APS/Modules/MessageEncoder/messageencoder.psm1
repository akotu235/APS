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
    [CmdletBinding(SupportsShouldProcess, HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/MessageEncoder/New-EncryptionKey.md")]
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
    if(-not (Test-Path "$keysDir\My")){
        New-Item -ItemType Directory -Path "$keysDir\My" -Force >> $null
    }
    $privateKey = "$keysDir\My\$Name.pfx"
    $publicKey = "$keysDir\My\$Name.pub.cer"
    $keyPassword = Read-Password -Prompt "Create a key password"
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
    [CmdletBinding(HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/MessageEncoder/Protect-Message.md")]
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
    [CmdletBinding(HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/MessageEncoder/Unprotect-Message.md")]
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUzWHZL/5LWXirH8jQyXhF+Qbd
# JxSgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBQ5CCPwc4ZP24WiVBGrr+9oG7nu2jANBgkqhkiG9w0BAQEFAASCAgBS1TDN
# N0PR8baKC3j1K6VbqoW7Pm0J0SKLbCiL9ro7eZNKJ87alJnFoTFr4XzoYKj9rt3z
# 9icci5BVKJ35HWAnMhdd2BhWilRC3HbqdYVor5D0igQ5ZF3ALrIHwLZeRIUCqQaN
# OJTmJ06Aiq/9PgeN7+hBz8KS8R5eJa0mNThDlKSPni/Rq0CjCiRZAcXcXvpFZ9HS
# u5ukMgXSHgd3Yj5Bc/IOZWGg+yCYKToCp9YEYYAPHpSbvQqLxwYw4I1MTlvBxhTa
# NCKs52gDqR28t2VqKN3CL+ENUBIBwbRDV5K3El9AF4YDlCYaVKIX0/jcQry9Zbtf
# TdMhFE5rQdmEXYY1HHhzoZZgYgGsoCV+Z/5vDdy1BGzvaNSkCFSSOQuAvCQtogL/
# i3bUeyQgMLgFStNNxLZG2GCSgQ2tZSBWDELQxdnmX/lUwwpkyst0S7XEy1yyf1BQ
# xEW8qG2j/vMjXZkRIByilDxgTHU6rpKDJa0GbhrPBWU4QET6Nt+dnW0vezbbwUxK
# VybHSPipSUHWuoWEkvVOQJuFtTVjwGzPciRbwNRBEMo+9OOwIRXkEMCJioHSrdrV
# K3DIi6VqrjbCqpujwJNozz4576dyJbEgPi1EK+6LoftFOJEDQ2mF+SonyOPATArv
# OUpPa75xazDAtlHR2RujQ/tgbYd//1PtJ9HLVQ==
# SIG # End signature block
