function Get-Config{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleBase,
        [string]$Field,
        [string]$ConfigPath,
        [string]$FileName
    )
    if($ConfigPath = (Get-ConfigPath $ModuleBase -FileName $FileName -ConfigPath $ConfigPath)){
        [psobject]$Config = Import-Clixml -Path (Get-ConfigPath $ModuleBase -FileName $FileName -ConfigPath $ConfigPath -SkipTest)
        if($Field){
            if($Config.$Field){
                return $Config.$Field
            }
            else{
                return $null
            }
        }else{
            return $Config
        }
    }
    else{
        return $null
    }
}

function Set-ConfigField{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleBase,
        [Parameter(Mandatory = $true)]
        [string]$Field,
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [string]$ConfigPath,
        [string]$FileName
    )
    $Config = Get-Config $ModuleBase -FileName $FileName -ConfigPath $ConfigPath
    Write-Verbose "Setting the $Field configuration field on a module $(@($ModuleBase.Split("\"))[-1])."
    if($Config){
        $Config | Add-Member NoteProperty $Field $Value -Force
    }
    else{
        $Config = New-Object PSObject -Property @{
            $Field = $Value
        }
    }
    return (Save-Config $ModuleBase -Config $Config -FileName $FileName -ConfigPath $ConfigPath)
}

function Remove-Config{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleBase,
        [string]$Field,
        [string]$ConfigPath,
        [string]$FileName
    )
    if($Config = Get-Config $ModuleBase -FileName $FileName -ConfigPath $ConfigPath){
        if($Field){
            if($Config.$Field){
                Write-Verbose "Removing the $Field configuration field from the $(@($ModuleBase.Split("\"))[-1]) module."
                $Config.PSObject.Properties.Remove("$Field")
                return (Save-Config $ModuleBase -Config $Config -FileName $FileName -ConfigPath $ConfigPath)
            }
        }
        else{
            Write-Verbose "Deleting configuration file from module $(@($ModuleBase.Split("\"))[-1])."
            Remove-Item -Path (Get-ConfigPath $ModuleBase -FileName $FileName -ConfigPath $ConfigPath -SkipTest)
            return $null
        }
    }
}

function Save-Config{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleBase,
        [Parameter(Mandatory = $true)]
        [psobject]$Config,
        [string]$ConfigPath,
        [string]$FileName
    )
    Write-Verbose "Saving $(@($ModuleBase.Split("\"))[-1]) config."
    $DestPath = Get-ConfigPath $ModuleBase -FileName $FileName -ConfigPath $ConfigPath -SkipTest
    $DestDir = Split-Path $DestPath
    if(!(Test-Path $DestDir)){
        New-Item -Path $DestDir -ItemType Directory -Force
    }
    $Config | Export-Clixml -Path (Get-ConfigPath $ModuleBase -FileName $FileName -ConfigPath $ConfigPath -SkipTest) -Force
    return $Config
}

function Get-ConfigPath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleBase,
        [string]$ConfigPath,
        [string]$FileName,
        [switch]$SkipTest
    )
    if(!$FileName){
        $FileName = "$((@($ModuleBase.Split("\"))[-1]).ToString().ToLower()).config.xml"
    }
    elseif(!($FileName -like "*.xml")){
        $FileName = "$FileName.config.xml"
    }
    if($ConfigPath){
        if(!($ConfigPath -like "*.xml")){
            $ConfigPath = "$ConfigPath\$FileName"
        }
    }else{
        $ConfigPath = "$HOME\AppData\Local\APS\Configuration\$FileName"
    }
    if($SkipTest){
        return $ConfigPath
    }
    elseif(Test-Path $ConfigPath){
        return $ConfigPath
    }
    else{
        return $null
    }
}