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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqYO/vNf5EW/qIRLHItoQHN9u
# gBmgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBRL9QjxgMagVmz0EsiRx0I/XOGNdzANBgkqhkiG9w0BAQEFAASCAgBpjFd8
# TsU1TPL6ypnw7kKa6JK5ci5hfp08362idvbCnTIDbmUTclvP854wFRUxpg/jeVPH
# f6HRMp6+qnm33cBc+2rKOcvQ28Y11AruJGmSJxwRFnv4+HzNPz3BNq5ESIcH5Jdp
# 31IWxTx0rB+aMVoyP/z+vlc+LN7rrsQV/8SpIJL2qHX5oN2LXiJylnAxyKgjEIys
# HCYLN4scb+RWBW0Pq3T3U0hIc6GKRK2YX4Sl1m7diYnUI7Nc0WrOoXswC+CWnOxj
# S+/O/nPB/lh03qxSW49dxkCod28+avfZe1thLlUd91KX+14nfI8t24SQtuufSrpu
# qEU5YjTOBTEYpnOlPaVpaVVqH3gQg/PwimonwlzhLzuKHpI6bu4mPWJtZo7MGxjx
# msJsSdUMQAKNeeSovZXH2HqGTsOgKrpBIEBTl+rbGcNxNI8lrRLcGybwpgxHAvUP
# bVGqVv+XynVDRFn/Ze0t3jtTe+Gsz9VIb0WfanGo91v9wfqRPtoFNFJT7IIYX0vj
# kD8prdyIyG4DtHtxEMhGLaaYUUI1AOGDdWelHYpCl7lp6rxZfheV8yDe6Ifoniq+
# lZBfh18yuAXafFsbY5V8rCw5i0boeMOFQ5bR0kjKsky/eAXeMTwOQ26T7G4YgncA
# yMrfJdJ+/QOwZ0I0OGVeqfXWQf1mlo2J2sXpXA==
# SIG # End signature block
