<#
.SYNOPSIS
Adds an Authenticode signature to a PowerShell script or other file.
.DESCRIPTION
The ``Add-Signature`` cmdlet adds an Authenticode signature to the specified file using the installed local certificate. If no certificate is installed, the user is asked if he wants to create a new local certificate. In a PowerShell script file, the signature takes the form of a block of text that indicates the end of the instructions that are executed in the script. If there is a signature in the file when this cmdlet runs, that signature is removed.
.PARAMETER File
Specifies the file to be signed. If a directory is selected, all scripts in it and in subdirectories will be signed.
.EXAMPLE
Add-Signature -File ".\scriptToSign.ps1"
#>
function Add-Signature{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [System.String]$File
    )
    if(@(Get-ChildItem cert:\CurrentUser\My -codesigning).Length -gt 0){
        if((Get-ChildItem cert:\CurrentUser\My -codesigning).Length -eq 1){
            $Cert = (Get-ChildItem cert:\CurrentUser\My -CodeSigningCert)[0]
        }
        else{
            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName System.Drawing
            $form = New-Object System.Windows.Forms.Form
            $form.Text = 'Select a Certificate'
            $form.Size = New-Object System.Drawing.Size(300,200)
            $form.StartPosition = 'CenterScreen'
            $okButton = New-Object System.Windows.Forms.Button
            $okButton.Location = New-Object System.Drawing.Point(75,120)
            $okButton.Size = New-Object System.Drawing.Size(75,23)
            $okButton.Text = 'OK'
            $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $form.AcceptButton = $okButton
            $form.Controls.Add($okButton)
            $cancelButton = New-Object System.Windows.Forms.Button
            $cancelButton.Location = New-Object System.Drawing.Point(150,120)
            $cancelButton.Size = New-Object System.Drawing.Size(75,23)
            $cancelButton.Text = 'Cancel'
            $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $form.CancelButton = $cancelButton
            $form.Controls.Add($cancelButton)
            $label = New-Object System.Windows.Forms.Label
            $label.Location = New-Object System.Drawing.Point(10,20)
            $label.Size = New-Object System.Drawing.Size(280,20)
            $label.Text = 'Please select Certificate:'
            $form.Controls.Add($label)
            $listBox = New-Object System.Windows.Forms.ListBox
            $listBox.Location = New-Object System.Drawing.Point(10,40)
            $listBox.Size = New-Object System.Drawing.Size(260,20)
            $listBox.Height = 80
            $Certs = @(Get-ChildItem cert:\CurrentUser\My -codesigning)
            foreach($Cert in $Certs){
                [void] $listBox.Items.Add($Cert.Subject.ToString())
            }
            $form.Controls.Add($listBox)
            $form.Topmost = $true
            $result = $form.ShowDialog()
            if($result -eq [System.Windows.Forms.DialogResult]::OK){
                $Cert=(Get-ChildItem cert:\CurrentUser\My -codesigning | Where-Object Subject -like "*$($listBox.SelectedItem)*")
            }
        }
    }
    else{
        Write-Warning no certificate.
        $ans = Read-Host -Prompt "Do you want to create a new certificate?(y/n)"
        if($ans.ToLower() -like "y*"){
            New-CodeSigningCert
        }
    }
    if((Get-ItemProperty $File).Mode -like "d-*" ){
        $Files = Get-ChildItem -Path $File -Recurse | Where-Object -Property Extension -Match ".psm?1"
        foreach ($f in $Files){
            Remove-Signature $f.FullName
            Set-AuthenticodeSignature $f.FullName $Cert
        }
    }
    else{
        Remove-Signature $File
        Set-AuthenticodeSignature $File $Cert
    }
}

<#
.SYNOPSIS
Removes the script signature.
.DESCRIPTION
If the indicated file has a signature block it will be removed.
.PARAMETER File
Specifies the file to remove the signature.
.EXAMPLE
.\Remove-Signature.ps1 -File .\scriptNmae.ps1
#>
function Remove-Signature{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [System.String]$File
    )
    if((Get-Content $File).Contains("# SIG # Begin signature block")){
        try{
            $FileContent = Get-Content $File
            $FileContent[0..(((Get-Content $File | Select-String "SIG # Begin signature block").LineNumber)-2)] | Set-Content $File
        }
        catch{
            Write-Information "Signature was not removed from $File"
        }
    }
}
##########


# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjrHR0EZZCUpq7GBu5CtkGlsP
# os+gggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBR9/yUQkd7qsj+w3DkdwYnNIXo6fzANBgkqhkiG9w0BAQEFAASCAgAdehiK
# YfDLqsDXQADTR6C7DXEgq9Ehh/bKmtIvGV1jpB61bGqOf+S1GaT1tITy55X2enLm
# t6arv0iwFYkY2k9wb5u9VBpTJLR55JmX2Lb+IgiliOuwIVvrxht7JX61LvS+kFdm
# VNvkBeTJVpBhvtwiz5Aq2eUzNS3wOm+sOgo9hLbrtYd4NA7bj7bDH+hHzBvZjeES
# MKTm973kAtZzMwvxGnlC4aTv5jE0OxxxAUndQsAHkNfmijd0GFuktu++4s66+cv0
# coeXAqUoBLa6fkWRAjZmITip4234n1eIuGEX1WrL0uHikhwK2Kdz0SkPwDyNEvM2
# pdYtvvnOD/mMmXarp7VbEaFETG+EVOCq9aSlwFkhux7FrGhYj089DqDj8xMdN4t3
# inLu7s5eLOhCDx3ttWERMLjdNGZwQhs/cSZtVItQJJrJ7/X09uy0WtKcPaW+xfaP
# BkQNRl7Fd272crqtA9hmMSE5xr9qcZAg0iqfT+uzV7nkkyc7SGGTDmSM2vtsxMmX
# OqhUTll7ipfwz+VlVdHRe3RnPnmTBmSDp4pihYPZ8x4EfbqdQuZS+cJAcIhDBBL/
# St2CXvpyuOG+6isyzV1STw+bZjwum41uDOLrlY7KYshlkROxOC6GeSl7w+NgN8uI
# YkGWAKVEqXHt1G74TrR/2j0Y+yiIpoOruoDnvA==
# SIG # End signature block
