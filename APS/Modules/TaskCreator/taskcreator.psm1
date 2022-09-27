<#
.SYNOPSIS
Registers a scheduled task definition on a local computer.
.DESCRIPTION
The ``New-APSTask`` cmdlet registers a scheduled task definition on a local computer. This task executes PowerShell commands at the specified time.
.PARAMETER Command
Specifies the commands to be executed.
.PARAMETER StartTime
Defines the execution time of the commands given in the ``-Command`` parameter.
.PARAMETER TaskName
Specifies the name of the task. By default APS Task (<cmdlet>).
.PARAMETER WindowStyle
Set the window style for the session. Valid values are Normal, Minimized, Maximized and Hidden. Default Hidden.
.PARAMETER Save
Specifies whether the task after execution is to be kept in the task schedule.
.EXAMPLE
New-APSTask -Command '[console]::beep(5000,3500)' -StartTime 6:00:00 -TaskName "Alarm"
#>
function New-APSTask {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory=$true)]
        [System.String]$Command,
        [System.DateTime]$StartTime = $((Get-Date).AddSeconds(3)),
        [System.String]$TaskName = "APS Task($($Command.TrimStart('"& {').Split(" ")[0]))",
        [ValidateSet("Normal","Minimized","Maximized","Hidden")]
        [System.String]$WindowStyle = "Hidden",
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

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlLPBoNJhdNtSHL1kl83FLR6k
# CxagggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBQ/zviKPZI9dFyNjWQKg3qqtBTuLTANBgkqhkiG9w0BAQEFAASCAgC7HfPC
# XsZ3N5MX+tuOfNxLcTjJxlw16pprndFTT1DJ6NggQ0lkJs44vwJsMuW4xWGvfY4J
# ZGZcvgFu6ABuF0aHeiokexPg2YZQeWWbLWdoYVduMcZ10BxMVu4rWODqWeCiMsb1
# ilxHGEquKc+Otk6QGjJdCxpyo3HTIeLbz6as+kWsFhLEcRbbbJk3dyHW7djBS4Sm
# aY2VQZyiyAzO5r9rFIKvGlxR4TDx3U0U4wNH72BZQ5cjKAGAM0hqpvqF4PWg0t7n
# FrKpYyurbOhNngYvU821ISEnS+huU0FQ0vWtfwFAZQBCItJEGRslHaZS2yquvccV
# 3MhGDV8VxWjhgYpfiqLo4yi/MjYZAOsF+tgB8DTsqjzaJA3U3UJtWiFPmEt21tHL
# csR73tjq4velVbHK7C2avRDGz39BfjP9ISroKvVaHEyodQppMEIQMU6paJ9Fgah5
# FLZC4TdW0E+o9QBsAcX+paiHEvH7Pp7NiUPb0sn5Oifh2kpP/4ffNO3DtTpVt2hc
# d8xR768QAsTStX0fXth4M0ochVcjAorm4EHbVvzErpkXUIlnECzrnmkgmZte5Vbx
# DAHDKYO7eK+xLdcPlCTy1yiw4QP7BdTRvZysQJvoRmtnSzuK+h+JPbguaSMM3kpV
# Pao5a0Ro3S6Frj5idcF3372bqM1Dmh2F7CZsmA==
# SIG # End signature block
