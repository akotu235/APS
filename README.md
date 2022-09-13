# APS
APS PowerShell

## Description
A set of useful tools in the form of a PowerShell module.

## Installation
Run the command below in PowerShell.

```Powershell
Install-Script -Name APS.Installer -Scope CurrentUser;Set-ExecutionPolicy Bypass -Scope Process -Force;& "$((Get-InstalledScript -Name APS.Installer).InstalledLocation)\APS.Installer.ps1";exit
```
## Update
Upgrade to the latest version using the command:
```Powershell
Update-APS
```
## Modules
<details>
  <summary>APSUpdater</summary>
  <ol>
    <ul>Updates APS to the latest version.</ul>
  </ol>
</details>

<details>
  <summary>AutoConfiguration</summary>
  <ol>
    <ul>Simplifies setup.</ul>
  </ol>
</details>

<details>
  <summary>AutoShutdown</summary>
  <ol>
    <ul>Shuts down the computer at a specified time.</ul>
  </ol>
</details>

<details>
  <summary>ConfigMenager</summary>
  <ol>
    <ul>It facilitates the management of configuration files. Loads, updates and deletes settings.</ul>
  </ol>
</details>

<details>
  <summary>DesktopCleaner</summary>
  <ol>
    <ul>Keeps your desktop tidy. Moves unnecessary files from the desktop to the archive.</ul>
  </ol>
</details>

<details>
  <summary>Geolocalization</summary>
  <ol>
    <ul>Provides geolocation information based on the network.</ul>
  </ol>
</details>

<details>
  <summary>Greeter</summary>
  <ol>
    <ul>Displays useful information when PowerShell starts up.</ul>
  </ol>
</details>

<details>
  <summary>MessageEncoder</summary>
  <ol>
    <ul>It encrypts and decrypts secret messages.</ul>
  </ol>
</details>

<details>
  <summary>Notifier</summary>
  <ol>
    <ul>Creates and displays notifications at the specified time.</ul>
  </ol>
</details>

<details>
  <summary>ScriptsSigner</summary>
  <ol>
    <ul>It is used to sign scripts.</ul>
  </ol>
</details>

<details>
  <summary>Speaker</summary>
  <ol>
    <ul>Converts text to speech.</ul>
  </ol>
</details>

<details>
  <summary>TaskCreator</summary>
  <ol>
    <ul>Creates tasks and runs them at the specified time.</ul>
  </ol>
</details>

<details>
  <summary>TextFinder</summary>
  <ol>
    <ul>Searches text files for the specified phrase.</ul>
  </ol>
</details>

<details>
  <summary>Weather</summary>
  <ol>
    <ul>Checks the current weather.</ul>
  </ol>
</details>

## License
Distributed under the MIT License. See [LICENSE.md](https://github.com/akotu235/APS/blob/master/LICENSE.md) for more information.

## Contact
Andrew - [Ask your question online](//widget.gg.pl/widget/38fe4ce527f071b3b70ecd72dadbb984438e54ac747479461c9331e371a4c2f0#uin%3D73836695%7Cmsg_online%3D%7Cmsg_offline%3DLeave%20a%20message%20and%20contact%20information%20and%20I%20will%20answer%20your%20question.%7Chash%3D38fe4ce527f071b3b70ecd72dadbb984438e54ac747479461c9331e371a4c2f0)

Project Link: [https://github.com/akotu235/APS](https://github.com/akotu235/APS)
