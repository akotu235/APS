# APS
APS PowerShell

## Description
A set of useful tools in the form of a powershell module.

## Installation
The script below installs the latest version of APS and also generates a local script signing certificate if needed.

```Powershell
$PSModulePaths = $env:PSModulePath.Split(";") 
foreach ($p in $PSModulePaths){
    if($p -like "?:\Users\*\*\WindowsPowerShell\Modules"){
        $APS_Base = "$p\APS"
    }
}
mkdir $APS_Base
$Client = New-Object System.Net.WebClient
$Client.DownloadFile("https://github.com/akotu235/APS/archive/refs/heads/master.zip","$APS_Base/APS-master.zip")
Expand-Archive -Path "$APS_Base/APS-master.zip" -DestinationPath $APS_Base
mv $APS_Base\APS-master\aps.psd1 $APS_Base
mv $APS_Base\APS-master\aps.psm1 $APS_Base
mv $APS_Base\APS-master\Modules $APS_Base
rm -r $APS_Base\APS-master.zip
rm -r $APS_Base\APS-master
Set-ExecutionPolicy Bypass -Scope Process -Force
Import-Module "$APS_Base\Modules\AutoConfiguration"
Import-Module "$APS_Base\Modules\ScriptsSigner"
if(!(Get-ChildItem cert:\CurrentUser\My -codesigning)){
    New-CodeSigningCert
}
Add-Signature $APS_Base
$answer = Read-Host -Prompt "Add APS to autostart?(yes)"
if($answer -like "" -or $answer -like "y*"){
    $Profile = Convert-Path "$APS_Base\..\..\"
    $Profile = "$Profile\profile.ps1"
    if(Test-Path $Profile){
        Remove-Signature $Profile
    }
    '<# Automatic loading of the APS module #>' | Add-Content -Path $Profile
    'Import-Module APS' | Add-Content -Path $Profile
    Add-Signature $Profile
}
Import-Module APS
```
