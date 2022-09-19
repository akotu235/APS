<#
.SYNOPSIS
Returns the settings.
.DESCRIPTION
Returns configuration of the given module or contained in the indicated xml file.
.PARAMETER ModuleBase
Specifies the location of the module.
.PARAMETER Field
Returns a single setting field based on the name.
.PARAMETER CustomPath
Specifies a custom settings file path.
.EXAMPLE
Get-Config $ModuleBase
#>
function Get-Config{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory=$true, ParameterSetName='Default', Position=0)]
        [System.String]$ModuleBase,
        [Parameter(Mandatory=$true, ParameterSetName='CustomPath', Position=0)]
        [System.String]$CustomPath,
        [Parameter(Position=1)]
        [System.String]$Field
    )
    if($ModuleBase){
        $ConfigPath = Get-ConfigPath $ModuleBase
    }
    else{
        $ConfigPath = Get-ConfigPath -CustomPath $CustomPath
    }
    if(Test-Path $ConfigPath){
        [psobject]$Config = Import-Clixml -Path $ConfigPath
    }
    else{
        return $null
    }
    if($Field){
        if($Config.$Field){
            return $Config.$Field
        }
        else{
            return $null
        }
    }
    return $Config
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
.PARAMETER CustomPath
Specifies a custom settings file path.
.EXAMPLE
Set-ConfigField $ModuleBase "Field" "Value"
#>
function Set-ConfigField{
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory=$true, ParameterSetName='Default', Position=0)]
        [System.String]$ModuleBase,
        [Parameter(Mandatory=$true, ParameterSetName='CustomPath', Position=0)]
        [System.String]$CustomPath,
        [Parameter(Mandatory = $true, Position=1)]
        [System.String]$Field,
        [Parameter(Mandatory = $true, Position=2)]
        [System.String]$Value
    )
    if($ModuleBase){
        $Config = Get-Config $ModuleBase
    }
    else{
        $Config = Get-Config -CustomPath $CustomPath
    }
    if($Config){
        $Config | Add-Member NoteProperty $Field $Value -Force
    }
    else{
        $Config = New-Object PSObject -Property @{
            $Field = $Value
        }
    }
    if($ModuleBase){
        return Save-Config $ModuleBase $Config
    }
    else{
        return Save-Config -CustomPath $CustomPath $Config
    }
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
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory=$true, ParameterSetName='Default', Position=0)]
        [System.String]$ModuleBase,
        [Parameter(Mandatory=$true, ParameterSetName='CustomPath', Position=0)]
        [System.String]$CustomPath,
        [Parameter(Position=1)]
        [System.String]$Field
    )
    if($ModuleBase){
        $Config = Get-Config $ModuleBase
    }
    else{
        $Config = Get-Config -CustomPath $CustomPath
    }
    if($Config){
        if($Field){
           $Config.PSObject.Properties.Remove("$Field")
           if($ModuleBase){
                return Save-Config $ModuleBase $Config
            }
            else{
                return Save-Config -CustomPath $CustomPath $Config
            }
        }
        else{
            if($ModuleBase){
                Remove-Item -Path (Get-ConfigPath $ModuleBase) -Force
            }
            else{
                Remove-Item -Path (Get-ConfigPath -CustomPath $CustomPath) -Force
            }
            return $null
        }
    }
    else{
        return $null
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
.PARAMETER CustomPath
Specifies a custom settings file path.
.EXAMPLE
Save-Config $ModuleBase $Config
#>
function Save-Config{
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory=$true, ParameterSetName='Default', Position=0)]
        [System.String]$ModuleBase,
        [Parameter(Mandatory=$true, ParameterSetName='CustomPath', Position=0)]
        [System.String]$CustomPath,
        [Parameter(Mandatory = $true, Position=1)]
        [psobject]$Config
    )
    if($ModuleBase){
        $ConfigPath = Get-ConfigPath $ModuleBase
        $ConfigDir = Split-Path $ConfigPath
    }
    else{
        $ConfigPath = Get-ConfigPath -CustomPath $CustomPath
        $ConfigDir = Split-Path $ConfigPath
    }
    if(!(Test-Path $ConfigDir)){
        New-Item -Path $ConfigDir -ItemType Directory -Force
    }
    $Config | Export-Clixml -Path $ConfigPath -Force
    return $Config
}

function Get-ConfigPath{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory=$true, ParameterSetName='Default', Position=0)]
        [System.String]$ModuleBase,
        [Parameter(Mandatory=$true, ParameterSetName='CustomPath')]
        [System.String]$CustomPath
    )
    if($ModuleBase){
        $FileName = "$((@($ModuleBase.Split("\"))[-1]).ToString().ToLower()).config.xml"
        return "$env:LOCALAPPDATA\APS\Configuration\$FileName"
    }
    else{
        if(!($CustomPath -like "*.xml")){
            $CustomPath += "\config.xml"
        }
        return $CustomPath
    }
}