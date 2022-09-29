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
.PARAMETER DisableVoiceNotification
Determines whether the voice prompts are to be disabled. Enabled by default.
.PARAMETER Title
Specifies the title of the notification. It is not spoken but visible on the pop-up toste.
.PARAMETER Save
Saves the task in the task schedule. By default they are removed after execution.
.EXAMPLE
Set-Notification 23:30 "Go to sleep!"
#>
function Set-Notification{
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName='Default', HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/Notifier/Set-Notification.md")]
    Param(
        [Parameter(Position=0)]
        [System.DateTime]$Time = $((Get-Date).AddSeconds(3)),
        [Parameter(Mandatory=$true, Position=1)]
        [System.String]$Text,
        [System.String]$Title,
        [Parameter(ParameterSetName='OnlyVoiceNotification')]
        [switch]$OnlyVoiceNotification,
        [Parameter(ParameterSetName='DisableVoiceNotification')]
        [switch]$DisableVoiceNotification,
        [switch]$Save
    )
    if($OnlyVoiceNotification){
         $Command = "Show-Notification -Text `'$Text`' -OnlyVoiceNotification"
    }
    elseif($DisableVoiceNotification){
        $Command = "Show-Notification -Text `'$Text`' -DisableVoiceNotification"
    }
    else{
        $Command = "Show-Notification -Text `'$Text`'"
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
.PARAMETER DisableVoiceNotification
Determines whether the voice prompts are to be disabled. Enabled by default.
.PARAMETER Title
Specifies the title of the notification. It is not spoken but visible on the pop-up toste.
.EXAMPLE
Show-Notification -Text "Text" -Title "Title"
#>
function Show-Notification{
    [OutputType([Windows.UI.Notifications.ToastNotificationManager])]
    [CmdletBinding(DefaultParameterSetName='Default', HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/Notifier/Show-Notification.md")]
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [System.String]$Text,
        [System.String]$Title,
        [Parameter(ParameterSetName='OnlyVoiceNotification')]
        [switch]$OnlyVoiceNotification,
        [Parameter(ParameterSetName='DisableVoiceNotification')]
        [switch]$DisableVoiceNotification
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
    if((-not $DisableVoiceNotification) -or $OnlyVoiceNotification){
        Use-Speech $Text
    }
}

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlWcsCneFHRr8P0X+YC7yZnR+
# X7ugggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBTpsXR8d1kXI8icuY/hxwztNp0vZTANBgkqhkiG9w0BAQEFAASCAgB2a3xg
# /O894pCAbDj4Q6nWjwosbTzv3C8XZhk47EAHVlzhBaIT9M+htuKqYddA0ypfLX4+
# jHyr+IDJqfuGJ/4qgVdOBYQEl9azEOGTLMkIt9piWcQSVWZzk6PEH1wkWoNrXD+m
# tFBEE5BxRU4hderR8mvIwzGHfAacyoGNCyK3dXs2oNEs+QVd8VcMCeHjS3r/TdUd
# trmWSVXaqh7nw5MQGacH72luLYO2XDCq0RlTx8M21p/mHgqZiOrKUV/gSpawX/Vg
# Y3b2UO443qRRWeIzYI6c/p0PkwE6OBJFUdwe75BivVe4vJAxU0YmWrCgteh0QVtz
# HYwCYqHkaLVB4W+tzju34xXon2D9Q/KvwmKOIEZtolcTc67pSJGjNiNXPsbel3l8
# +jkPEHA6t5eX9GLLySER+Hx2YyCHwf31LlyLBmMbWAfE/VLOQC5KFwhXtVkKqHqF
# 3UxMzWtys6OHf/KHbqx5/QNIDvQo7v1/6UK+XwYu8tpiZcis3a0z3sBuxU7V19ef
# uq6dwB8a4HfclgazQOHEOuhUbnDnCPjqUvopMkz0dhB/aUg8LDLQT3XV+PtKDBzX
# wfLW/GuZQhmnoXyLdhBn/031BOrgxGOAt6TyX5wUTrl3uZVsoDRczckpKyjT/1MP
# OEio46GINc4P5OMkaOxTHzB88/srebjnPzQx9g==
# SIG # End signature block
