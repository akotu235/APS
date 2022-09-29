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
    [CmdletBinding(DefaultParameterSetName = 'Default', HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/ConfigManager/Get-Config.md")]
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
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default', HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/ConfigManager/Set-ConfigField.md")]
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
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default', HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/ConfigManager/Remove-Config.md")]
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
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default', HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/ConfigManager/Save-Config.md")]
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
    [OutputType([System.String])]
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

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/izl5wCuztH0zHXLLJLcDfWK
# SqagggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
# AQsFADATMREwDwYDVQQDDAhha290dSBDQTAeFw0yMjA5MjAxOTQ4MDFaFw0zMjA5
# MjAxOTU4MDFaMBMxETAPBgNVBAMMCGFrb3R1IENBMIICIjANBgkqhkiG9w0BAQEF
# AAOCAg8AMIICCgKCAgEAvGcae/FCZugTbghxO7Qv9wQKvRvp9/WvJyJci/SIsPr1
# /Mf5wfBTJ3aCvyjFvHfcsDH4NdHZubHO531tc1NHCDh+Ztkr5hbOdl3x46nEXm6u
# e4Fiw23SB02dU3dAnFvNSGEE5jhQDOApGX/u7xEW4ZXrvMC5yLCBa3Kva1abPx5b
# owvQlHhiSsn039/K2xSNhR+x4QcgEIo9JYdcob0f7ZY3AhXT+f1PNyYe075SY+t2
# y1YMlPlq4THolVUB4yB5MknAOG7IoxFt0U9vXhMSjbb06LZ/I/2RpAJd/qcaC/aX
# CBvKYQbbmEqMqKutic/Q23cQU2jcuRxyy+Y5QphALwdkQGIuvOOIQCak/ZKa6k5S
# 5U3zcMSbGOFF1BHdLSmcUnicsuvMM4uOT0zF/yzuSv5fSo3t6W5VHa+1Ct8ygt3/
# Byq2dLPskUPn0khR3/PaC8Px0k6TpcL1auKeb/uObvckBH/NVvQebtFuXMFXCayw
# ZFQx2dGfqb20Q5ZDNw5u8PtrSAeTaqZ7shrcsHbi59ztASvNjapdnhosQ26ir5bD
# Urzn7Fm/R/tZ9wpCuZ6i2LErckKGMW0Lk1ku0HJv83q/rr0vkrbEXUWx6eaaXwQj
# IacKX8IvED/HN1gQ9WfkvLmQurF9ZUfJQDC/WNrIwYw4advSARKs/4WE+HmN1g0C
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSUHb/MW3YJQEoACPnV20ZgngOGCDANBgkqhkiG9w0BAQsFAAOCAgEA
# C6pw+UgUjitD9crDEpEPIcmC/Eiif7DnMI2xG1aS8drSFkTvJdmG1yI4gUigjncb
# LfDSLbUIwAUfaM6V1zPb/ec0dg0Nkn+Za1fpuIXxuPKtvrqr9FLfc70D3AphNrDD
# rFEd3c1ykLed7lllMYaLXkfWDRlxhhpP+LR9qbgvTxFbWk/7yA7kJrwEaDgfqqME
# QEE9xZDEIN/f1ycTnh0qmUwYoHDEKbOet/OgiILjzqIjplnaaKJIzFjmfDDK8JY+
# 0tl3hnyFHkPVe9sKTIEVhjc8XlaaCDDTEPTiWvB3TPMLZCqcwqQ4WdcWpS0Dp1Ms
# XvRVv8NkcDMPzFpgqFpkkrkqt94IESUycaAQe+czlurf/KiQjzAjVvhZFspqbBi8
# 83AZ9+mBQhtQqgzcZYSF2LAPbfTXCPw8daT/hOrUaU72YrA4ON64ZRYvcaj9u1AN
# +pxo8TY+YNak+tVByU3sfLfFwbJMJi63be1yo1yLc3b/d3DrJz3AIY82LrtdQcT3
# tj3QnyvVHpFvtzKZxO5hSgaTksmRBYJZ6cYcBgW69l8UpppiyAtzKo4AvD1XXlc6
# ehYjdBVms5F9spAWjwzXg9lWQSsul7V6WB7/PIaTF4hsZ9IylRl4FnBwcJbTdjXi
# E8oA77fIHMj6jOyxEeP6WGzjDYxBnLKyV/lVqk7WkqkxggLIMIICxAIBATAnMBMx
# ETAPBgNVBAMMCGFrb3R1IENBAhBhg/J9QEELqkT+sB86yVc7MAkGBSsOAwIaBQCg
# eDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEE
# AYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJ
# BDEWBBTAMVsoP5rJc23bal1hsONcnaJpojANBgkqhkiG9w0BAQEFAASCAgBT+XEW
# qdFccim30Rsnv0g1imaw/ZyGXZ2VI/oEjVKjrDge5Li3lIVhIBhziIZapNOf6beq
# +vKMyNOM13rXv/1bGB4VUv2kgMWCOEhYLL7Ylc3YuXCoAsf4RQgJKkMBYEK3UxUG
# fOyDZ0PdwhWCyHSrsqm9na/aCxQvShgOv7qa7lftk3B2lYHCBpvSSvF2cnbYVxGq
# wZ54NcIusRD1DuUGYirtmCKZRubRrW3DSz6N4uOBBGZRY4Q4fQlPySLjh+GgrCRt
# zXX2mX/mj2L0QTTv+cFUVgGG/j4P6UzpfxT8a2/BXkw9wQXiutA/Ywfi9egJY19O
# BvPLfHPwfz0RInpKiW796REd/Op0x4lUdtHHt31QG5hE9vhEjcukD5h8fxiClAW5
# jqpNB9n3mUfuLf+iuUAz31YfUBU8QxZT5hPYLNIRvKRSu8R2mK2d/MDZytkgwHal
# eDdkxSiom2BmpdSEnHr2C2Sgojx/zaabXqOY+DBOEY+hy90j9kRkaC9V9V4nW9u7
# CM1h7hz+epCGlkYx2t+Qm5aWwU1tmCUT0HNJx2DwQvBLozNO1EDZOh+lZ9RosOsn
# hMGue4+YweCV5d7BRJv/I+I8NYC8G6DNHyBhrS4s+fiFVTrqGxEqtXbp3HyYGqmy
# /GaAJAsMPigWTcVXOw1Hk+YX78aEn9VwUem24A==
# SIG # End signature block
