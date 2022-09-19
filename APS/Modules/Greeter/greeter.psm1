<#
.SYNOPSIS
Displays greeting information.
.DESCRIPTION
Displays information selected in a configuration file.
.EXAMPLE
Show-APSGreeting
#>
function Show-APSGreeting{
    if(-not ($Config = Get-Config $PSScriptRoot)){
        $Config = Set-APSGreeting -Default
    }
    if($Config.EnableAPSGreeting){
        if($Config.Clear){
            Clear-Host
        }
        if($Config.APSLogo){
            Write-Host "    _     ___   ___ `n   /_\   | _ \ / __|`n  / _ \  |  _/ \__ \`n /_/ \_\ |_|   |___/v.$((Import-Clixml "$PSScriptRoot\..\..\PSGetModuleInfo.xml").Version)`n"
        }
        if($Config.Date){
            Write-Host "Hi! It is $(Get-Date -Format g)"
        }
        if($Config.Weather){
            Write-Host $(Get-Weather)
        }
        if($Config.UserName){
            Write-Host "You are working as " -NoNewline
            if(Test-Admin){
                Write-Host "$env:UserName" -ForegroundColor Red
            }
            else{
                Write-Host "$env:UserName"
            }
        }
        Write-Host ""
    }
}

<#
.SYNOPSIS
Saves in the configuration file which information is to be displayed using the ``Show-APSGreeting`` function.
.DESCRIPTION
The ``Set-APSGreeting`` cmdlet running without parameters will help the user select the items to display.
.PARAMETER Default
Restores the default settings.
.PARAMETER Disable
Disables ``Show-APSGreeting`` functions.
.EXAMPLE
Set-APSGreeting
#>
function Set-APSGreeting{
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName="NoParameter")]
    param(
        [Parameter(ParameterSetName='Default')]
        [switch]$Default,
        [Parameter(ParameterSetName='Disable')]
        [switch]$Disable
    )
    if($Default){
        $Config = New-Object PSObject -Property @{
            EnableAPSGreeting = $true
            Clear = $true
            APSLogo = $true
            Date = $true
            UserName = $true
            Weather = $true
        }
        return (Save-Config $PSScriptRoot $Config)
    }
    elseif($Disable){
        Set-ConfigField $PSScriptRoot "EnableAPSGreeting" $false
    }
    else{
        $clear = Read-Host "Do you want to clear the screen?(yes)"
        $logo = Read-Host "Do you want to see the APS logo?(yes)"
        $date = Read-Host "Do you want to see the date and time?(yes)"
        $username = Read-Host "Do you want to see the username?(yes)"
        $weather = Read-Host "Do you want to see the weather?(yes)"
        $Config = New-Object PSObject -Property @{
            EnableAPSGreeting = $true
            Clear = $($clear.ToLower() -notlike "n*")
            APSLogo = $($logo.ToLower() -notlike "n*")
            Date = $($date.ToLower() -notlike "n*")
            UserName = $($username.ToLower() -notlike "n*")
            Weather = $($weather.ToLower() -notlike "n*")
        }
        Save-Config $PSScriptRoot $Config
    }
}