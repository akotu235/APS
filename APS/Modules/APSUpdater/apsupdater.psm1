<#
.SYNOPSIS
Updates APS.
.DESCRIPTION
Downloads and installs the latest APS from the PowerShell Gallery.
.EXAMPLE
Update-APS
#>
function Update-APS{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$Force
    )
    $APS_Module = Get-Module APS
    if(($APS_Module.Version) -lt (Get-APSCurrentVersion) -or $Force){
        Import-Module ScriptsSigner
        $APS_Base = $APS_Module.ModuleBase | Split-Path
        Update-Module APS -Force:$Force
        Add-Signature $APS_Base >> $null
    }
    else{
        Write-Host "APS is up to date" -ForegroundColor DarkGreen
    }
}

<#
.SYNOPSIS
Gets the latest APS version number from the PowerShell Gallery.
.EXAMPLE
Get-APSCurrentVersion
#>
function Get-APSCurrentVersion{
    $url = "https://www.powershellgallery.com/packages/APS/?dummy=$(Get-Random)"
    $request = [System.Net.WebRequest]::Create($url)
    $request.AllowAutoRedirect=$false
    try{
        $response = $request.GetResponse()
        $version = $response.GetResponseHeader("Location").Split("/")[-1] -as [Version]
        $response.Close()
        $response.Dispose()
        return $version
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}