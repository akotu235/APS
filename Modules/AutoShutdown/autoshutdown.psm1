<#
.SYNOPSIS
Shuts down the computer.
.DESCRIPTION
Shuts down the computer after 2 hours or after the time specified in the parameters.
.PARAMETER Minutes
Enter the number of minutes until system shutdown.
.PARAMETER Cancel
Cancel current shutdown.
.PARAMETER ShutdownNow
Shuts down the computer now.
.PARAMETER ShutdownNow
Shuts down the computer in minue.
.EXAMPLE
Stop-ComputrLater
.EXAMPLE
Stop-ComputerLater -Minutes 23
.EXAMPLE
Stop-ComputrLater -Cancel
#>
function Stop-ComputerLater{
    [CmdletBinding()] 
    Param(
        [string]$Minutes = 120,
        [switch]$Cancel,
        [switch]$ShutdownNow,
        [switch]$ShutdownInMinute

    )
    if($Minutes -eq 0){
        $ShutdownNow = $true
    }
    elseif($Minutes -eq 1){
        $ShutdownInMinute = $true
    }

    if($Cancel){
        if(Get-ScheduledTaskInfo -TaskName "Stop-Computer" -ErrorAction Ignore){
                Unregister-ScheduledTask -TaskName "Stop-Computer" -Confirm:$false
        }
        else{
            Write-Host "Scheduled task does not exist."
        }
    }
    else{
        if($ShutdownNow){
            if(Get-ScheduledTaskInfo -TaskName "Stop-Computer" -ErrorAction Ignore){
                Unregister-ScheduledTask -TaskName "Stop-Computer" -Confirm:$false
            }
            Stop-Computer -Force
            Write-Verbose "There is nothing to collect."
        }
        elseif($ShutdownInMinute){
            if(Get-ScheduledTaskInfo -TaskName "Stop-Computer" -ErrorAction Ignore){
                Unregister-ScheduledTask -TaskName "Stop-Computer" -Confirm:$false
            }

            $t=(Get-Date).AddMinutes(1)
            $action=New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -command Stop-ComputerLater -ShutdownNow"
            $triger=New-ScheduledTaskTrigger -Once -At $t
            $options=New-ScheduledTaskSettingsSet -Hidden -DontStopIfGoingOnBatteries
            Register-ScheduledTask -TaskName "Stop-Computer" -Action $action -Settings $options -Trigger $triger >> $null

            $ToastTitle = "Autoshutdown"
            $ToastText = "The computer will shut down in less than a minute"

            [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
            $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

            $RawXml = [xml] $Template.GetXml()
            ($RawXml.toast.visual.binding.text|where {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
            ($RawXml.toast.visual.binding.text|where {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

            $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
            $SerializedXml.LoadXml($RawXml.OuterXml)

            $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
            $Toast.Tag = "shutdown"
            $Toast.Group = "shutdown"
            $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

            $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("APS")
            $Notifier.Show($Toast);
        }
        else{
            $t=(Get-Date).AddMinutes($Minutes)
            $action=New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -command Stop-ComputerLater -ShutdownInMinute"
            $triger=New-ScheduledTaskTrigger -Once -At $t.AddMinutes(-1)
            $options=New-ScheduledTaskSettingsSet -Hidden -DontStopIfGoingOnBatteries
            if(!(Get-ScheduledTaskInfo -TaskName "Stop-Computer" -ErrorAction Ignore)){
                Register-ScheduledTask -TaskName "Stop-Computer" -Action $action -Settings $options -Trigger $triger >> $null
            }
            else{
                Set-ScheduledTask -TaskName "Stop-Computer" -Trigger $triger >> $null
            }
            Write-Host "Computer will shutdown at $('{0:HH:mm:ss}' -f $t)"
        }
    }
}

Set-Alias -Name "spcl" -Value Stop-ComputerLater
# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTnRew7JNb7WehJHlXRRa8WNQ
# 0pygggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
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
# CQQxFgQU2MmMIPiH+W+PaOk67VHqh6c/BPYwDQYJKoZIhvcNAQEBBQAEggEAUo0t
# vVWK+puSMhPfzZpBvjFBEdMGHwko08GRIpQgPCKrZNnjNAj28a571cJdTxoaKkuC
# v9xmH6Y22N1i0/rvL10yZ0W0OZN3EIgicB/CtbpzjlvHrRW3ZZ1E/5lDJ1oxikA3
# ecZMm8NzYA9cvbN2cT2IFlekDNuQX3m5b2FBju1WC3nQtAJWl6zW7IqpmNzvMT5j
# aBjxpXjlJBMuySGwXalcUSwiaSOVBIMy9DvNBQ9vnSuh1EIQD2rk64LIGJFXY4cs
# 3AdbdB38UWhsDRlHmNC1NGV92Q3fBcdEr65Dpm8cMsacEHcRKKdgE7S9zweAP8a5
# mJxp8EA8PmJBkCCsyA==
# SIG # End signature block
