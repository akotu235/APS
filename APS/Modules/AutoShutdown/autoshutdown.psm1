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
.PARAMETER ShutdownInMinute
Shuts down the computer in minue.
.EXAMPLE
Stop-ComputrLater
.EXAMPLE
Stop-ComputerLater -Minutes 23
.EXAMPLE
Stop-ComputrLater -Cancel
#>
function Stop-ComputerLater{
    [OutputType([Windows.UI.Notifications.ToastNotificationManager])]
    [CmdletBinding(SupportsShouldProcess)]
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
            Write-Output "Scheduled task does not exist."
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
            ($RawXml.toast.visual.binding.text|Where-Object {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
            ($RawXml.toast.visual.binding.text|Where-Object {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null
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
            Write-Output "Computer will shutdown at $('{0:HH:mm:ss}' -f $t)"
        }
    }
}
Set-Alias -Name "spcl" -Value Stop-ComputerLater