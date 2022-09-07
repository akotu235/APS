function Set-Notification{
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory=$true, ValuefromPipeline=$true)]
        [string]$Text,
        [System.DateTime]$Time = $((Get-Date).AddSeconds(3)),
        [switch]$OnlyVoiceNotification = $false,
        [switch]$VoiceNotification = $true,
        [string]$Title,
        [switch]$Save
    )
    $Command = "Show-Notification -Text `'$Text`' -OnlyVoiceNotification:`$$OnlyVoiceNotification -VoiceNotification:`$$VoiceNotification $Title"
    New-APSTask -Command $Command -StartTime $Time -TaskName "APS notification" -Save:$Save
}

function Show-Notification{
    [OutputType([Windows.UI.Notifications.ToastNotificationManager])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValuefromPipeline=$true)]
        [string]$Text,
        [switch]$OnlyVoiceNotification,
        [switch]$VoiceNotification = $true,
        [string]$Title
    )
    if(!$OnlyVoiceNotification){
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
    if($VoiceNotification){
        Use-Speech -TextToSay $Text
    }
}