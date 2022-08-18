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
    [CmdletBinding()]
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
    [CmdletBinding()]
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
        $ConfigPath = "$ModuleBase\..\..\Configuration\$FileName"     
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
# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUs1nm9uRU8LhFVB7zReesCJ/l
# vbGgggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
# AQsFADAeMRwwGgYDVQQDDBNQb3dlclNoZWxsIGFrb3R1IENBMB4XDTIyMDIwMTEz
# MDExMloXDTI3MDIwMTEzMTExM1owHjEcMBoGA1UEAwwTUG93ZXJTaGVsbCBha290
# dSBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ5Jah2xqCyY33yT
# xhz7JjIQofP86RYwn5arpiQfKz87xvKTzOcVm9Pf3jrpKkcUnGL7PKqGDAX6HL5r
# GQ7/2RPlnH7cSYIM9vYYmR7vgUUgQACsYVOO5UcrlDT9ga387gd7YInmSn/icot3
# b2gvCf1Ok3OT05d8Vu4PzzYXNRvc6pIgnQ++ENakvB6LLSoso3OuZZoFhHpufD0/
# 8ac21gw9ZeweFtQzy8BAkMbPCSSymiYduLPF4XEb1vo2w3fHDl/LYCfrJWOHTELS
# IjpRLJQYbJnewBZ1x6jXRB0dTbUrO3C5UPoKXYPMIMi5Slvk1XPDHeXLOXAb4ZTO
# EHV325kCAwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUF
# BwMDMB0GA1UdDgQWBBR1hk5NfI7NaI/MFxkS4z6wB5uaszANBgkqhkiG9w0BAQsF
# AAOCAQEABoUXCtmgDOiK6QjrzONCSE+7NbYrwzPonxGY0PNvmxf5Y6CcCK0Nga8v
# ImAZM9cXAGOUZE0wZQUODHW4OxbW1kgzS4OvOQZZUeSPNG7OLxttYkF5+5Pfs8RY
# AxkI0XYP3JId4Fx5E8ByMGx7wOpyVcLOCU+DEpEf21tHa4xQ5RGeKTcE7hRROLpg
# g50DeoiSAeAmAH2K2l2uCPb+fP+MeEFH9THGPYJbWozU9Zq90Az3HCEn2dkPXKof
# ZfBOJt3/WwSWGtYZqf0cAooTcKlO1TrreAmh4uuslfM7F579xKqX8ou1JzRQ2n/M
# WRajsdVGAXYebpyYbjiGjNKoGzWS8DGCAdMwggHPAgEBMDIwHjEcMBoGA1UEAwwT
# UG93ZXJTaGVsbCBha290dSBDQQIQfziWHbCKBoRNGa23h81cKTAJBgUrDgMCGgUA
# oHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0B
# CQQxFgQUgIAa6k0C5FN84wEk9cgeEmehRdcwDQYJKoZIhvcNAQEBBQAEggEAQF/1
# kwyfJwyIy4cUwfvSBhPG8kV3wRL/VU3/TdAKNC5tTbLtlzqu9GU5jIhqnGeWPA5q
# zaijA+0AVK1ApT4C5EH4RTjdVpcpaWBb1gYePsM85qCvLdRxaIOPvgSO9npNtSht
# 1H59VJp/GnvOBXESvMC3zPvhGd1zrNWg1pMYnaP9OxrJzaOdIILfY8LMhurG9aR+
# wFicuQQm2OJdgPv8OvTeiw4AL/6ZhDhNfHeYonCXVicXI40mh/XnUWVJQAk6619p
# xKslNzjuCKZthATL5zDn4iGV14JdMCfMoePh/OWR3Lc8d8uKfy35ogw3yRQqkVMd
# VtNn8vyPgtpK63wqRA==
# SIG # End signature block
