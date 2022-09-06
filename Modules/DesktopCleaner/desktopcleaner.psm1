<#
.SYNOPSIS
Cleans the desktop.
.DESCRIPTION
Moves files to the desktop archive.
.PARAMETER Autorun
Always run when user logs on.
.PARAMETER Disable
Disable autorun.
.PARAMETER Skip
Skip cleaning.
.PARAMETER ExceptionList
Opens the exception list in a txt file.
.PARAMETER AddException
Adds the exception specified in the parameter to the list.
.PARAMETER SetDefaultExceptionList
Restores the default exception list.
.PARAMETER SaveCurrentDesktopState
Saves the desktop state to the exceptions list.
.PARAMETER Archives
Opens the desktop archive in the file explorer.
.EXAMPLE
Clear-Desktop
.EXAMPLE
Clear-Desktop -Autorun
.EXAMPLE
Clear-Desktop -Disable
.EXAMPLE
Clear-Desktop -Autorun -Skip
.EXAMPLE
Clear-Desktop -ExceptionList
.EXAMPLE
Clear-Desktop -AddException "filename"
.EXAMPLE
Clear-Desktop -SetDefaultExceptionList
#>
function Clear-Desktop{
    [CmdletBinding()]
    Param(
    [switch]$Autorun,
    [switch]$Disable,
    [switch]$Skip,
    [switch]$ExceptionList,
    [switch]$SaveCurrentDesktopState,
    [switch]$SetDefaultExceptionList,
    [switch]$Archives,
    [string]$AddException
    )
    $ExceptionsFile = $PSScriptRoot + "\exceptions.txt"
    $ArchivesDir ="$HOME\Archiwum pulpitu\"
    if($ExceptionList){
        $Skip=$true
        Write-Verbose "The exception list has been opened with a notepad."
        Start-Process notepad $ExceptionsFile
    }
    if($SaveCurrentDesktopState){
        $Skip=$true
        $Src = Get-ChildItem ~\Desktop
        Write-Verbose "The contents of the desktop have been read."
        Set-Content $ExceptionsFile "desktop.ini`r`ndesktop_backup.ini"
        Write-Verbose "The contents of the Exceptions File have been removed."
        foreach($file in $Src){
            Add-Content $ExceptionsFile $file
            Write-Verbose "Exception `"$file`" added to the list."
        }
        Write-Verbose "New exception list has been created."
    }
    if($SetDefaultExceptionList){
        $Skip=$true
        Set-Content $ExceptionsFile "desktop.ini`r`ndesktop_backup.ini`r`nTODO.txt`r`ntemp"
        Write-Verbose "Default file list has been restored."
    }
    if($AddException){
        $Skip=$true
        Add-Content $ExceptionsFile $AddException
        Write-Verbose "Exception `"$AddException`" added to the list."
    }
    if($Archives){
        $Skip=$true
        explorer.exe $($ArchivesDir)
        Write-Verbose "The desktop archive has been opened in the file explorer."
    }
    if($Autorun){
        $Disable=$false
        $action=New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoLogo -NonInteractive -WindowStyle Hidden -command Clear-Desktop"
        $options=New-ScheduledTaskSettingsSet -Hidden
        $triger=New-ScheduledTaskTrigger -User $env:UserName -AtLogOn
        $task=Get-ScheduledTaskInfo -TaskName "Clear-Desktop" -ErrorAction Ignore
        if(!($task)){
            Register-ScheduledTask -TaskName "Clear-Desktop" -Settings $options -Trigger $triger -Action $action –Force >> $null
            Write-Verbose "Created Scheduled Task."
        }
        else{
            Write-Output "Autostart was already on."
        }
    }
    if($Disable){
        $Skip=$true
        $task=Get-ScheduledTaskInfo -TaskName "Clear-Desktop" -ErrorAction Ignore
        if($task){
            Unregister-ScheduledTask -TaskName "Clear-Desktop"
            Write-Verbose "Removed from autostart."
        }
        else{
            Write-Output "Autostart was already turned off."
        }
    }
    if(!$Skip){
        $Src = Get-ChildItem ~\Desktop
        Write-Verbose "The contents of the desktop have been read."
        $DestPath = $ArchivesDir + (get-date).toString('MM.yyyy')
        if(!(Test-Path -Path $ArchivesDir)){
            mkdir $ArchivesDir >> $null
            Write-Verbose "Created path: $ArchivesDir."
        }
        if(!(Test-Path $DestPath)){
            mkdir $DestPath >> $null
            Write-Verbose "Created path: $DestPath."
        }
         if(!(Test-Path $ExceptionsFile)){
            Clear-Desktop -SetDefaultExceptionList
        }
        $exceptions = Get-Content $ExceptionsFile
        foreach($file in $Src){
            $filename = $file.Name
            $filebase = $file.BaseName
            $fileext = $file.Extension
            $filenameNU = $filename
            if($exceptions.Contains($file.Name)){
                Write-Verbose "Kept file: $file."
            }
            else{
                if(Test-Path $DestPath\$file){
                    $n = 1
                    while (Test-Path $DestPath\$filenameNU){
                        $filenameNU = $filebase + " (" + ++$n + ")" + $fileext
                    }
                    Write-Verbose "File name changed! $filenameNU"
                }
                Move-Item $file.FullName (Join-Path $DestPath $filenameNU)
                Write-Verbose "Moved the file: $filenameNU."
            }
        }
        Write-Verbose "Cleaning complete."
    }
}

# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFSg0bJ1Yo2DO55U8lPzEunNo
# EZygggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
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
# CQQxFgQUsYqZ3aoItFfaDm9VfpyBKUCoR0QwDQYJKoZIhvcNAQEBBQAEggEAiB02
# OfqoBSm2fJHuQJAuIFu0dT22PzZloUzBSRtuHJ+EoZS7PQwbkXbmo5fAB2b59MMH
# cfXKEuHysXmsSVDp3jQcznLLfxh78UDNqwyohMOebvxUyrcbaeh4FcYr7X0bGCRK
# AWgpiLTNT7Mwgzad7/6dChF3GSwjp1M4HGbDPPAYx0zxF2ESqbNY6t/sjw/iobvB
# mz7uroEOUoq8On0UGnIMtHtbGQN1iokKplU4NgfPOi3Af22daHMcyUvaCP2GuG9o
# JYPJQB15eyCVtST2k5aTkZmhAVMZUFICJxmDwupxtHy7sBkUt/cicAIRmkTpIJtF
# e6SYeh62JxUxmTJq4A==
# SIG # End signature block
