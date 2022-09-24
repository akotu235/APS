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
        [Parameter(Mandatory=$true, ValuefromPipeline=$true)]
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfvSv7KNdLkRT5VJowZzUCVz6
# DtOgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBSPW/dJnLmJRiByPWLiQaBNcaPmETANBgkqhkiG9w0BAQEFAASCAgBP13qh
# W5fZnM2U+T491td4/gnE/8vhMPObo7jcs7pBdUsJED8dvOe7gkwF4OKqiGe2/P4i
# 0C7X8m8crTjvyUE6RX3Frg/Ii17V7/UI7mu0WstxasEDs6dLuEm4g8lbYIstSP4n
# P/s+QNy4e8pPrXDIurd8xvgixvfDfibmmmjfYiQaQ8JI7OQXTBTfCuYQEzCSKHE1
# rNjmeaTw2e+OeeycakNqJ5Mt/1RVe7iB3cbFsKRT2ump+S95VuWixkCo1h20XA2A
# fSj1UJqNGdfOe8YKU/jdNT1ZUClwqkWuXrc878WnUF60LTjQgFwiWJDRJ7t7RznZ
# KctbFhap60RBC8lBX3pPYhYyYdl8EzkCiIwXqiYdggFCRrKjWAYXFutfTNMH+vUR
# 09FPjOjjRTnFOtGBb8tta7mfXerJ6dEM3KjMoTEydhH4k09Y5Iivt3LqtoMnIZ8N
# StkhniK9zm3kozSsiphwrE2d+ApBSiy0IIFZOReWJ7mWba3bozdEJbqkIMPyRKxy
# 7BHq/oHFpWV/S25eCjtuGuuIweiuUkyELvZ1ey1B1m/R7MI2qau6HJzX6N4DT358
# qPNrzP6PxIONGQBqUrThNtfwxaKqH/Z9wTPQqmt/o7ooQEAvGHkeQ6w5ax2UE2z2
# Dhi86o7JweOUkZEVRP7T80Ow95/StJxsxEeW+g==
# SIG # End signature block
