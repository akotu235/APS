param(
    [switch]$Analyzer
)
$projectBase = "$PSScriptRoot\..\"
if(!$Analyzer){
    Set-ExecutionPolicy Bypass -Scope Process -Force -Confirm:$false
    Import-Module Pester
    Invoke-Pester -Output Detailed -Path "$projectBase\Tests"
}
else{
    Import-Module PSScriptAnalyzer
    Invoke-ScriptAnalyzer -Path "$projectBase\APS" -Recurse -ExcludeRule PSAvoidUsingWriteHost | Select-Object ScriptName, Line, Severity, Message | Format-Table -AutoSize -Wrap -GroupBy ScriptName -Property Severity, Line, Message
}

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCoit3EssocVik3h7TiIuCNRt
# 07CgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBTdGyaP7y3XjuhewzBnWIfRHc9GwDANBgkqhkiG9w0BAQEFAASCAgAv9+wl
# mDjvkIpyHABpdb+UNycA1BURu1b+iw0XH34eKEcRIXh81V3+yLkKLEMTM2aDRxBX
# Rcrge2b8UXRV4YNGTqVomITMOgaMHTqN75AQhuzE7kdfPUgniVPw0joFXTTzEVFn
# AUiem28KLcA7JMMTVUWQSPWb83prxj+9TEEsNU5RbHI0sxFyNlUnCdDduSuGlfnv
# uP5LkHFAIeFJz3guHELsivhdewwdObbqSUlfzOD4a/5iZIKGz/2MQcSctDyE/1JD
# yMRv0+3JI9/Okc/leCFdbRtquNQucVYgNtiVzbpQl4BLVv/hSNVFnzODkzoUEhw5
# KX6iPj3wkCJ1vpkfvgk9fiwwqMGvuabWrLtZxYBOC1ThV0yu4ghzD9vlA01zzlt+
# gClkYJz7kdkBJMPhugy+V7AjtZgoxa2n1aXOOAIXJGKYSo3japPfasGfA5nS9uo0
# bU71gAPJlfqeOqRgplVWtrH2d3EfXWghfnBEd0+XcQfQwxYPQZCqFf4dlJlY7F8V
# Hy5UX9hXFQNmpuIOVGMn0MvsdwU71TiZDQcw4751K0b6Tg6hMy+1Gb5sS1g4AmZn
# XhWptC07Sq6Mg8qBIccX7+sWo3mEp7aCKrOZ36CrySuMfuro026Vye6k+m7Rbtj+
# PTyUjmCq6OC4K7XxRC4h/ANfc/cynQEwEeWJew==
# SIG # End signature block
