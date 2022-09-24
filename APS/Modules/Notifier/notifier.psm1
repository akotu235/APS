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
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName='Default')]
    Param(
        [Parameter(Position=0)]
        [System.DateTime]$Time = $((Get-Date).AddSeconds(3)),
        [Parameter(Mandatory=$true, ValuefromPipeline=$true, Position=1)]
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
    [CmdletBinding(DefaultParameterSetName='Default')]
    Param(
        [Parameter(Mandatory=$true, ValuefromPipeline=$true, Position=0)]
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUhfdWPwOWVy+xopn1Ny8Wa4Ae
# peigggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBRSPj8Xvbr4ISPhwnCj4ZRFzNKCMDANBgkqhkiG9w0BAQEFAASCAgCloKxu
# OqVXHq3N1uVS/nblEzTcrdkhQWdmfWBicLatQ2Toly3K8dZjuQhAJ+i8EllUJ8Ib
# vZoEpqhznjnQIZUxAdUQ0iuP9h3hTQFl1PAKG4ZlUpFXXExwHBFku045ef3aQee2
# dUhe2B1WL6j+gX5Y3oprH0geQK34xe7DfNWNlc/QF1LbBxIDbrSB8/KvGGOCLGw0
# bcPutKHFur40f6bQrylwoyUYkQWJD2m/zpVAi4F1VmCoxzzRvd3EK5okMiLCBZAh
# WNzB5eTnkhJVo7xKrXNZ0vmmZEMnxDI+q2gEx6COqzcRRKgoLfqa0wQQrWXNOGXk
# ahvnS969PVQLa6fi8XTax5SeiSF1avKR7Lse/80OVWOMs4xZn5/bYxHm1/xk6vHL
# INbZE7mEF32YP11ZC+3JCHvh0fMfukO9YXbJK6DMoQb9EWPIn4pxu8TUmxP+Lwo6
# pxQOYk63nC0CDiRRBnIB461IWGPI2qoC3iO0wfcTcUQrFs/BJhervOTViWM7MnHd
# Z40EykUN2i0THnw/QkhIHrnKP+fAY0nTQxlM+rCk3VcT1MEMvNdTgvvX5goTYAuE
# OCcaYACjtCwaZwhW5LVPd2bBBFylNAdMl/dhkGp7RssniDKN8JqdsK5wmJldR0b6
# KH8SjpIxK0aGC574fOjlyONxCkCVcr896xuXDA==
# SIG # End signature block
