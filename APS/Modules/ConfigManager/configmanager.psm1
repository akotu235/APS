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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUcK6Q9ZU4Dkoi8J3R0+UgrFfB
# riugggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBQTCXBQjS2eqMIRS65nrs/5uoY4wzANBgkqhkiG9w0BAQEFAASCAgB4s0YW
# Tsdx0BVVgeserzCT70kW9SfpysUTiQkPiAxR2g2YgWtR5lfqZJ8iSAmoJHe3JYCk
# +Z7swrIgsHG2KilciTSpF9SXtq7GWOF5LBmJqhKLbsXesOKjRe+oHxXbianwkl6q
# IB9HLOmngjXOdVVPT24v+9DGNjA4QsMlLW6TQ2hNNJ24JUMD6iSnSlbnPz6wOJBj
# TilXbd8qOLU9T7qWaLtKuCqJe/AfyQriiew65vAqk8z1z3Wa4i+omGVhWeMkqpwf
# BKic5Cj2l1CFufLffm7a05A02MRYOuSq3spfBedUcwbDjfO9S4/GVC4Cwi5oz75u
# jBDg5ebbW1z6U89jIbCeLzzjtEOFNG4AI/PTeDQmKky1o5QkVHbRkh9oCw3SPSJp
# 5zmPk7D2MrPubj2OJ7SX+uylzPbCLHzQu0nC9JUaX7Nr/jBrgce2coI5pb/qETbh
# xe/gCqlhRqphEo1/LQMtNyj0UmfpIGrl0JSb4NU2yu2ZWxr2So+QqSyhMYyyrprl
# huXh+xcJqoYQYaOIUemAB62d2I95JaHqwTiMnSQMDS4HINIU+31HKi3cyUny/r5A
# ZSBi2g02j0yn4kBOlGde33wHVJcWR8faynlsOw73zFMv5OpOeCYrXl/Akrd0ZUqp
# xMdnHBFEvcAW60r818PzuhIAd9pxwpTcwUfHhA==
# SIG # End signature block
