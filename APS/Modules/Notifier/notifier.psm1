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





# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqKeGgjXiilkYSCEn91VF9LLi
# eGCgggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
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
# CQQxFgQU/UZW+M9dLT56hlQqSP0TCGx212owDQYJKoZIhvcNAQEBBQAEggEAZPUI
# TpcbfVD7WOTCP2cSsfBA4uPScn6NkayJNfxG0w/BJsnFV9c2lP9/o4+fmhfyNL/7
# ccMRYrmx6aS6AoWVy2M9/12Naw0TGkSRRedsKLx9iLvXRC1SKwaJWRtjhZUqnhm4
# oygTZ8dZOZMBwKI0dpPrMLQhY5HAlUgRU/pFZE6jX1ToeDDpqnsSoLiwCUUbbFcp
# +NR5buq7Gg7LwC3dvB4sRYEDkeChdmRHjElDkR0OunA+yFGS/Zknzy2LHxvJwf+h
# GNS2oUoylqVZJUI4F/Su8wLcry+DI3AI0oI0NoUHP9gL0N6Qisb/bR7TKk58f9kZ
# jx/wNEqD3/7qsgYdaw==
# SIG # End signature block
