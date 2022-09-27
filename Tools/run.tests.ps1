param(
    [switch]$Analyzer,
    [switch]$Detailed
)
$projectBase = "$PSScriptRoot\..\"
if(!$Analyzer){
    Set-ExecutionPolicy Bypass -Scope Process -Force -Confirm:$false
    Import-Module Pester
    if($Detailed){
        Invoke-Pester -Output Detailed -Path "$projectBase\Tests"
    }
    else{
        Invoke-Pester -Path "$projectBase\Tests"
    }
}
else{
    Import-Module PSScriptAnalyzer
    if($Detailed){
        Invoke-ScriptAnalyzer -Path "$projectBase" -Recurse -ExcludeRule PSAvoidUsingWriteHost | Select-Object ScriptName, Line, Severity, Message | Format-Table -AutoSize -Wrap -GroupBy ScriptName -Property Severity, Line, Message
    }
    else{
        Invoke-ScriptAnalyzer -Path "$projectBase\APS" -Recurse -ExcludeRule PSAvoidUsingWriteHost | Select-Object ScriptName, Line, Severity, Message | Format-Table -AutoSize -Wrap -GroupBy ScriptName -Property Severity, Line, Message
    }
}

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJhi8nz/Uu2FsD0OL5946xHIf
# m7CgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBQKgEaCq+1cb45xy6KSMlOpQPD7ljANBgkqhkiG9w0BAQEFAASCAgAFUPuM
# +8HN4f4He7kqjPAUXG09dhJ4P6N0KiCm6iOqvN3YmHDG82/XfEi7CazSgYN7PWCE
# iOkSoPAE9IJ9LJE/145b1ErPtggHYEAbRdb1vXvdQ2EdOh3gPHGNzhLSd5H6wvPH
# U8XO7L8d8FIOTDfWBLSFF/uxET+rTuxwqP6Q5PwSwxRrKG07JjvmpAKVb6I/02Eb
# Jd6SnsHkVCQsz1L9lwsTpdPGM7bkYBRLcoCGqAml4KhSsr4I9CEEsCljmeEByrkG
# lKl0AL9aFrBQfw6+RAc78XueHETfa6HjRzFP6pWaaKb40T8EgFQMbLruFnE9pTT2
# +SR3cHFA4EhoLJTiFmU8LP7faZZdLgkDxIP6u+HKI17U5JPI3y4G3oMKaUROGTKl
# OzlHjwEeI52iFdlXvdNN53zTCeMBstaBB0n1y3kcJ3CF1iXBJ25Hj1GDs+T1q/ZJ
# h3YkOGxo0SxBNKYG0Hq3O/xKl8ZlOLVF0BoCaKs2gJ8BOvxa541eTpGAlRPgCNde
# c2gRwCFdeZ/6EWY1KUxINGEmFkmSH1zw3dgYtQxuRJ8vJF28dC5Hbg1MGf8LpC0P
# 5vrWw7Orm4qZNvTwtnMlCSdR60WBFmTE7D3mMMGK/CZBKooAXEPEmxMaP4M3Y/Dd
# 3DjPEJWbt4cu5+sIMx15X/guHMNBROzfVymq1g==
# SIG # End signature block
