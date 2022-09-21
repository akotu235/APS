
<#PSScriptInfo

.VERSION 1.1.2

.GUID dcfea47c-45a6-4a40-96ab-759c222da486

.AUTHOR akotu

.COMPANYNAME akotu

.COPYRIGHT

.TAGS APS Installer

.LICENSEURI https://github.com/akotu235/APS/blob/master/LICENSE.md

.PROJECTURI https://github.com/akotu235/APS

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


#>

<#

.DESCRIPTION
 Installs APS

#>

Install-Module APS -Scope CurrentUser -Confirm:$false -Force -SkipPublisherCheck
Set-ExecutionPolicy Bypass -Scope Process -Force
Import-Module APS
$APS_Base = (Get-Module APS).ModuleBase
mkdir -Path "$APS_Base\installer" -Force >> $null
$client = New-Object System.Net.WebClient
$client.DownloadFile("https://github.com/akotu235/APS/raw/master/Installer/Installer.zip","$APS_Base\installer\Installer.zip")
Expand-Archive -Path "$APS_Base\installer\Installer.zip" -DestinationPath "$APS_Base\installer"
$certPath = "`'$APS_Base\installer\akotu CA.cer`'"
$command = "if(Import-Certificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\Root){exit}"
while(-not (Test-Path "$APS_Base\installer\akotu CA.cer")){}
Confirm-Admin -NoExit $command
$profilePath = $PROFILE.CurrentUserAllHosts
if(Test-Path $profilePath){
    $profileContent = Get-Content $profilePath -ErrorAction SilentlyContinue
    if(-not($profileContent -contains 'Import-Module APS')){
        if($profileContent.Length -eq 0){
            Move-Item -Path "$APS_Base\installer\profile.ps1" -Destination $PROFILE.CurrentUserAllHosts -Force
        }
        else{
            if(-not (Get-ChildItem cert:\CurrentUser\My -codesigning)){
                New-CodeSigningCert
            }
            Remove-Signature $profilePath
            Add-Content -Path $profilePath -Value '# Automatic loading of the APS module'
            Add-Content -Path $profilePath -Value 'Import-Module APS'
            Add-Signature $profilePath >> $null
        }
    }
}
else{
    Move-Item -Path "$APS_Base\installer\profile.ps1" -Destination $PROFILE.CurrentUserAllHosts -Force
}
while(-not ([boolean](Get-ChildItem "Cert:\LocalMachine\Root" | Where-Object {$_.Subject -like "CN=akotu CA"}) -and ($profileContent -contains 'Import-Module APS'))){
    $profileContent = Get-Content $profilePath -ErrorAction SilentlyContinue
}
Remove-Item -Path "$APS_Base\installer" -Recurse -Force
Get-Module APS | Remove-Module
try{
    Import-Module APS -ErrorAction Stop
    Write-Host "APS successfully installed." -ForegroundColor Green
}
catch{
    Write-Host "Something went wrong.." -ForegroundColor Red
}