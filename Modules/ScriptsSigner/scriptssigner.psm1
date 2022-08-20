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
            Set-AuthenticodeSignature $f.FullName $Cert
        }
    }
    else{
        Set-AuthenticodeSignature $File $Cert
    }
}
# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbHAPCJttnjzSxaMCZdhdL5fK
# dM2gggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
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
# CQQxFgQUP9ocxWggQ1WJ/OU7unLL8mvTf9cwDQYJKoZIhvcNAQEBBQAEggEAGOE2
# Vu4UruxjOZdPcdD9X/Zeg4ZB2Lqw1l1zgTm1WDZJxApsuvbhrJWPqm4bhuRTAnB3
# QThsrs0d7h4RyEIiuUO2HXsxUFap7Carq/lgnX5wsEOaKD/GK0xC/bYihjBMNllg
# m+mz56h7gBYCF6U2ci51Nskf2srCeyOIf2uvj4ij4cnzVASGNekZF8B1O61dz7c5
# c4fiulKAECZ7/ck+I1VOvpBNLYVAs5RK5k90H4yFkcMrftUDqkhTghbcYADBOskh
# 4V/EKTOt21ZChbMgHY9Mf8PmoI5EljufpyXoiwgpg7cA6giufTPHrNWEiN0QSRjF
# w9oTw2LHOJigQn0cmw==
# SIG # End signature block
