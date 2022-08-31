<#
.SYNOPSIS
Signs the script with my certificate
.DESCRIPTION
Signs the script passed by the parameter
.PARAMETER File
Enter the path to the file 
.EXAMPLE
.\Add-Signature.ps1 -File .\scriptToSign.ps1
#>
function Add-Signature{
    [CmdletBinding()] 
    param(
        [Parameter(Mandatory=$true)]
        [string]$File
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
                $Cert=(Get-ChildItem cert:\CurrentUser\My -codesigning | where Subject -like "*$($listBox.SelectedItem)*")
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
        $Files = Get-ChildItem -Path $File -Recurse | where -Property Extension -Match ".psm?1"
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
Removes the signature.
.PARAMETER File
Enter the path of the script to remove the signature.
.EXAMPLE
.\Remove-Signature.ps1 -File .\scriptNmae.ps1
#>
function Remove-Signature{
    [CmdletBinding()] 
    param(
        [Parameter(Mandatory=$true)]
        [string]$File
    )
    if((Get-Content $File).Contains("# SIG # Begin signature block")){
        try{
            $FileContent = Get-Content $File
            $FileContent[0..(((Get-Content $File | Select-String "SIG # Begin signature block").LineNumber)-2)] | Set-Content $File
        }
        catch{}
    }
}
##########

# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9hrwCQDxzVHoNyjBqfzWhtjg
# Nf+gggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
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
# CQQxFgQUCVmyrChaTkUbDQGQfoh1/rlJiuIwDQYJKoZIhvcNAQEBBQAEggEAC4/0
# mqa1u/MrKfT9nj6qOtsVogr3KiwHnkVDi31Y1Kn7sE0p0JSPHWzeeYFco/aDB+IT
# O0d60tRwphPa7uQA0Xag6zPl3wHyB0NpcALQw0M8h+N0z+z5ao0hA8irnCc8Hs2V
# 3pg6G8QKubvMez4lhHCz/MIsJrmdazbYdOUT1BH1t67IH9pVQDoQYVRPngY4YCBE
# Vf75Rqrvmm50G8lZvUKMzCFXo4nkgf8LPFr7duoTFaLTA1n18UdmtDIgshmeW8S/
# au/9KSD8Kcm9MJQ0gJNgnTRp5Xu+UEmImVGBKNz5M4GWpTUV8IWrq/+5nukCiE9F
# XxRy2tfC+pTWQtBebQ==
# SIG # End signature block
