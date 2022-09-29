<#
.SYNOPSIS
Changes text to speech.
.DESCRIPTION
Speaks the text specified in the parameter aloud.
.EXAMPLE
Use-Speech "hello"
#>
function Use-Speech {
    [CmdletBinding(HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/Speaker/Use-Speech.md")]
    Param(
        [Parameter(Mandatory=$true, ValuefromPipeline=$true)]
        [System.String[]]$TextToSpeech
    )
    Process{
        if($input){
            $Text += $_.ToString()
        }
        else{
            $Text = $TextToSpeech
        }
    }
    End{
        Start-Job {
            $sc = New-Object -ComObject MSScriptControl.ScriptControl.1
            $sc.Language = 'VBScript'
            $sc.AddCode('
                Function Speech(byval t)
                Set objVoice = CreateObject ("SAPI.SpVoice")
                ObjVoice.speak t
                End Function
            ')
            $sc.codeobject.Speech("$args")
        } -ArgumentList $Text -RunAs32 | Wait-Job | Receive-Job
    }
}

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnmmYBIVaTUn6o+/O6FaKdZDk
# Tn+gggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBSwurcZb91Ya3VnBeKXp1BZ/XlzAzANBgkqhkiG9w0BAQEFAASCAgBlsGqc
# h2gkvxS8pa9YIjqOJpE5o7RmAdWmbDxDq/pYE9Q9d0vcYmd7k54PQvhomzHXLcfQ
# 8+O1yXQGztOMKYMU/6zDVglQAaTMFr2yHWw0Svh3XeTRMrru2ZVcTtxgmpUmaKq3
# D0JFkTN5DOaWRW1kFQbjgJyVr53Swe4mu4cW5wEMJr7SMMRVcH8slVObAR2ome8u
# utHRp58Y2f8S7rV8uxk7+RucHehFr+OTRCJ42nI0QkyTr3H3gds/E4D9lRtiaRP7
# tYCzOkIkBcXzOmiNPkwRBw8iX37PqdEDE6B1VHFfPaKS6Ml82m2vTcuoK+amq5WK
# ZoYHTi909GH8PG/yqFWjAqDPSMte4kG76WBfv61ZWd4vmkorJPniOfLTStGOXhtH
# MTQAaLihKTle4C1hRryMEcenwf414sNiUx+wotDzTBbHo+cUjeQlydEhC7AcVkrU
# neyjNla9OOWpIg4TEkUJJa63J3EnY51wZfH4t7MXqK/zMUn9u1K7vidCsd5o/CYC
# GegG8dbScUanP5+qiNAL3PBPZGwM03rgpeqDjOn04q4pwWWmfFDbeWectIOvyaOr
# Admdbw/12NstTP6Ts+RP8xoRj9Qmn70CYralSoCN6YaeqEpCFFBgvrr31fCqPOVQ
# wXaLDGWfbbX7aLkXkM4oTjcM2yT5cVsJQ2WCUw==
# SIG # End signature block
