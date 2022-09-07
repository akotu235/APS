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
Removes the signature.
.PARAMETER File
Enter the path of the script to remove the signature.
.EXAMPLE
.\Remove-Signature.ps1 -File .\scriptNmae.ps1
#>
function Remove-Signature{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$File
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

