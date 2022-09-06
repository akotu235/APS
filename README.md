# APS
APS PowerShell

## Description
A set of useful tools in the form of a powershell module.

## Installation
Run the command below in Powershell.

```Powershell
Install-Script -Name APS.Installer -Scope CurrentUser;Set-ExecutionPolicy Bypass -Scope Process -Force;& "$((Get-InstalledScript -Name APS.Installer).InstalledLocation)\APS.Installer.ps1";exit
```
## Update
Upgrade to the latest version using the command:
```Powershell
Update-APS
```
