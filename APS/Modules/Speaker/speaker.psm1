<#
.SYNOPSIS
Changes text to speech.
.DESCRIPTION
Speaks the text specified in the parameter aloud.
.EXAMPLE
Use-Speech "hello"
#>
function Use-Speech {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true, ValuefromPipeline=$true)]
    [System.String]$TextToSpeech
    )
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
    } -ArgumentList $TextToSpeech -RunAs32 | Wait-Job | Receive-Job
}


# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6l+x2GvzsE2kkw4dooBxUexU
# XKKgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBRbwo1fkejLj9PqtWBZ5Lg1LdGLKjANBgkqhkiG9w0BAQEFAASCAgA5Gp4w
# WOpPxX9fcTZ/QEBLxCGES7ppXrkI86qfedSlfGik0YvmvLwwrKHEOoM2fRkzUU/B
# RCSnLqgXcy/E1GR3Onajhjp3Nd1CJN9/DXm7G6EEMVuc3pyGQUK9mH9uuG4/bVJ3
# GihNt/pNkNR5qOMgn086QdN/eVGg4sd0CytsbWb/8dDPwnRwb4AJIWvPtkxH/OMW
# Y6ZBP1kGbby6Jg3Vvk8YduE7ODhpmWT5I/fA+g6HvE9zlLCDOqlF9btP6KRqxI2D
# RY3IVE6iOzL39Spa/ogRtdr4jVS+47ADItuoCSf7p986TntaxhrRbpBMrqcf2bmJ
# FdmBerfy/WaykkV7PLa4O+lPx7swfzGFF6Xgg+q6LNkS2mjDBn4UF32O6IeU1YBe
# PTyJA1fRk2TTaOiJ1Wsz9u/16inGehPqj4HoMFgNiesbZxdSEkcvCiOfkqbJm4Qm
# cTXT6djhE0vnFO2sAYSD1iF25ug2ZIUvAAhQCeDoCMfU4YbveZSllDXOHYwanQJ/
# Zcx+zORucLnaeoCic2+NSLvY73INfWvbjAAb2Muh2ivjifGLHavneqi6I8KFd4jS
# unIMXJt1UuxIE5/euPyFsQBtH/NgjRXAfA7l++hy6AsbB9RFmS2Ydx6gdQFboheR
# oXPm55Hp1aw91RXCnzFR3Cg/sVvqHgOVTQSGTQ==
# SIG # End signature block
