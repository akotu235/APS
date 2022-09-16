<#
.SYNOPSIS
Sets a notification.
.DESCRIPTION
Sets a notification at a specific time. By default, the notification is made both by voice and in the form of a pop-up toast.
.PARAMETER Text
Specifies the content of the notification. This content will be spoken when the voice prompts are not disabled.
.PARAMETER Time
Defines the time the message appears. If not set, the notification will show after 3 seconds.
.PARAMETER OnlyVoiceNotification
It turns off the toast pop-up, leaving voice prompts.
.PARAMETER VoiceNotification
Determines whether the voice prompts are to be enabled. Enabled by default.
.PARAMETER Title
Specifies the title of the notification. It is not spoken but visible on the pop-up toste.
.PARAMETER Save
Saves the task in the task schedule. By default they are removed after execution.
.EXAMPLE
Set-Notification "Go to sleep!" -Time 23:30
#>
function Set-Notification{
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName='Default')]
    Param(
        [Parameter(Mandatory=$true, ValuefromPipeline=$true, Position=0)]
        [System.String]$Text,
        [System.DateTime]$Time = $((Get-Date).AddSeconds(3)),
        [Parameter(ParameterSetName='OnlyVoiceNotification')]
        [switch]$OnlyVoiceNotification,
        [Parameter(ParameterSetName='VoiceNotification')]
        [switch]$VoiceNotification=$true,
        [System.String]$Title,
        [switch]$Save
    )
    if($OnlyVoiceNotification){
         $Command = "Show-Notification -Text `'$Text`' -OnlyVoiceNotification:`$$true"
    }
    else{
        $Command = "Show-Notification -Text `'$Text`' -VoiceNotification:`$$VoiceNotification"
    }
    if($Title){
        $Command += " -Title $Title"
    }
    New-APSTask -Command $Command -StartTime $Time -TaskName "APS notification" -Save:$Save
}

<#
.SYNOPSIS
Shows the notification.
.DESCRIPTION
Immediately shows the notification without saving to the schedule of tasks. It can be called when an event occurs.
.PARAMETER Text
Specifies the content of the notification. This content will be spoken when the voice prompts are not disabled.
.PARAMETER OnlyVoiceNotification
It turns off the toast pop-up, leaving voice prompts.
.PARAMETER VoiceNotification
Determines whether the voice prompts are to be enabled. Disabled by default.
.PARAMETER Title
Specifies the title of the notification. It is not spoken but visible on the pop-up toste.
.EXAMPLE
Show-Notification -Text "Text" -Title "Title"
#>
function Show-Notification{
    [OutputType([Windows.UI.Notifications.ToastNotificationManager])]
    [CmdletBinding(DefaultParameterSetName='Default')]
    Param(
        [Parameter(Mandatory=$true, ValuefromPipeline=$true, Position=0)]
        [System.String]$Text,
        [System.String]$Title,
        [Parameter(ParameterSetName='OnlyVoiceNotification')]
        [switch]$OnlyVoiceNotification,
        [Parameter(ParameterSetName='VoiceNotification')]
        [switch]$VoiceNotification
    )
    if(-not $OnlyVoiceNotification){
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
        $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
        $RawXml = [xml] $Template.GetXml()
        ($RawXml.toast.visual.binding.text|Where-Object {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($Title)) > $null
        ($RawXml.toast.visual.binding.text|Where-Object {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($Text)) > $null
        $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $SerializedXml.LoadXml($RawXml.OuterXml)
        $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
        $Toast.Tag = "APS"
        $Toast.Group = "APS"
        $Toast.ExpirationTime = [DateTimeOffset]::Now.AddHours(12)
        $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("APS Notifier")
        $Notifier.Show($Toast)
    }
    if($VoiceNotification -or $OnlyVoiceNotification){
        Use-Speech $Text
    }
}