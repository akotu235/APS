<#
.SYNOPSIS
Returns the settings.
.DESCRIPTION
Returns configuration of the given module or contained in the indicated xml file.
.PARAMETER ModuleBase
Specifies the location of the module.
.PARAMETER Field
Returns a single setting field based on the name.
.PARAMETER ConfigPath
Specifies a custom settings file path.
.PARAMETER FileName
Specifies a custom name for the settings file.
.EXAMPLE
Get-Config $ModuleBase
#>
function Get-Config{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]$ModuleBase,
        [System.String]$Field,
        [System.String]$ConfigPath,
        [System.String]$FileName
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

<#
.SYNOPSIS
Sets a single field in the settings file.
.DESCRIPTION
Creates a new field or overwrites an existing one in the settings file. Returns an updated psobject configuration.
.PARAMETER ModuleBase
Specifies the location of the module.
.PARAMETER Field
Specifies the name of the setting to save. If it already exists, it overwrites it.
.PARAMETER Value
Specifies the setting value for the field.
.PARAMETER ConfigPath
Specifies a custom settings file path.
.PARAMETER FileName
Specifies a custom name for the settings file.
.EXAMPLE
Set-ConfigField $ModuleBase "Field" "Value"
#>
function Set-ConfigField{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]$ModuleBase,
        [Parameter(Mandatory = $true)]
        [System.String]$Field,
        [Parameter(Mandatory = $true)]
        [System.String]$Value,
        [System.String]$ConfigPath,
        [System.String]$FileName
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

<#
.SYNOPSIS
Deletes a configuration file or a single configuration field.
.DESCRIPTION
Deletes the configuration file, unless a specific field is specified. Returns the current configuration or ``$null``.
.PARAMETER ModuleBase
Specifies the location of the module.
.PARAMETER Field
Specifies the name of the field to be deleted.
.PARAMETER ConfigPath
Specifies a custom settings file path.
.PARAMETER FileName
Specifies a custom name for the settings file.
.EXAMPLE
Remove-Config $ModuleBase "Field"
#>
function Remove-Config{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]$ModuleBase,
        [System.String]$Field,
        [System.String]$ConfigPath,
        [System.String]$FileName
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

<#
.SYNOPSIS
Creates a configuration file.
.DESCRIPTION
Creates a configuration file or overwrites an existing one. Returns the current configuration.
.PARAMETER ModuleBase
Specifies the location of the module.
.PARAMETER Config
Specifies the psobject type configurations to save.
.PARAMETER ConfigPath
Specifies a custom settings file path.
.PARAMETER FileName
Specifies a custom name for the settings file.
.EXAMPLE
Save-Config $ModuleBase $Config
#>
function Save-Config{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]$ModuleBase,
        [Parameter(Mandatory = $true)]
        [psobject]$Config,
        [System.String]$ConfigPath,
        [System.String]$FileName
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

<#
.SYNOPSIS
Returns the path of the configuration file.
.DESCRIPTION
Returns the path of the configuration file. If ``-SkipTest`` is not set and the file does not exist returns ``$null``
.PARAMETER ModuleBase
Specifies the location of the module.
.PARAMETER ConfigPath
Specifies a custom settings file path.
.PARAMETER FileName
Specifies a custom name for the settings file.
.PARAMETER SkipTest
Skips checking for the existence of a configuration file.
.EXAMPLE
Get-ConfigPath $ModuleBase
#>
function Get-ConfigPath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]$ModuleBase,
        [System.String]$ConfigPath,
        [System.String]$FileName,
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