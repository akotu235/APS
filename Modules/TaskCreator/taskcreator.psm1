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
.EXAMPLE
New-APSTask -Command '[console]::beep(5000,3500)' -StartTime 6:00:00 -TaskName "Alarm"
#>
function New-APSTask {    
    [CmdletBinding()] 
    Param(
        [Parameter(Mandatory=$true, ValuefromPipeline=$true)]
        [string]$Command,
        [System.DateTime]$StartTime = $((Get-Date).AddSeconds(3)),
        [string]$TaskName = "APS Task($($Command.TrimStart('"& {').Split(" ")[0]))",
        [ValidateSet(“Normal","Minimized","Maximized","Hidden")] 
        [string]$WindowStyle = "Hidden"
    )
    $Command = " & { $Command }"
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument " -WindowStyle $WindowStyle -command $Command"
    $triger = New-ScheduledTaskTrigger -Once -At $StartTime
    $options = New-ScheduledTaskSettingsSet -Hidden -DontStopIfGoingOnBatteries
    $i = 0
    $iTaskName = $TaskName
    while((Get-ScheduledTask -TaskName "$iTaskName" -TaskPath "\APS\" -ErrorAction Ignore ) -ne $null){
        $i++
        $iTaskName = "$TaskName($i)"
    }
    Register-ScheduledTask -TaskName $iTaskName -Action $action -Settings $options -Trigger $triger -TaskPath "\APS\" >> $null
}




# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYB3t1oZXLHrtVpt/I+mOaSy5
# 9VmgggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
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
# CQQxFgQUK4wUNdjAiALRJvjMtZYnklq09AEwDQYJKoZIhvcNAQEBBQAEggEAhRbl
# 4ymUYptdwutFZLOef10kDwrnDMfTTqVwiSlk0rnz2cN99WiXH7masfkkYm+B12ad
# P4quE3VR98OYq7B6s/ge10baoAkVurfjoDzvRufuTUV04yb4COReo7vjpIQLk0oO
# XahGuKgWr8imdclDnz2lTrv6v+4/O0GfG6mLfSjBSEJPDxh6UbvAzF6fnc0MsJLt
# m3aRyyMl47JTDv6aRorME4OyGviBH+6S3KExq3OamnK7UfAkOhd+FQKvnTc1m0Nh
# G176vHhuJh4D/n+5ZTBQw5cSwBBJhelSHl6uuOJ3Tm/M5sFd1luaHmhTV6CkN13s
# UMCf3mhb7Mom0lEheA==
# SIG # End signature block
