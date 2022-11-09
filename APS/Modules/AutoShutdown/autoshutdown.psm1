<#
.SYNOPSIS
Stops (shuts down) local computer at a specified time.
.DESCRIPTION
The ``Stop-ComputerLater`` cmdlet shuts down the local computer after two hours by default. You can use the parameters of Stop-ComputerLater to specify the shutdown time or cancel a scheduled shutdown. A minute before the computer is stopped, a notification will be displayed.
.PARAMETER Minutes
Specifies the time in minutes until the computer stops. Default 120 minutes.
.PARAMETER Cancel
Cancels a scheduled computer shutdown.
.PARAMETER ShutdownNow
Shuts down the computer now.
.PARAMETER ShutdownInMinute
Shuts down the computer in a minue.
.EXAMPLE
Stop-ComputrLater
.EXAMPLE
Stop-ComputerLater -Minutes 23
.EXAMPLE
Stop-ComputrLater -Cancel
#>
function Stop-ComputerLater{
    [OutputType([Windows.UI.Notifications.ToastNotificationManager])]
    [CmdletBinding(SupportsShouldProcess, HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/AutoShutdown/Stop-ComputerLater.md", DefaultParameterSetName="Default")]
    Param(
        [Parameter(ParameterSetName='Default', Position=0)]
        [System.String]$Minutes = 120,
        [Parameter(ParameterSetName='Cancle')]
        [switch]$Cancel,
        [Parameter(ParameterSetName='ShutdownNow')]
        [switch]$ShutdownNow,
        [Parameter(ParameterSetName='ShutdownInMinute')]
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

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTxoNHfn1NIqjVlNe4tfjQ75m
# fUagggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBR2NcxGiPDmAOCyiQ6BIksIXTz3nDANBgkqhkiG9w0BAQEFAASCAgCeikof
# PmdGhkHnwJWAtYG76RZlXpYWqChJBJbZqlrh7ZYWdSVoSpuEyaoSp94upb6NtsEr
# uogQDdX9H4UerMLs0TIMGOYfrT3myXsUHaBukI1N1WaFkp2DgbPJxXj5Fpc9uhz5
# aRRJB0L7c6+0MJlgCd480gFuVLY1ax1LuuyHccb59pGSy9WjHpfTCahbx38ar5tK
# zW0YahKik2XLfjH56Spb/Gj8ZhAcwLdiF7YyJxA4wJWBWxFL7qUeYDigMsYZTbL9
# fqiftH7XBPTgAIQNW+s2uo6watUX7FzUM31d62TWp7p7+jh/MX9qWkWX183ilChP
# rCHytA6VDEpRcxga1RAzZlQuKuDopw9nj3ZXHirSuOCAeeTG3OGVC5LgwsnZPGVa
# SobLgQtHPuoL0zTdG4oxpapyBL/9eBxYZiZfVUTjpOPWTUPEs8P7w2UglJBT+r0l
# DLdjrSM88jIYGFzWh3ED2ZL8wuuOcK1LFr/FcIxaUN9Kj8sHH5MFy4GZCmDY7fH2
# TALUFIHTjtzY97BGnsroIaiMjYshDiY47iTf9zQaoQVjyyq/0qUK/b4PTJhKMOO3
# SDlMv5Z7pDOeKhKaYFE9AW1uJ8O+zNvNDnCZU36WrJV61iiY49EkEMS9ZGFLwVNm
# qlUkWOw+3P20TrVRWvV0+r/anJliOsf70XMQuw==
# SIG # End signature block
