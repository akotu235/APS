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
        [Parameter(Position=1)]
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
    if($VoiceNotification -or $OnlyVoiceNotification){
        Use-Speech $Text
    }
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
}

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPpWvOpcLm3C40/kQD4RWZoHt
# A7qgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBSMhWbrLbfRB+56lbMLmXAvVgSFJzANBgkqhkiG9w0BAQEFAASCAgAjNg5h
# CChQ9csePl/bahpgRTSHlpBDmNuXZyXrGROV+FNPDglOVb6tuCdqGOZF05nBRZ2k
# bhLdZYXCod6nWcaFrb9NWfEBb4rfpnmR5kfwuCqSwd6sTb/4hwXcuAjS0sQvYr3B
# PTE680eQEFEuP5rfHkOUdxLWyBgp/0beds3Uq9sDM1mMHhIIO+zzaoEXfqZaANOx
# nIfFhFxDZwxZ/kdJI20PXc4yCAjV1sTQAdQ4tZC93zB/IZuw8+EKWNS1zN4V7ezX
# IlvHHldWPOXBA6J6/u9DW2DoozuIlqY3jvjfubxgrx173QMH1l95VrXYKgnytka2
# 74sbcVBYV/qis3GRqB+jiLq2IXpV4YAKZ6+56B+ivSzT94dcZBOhgsLbLWpJaMlw
# 3boFH4PcTmD/qvY6bkAxWz871YL9JQE4ScgM0R7a4z3DUQRfG7b46i4HgfIbnSwY
# 9ENyMyn20dn5GFAXZV/gUDXAziUPwQWBpmhrLdaRUrFbFo8ACYIM1h4LP0WLqzkr
# 0lGmulicAVzcfBGNIT9E+02CvWN8t9OVVjKxOxO00AvDK3qWd5wTUZcsY9OGl0O6
# lp7EHeKQV0qxTRAAuXkXLT6Sp/i4mziXVbGud23MsJSnNpqnAkfnlYt2LR9Pcts2
# gB5w6AE/i3Q5KkTkLf+RG/7KrWzFmCw6eJdL8g==
# SIG # End signature block
