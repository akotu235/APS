<#
.SYNOPSIS
Creates a new task.
.DESCRIPTION
Executes the Powershell command at the given time.
.PARAMETER Command
Enter powershell command for execution.
.PARAMETER StartTime
Specify the start time of the task.
.PARAMETER TaskName
Enter a name for the task.
.PARAMETER WindowStyle
Set the window style for the session. Valid values are Normal, Minimized, Maximized and Hidden. Default value: Hidden.
.PARAMETER Save
Keep the task in the task schedule.
.EXAMPLE
New-APSTask -Command '[console]::beep(5000,3500)' -StartTime 6:00:00 -TaskName "Alarm"
#>
function New-APSTask {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory=$true, ValuefromPipeline=$true)]
        [string]$Command,
        [System.DateTime]$StartTime = $((Get-Date).AddSeconds(3)),
        [string]$TaskName = "APS Task($($Command.TrimStart('"& {').Split(" ")[0]))",
        [ValidateSet(“Normal","Minimized","Maximized","Hidden")]
        [string]$WindowStyle = "Hidden",
        [switch]$Save
    )
    $Command = " & { $Command }"
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument " -WindowStyle $WindowStyle -command $Command"
    $triger = New-ScheduledTaskTrigger -Once -At $StartTime
    $options = New-ScheduledTaskSettingsSet -Hidden -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries
    if($Save) { $taskPath = "\APS\" }
    else { $taskPath = "\APS\Temp\" }
    $i = 0
    $iTaskName = $TaskName
    while($null -ne (Get-ScheduledTask -TaskName "$iTaskName" -TaskPath $taskPath -ErrorAction Ignore )){
        $i++
        $iTaskName = "$TaskName($i)"
    }
    Register-ScheduledTask -TaskName $iTaskName -Action $action -Settings $options -Trigger $triger -TaskPath $taskPath >> $null
    #remove temporary tasks
    $APSTempTasks = Get-ScheduledTask -TaskPath "\APS\Temp\" -ErrorAction Ignore
    if($APSTempTasks){
        foreach($task in $APSTempTasks) {
            $taskInfo = $task | Get-ScheduledTaskInfo
            if($taskInfo.NextRunTime -lt (Get-Date) -and $task.TaskName -notlike $iTaskName){
                $task | Unregister-ScheduledTask -Confirm:$false
            }
        }
    }
}