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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXcm46WU6hD7RQMbixJkG/u+C
# JQKgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBTkTHqJMej3z6bQsPBSG5S+XjdY0DANBgkqhkiG9w0BAQEFAASCAgBL7FK5
# 4zhEi30yyTZUn4ffwc0uUwlHmLK6lffga+LRby/Uv+hyDXdrHu+W0mFZMAnrezHZ
# cpLIlI/kBl5+OV3CtGq43wZIUB7YjNUBU3haygV2UgRumGBGO7i5pgtas4hbanYQ
# OFxfqCP3vxu9DU5awtTYrR8E5Rb6em84P8JvuQlxfdoKnj4UKIV8jwkR9G9IcAWP
# U6LFRu1JSMfu9lC9RNMUYBdrKXxaDZQnOYPdtrzKsnCVsVV4/zWCRcVHXhg7aS2q
# ATDMCX9qj6MlNl7nyEjD//RRZ8q7UGJMv8tU1qOLnl9O7/duFBHKzNYQiFZY9ZEi
# YSMkqRZRAdhJul1EdpE+sPwjyv7oe6cZFJeykEBWHkoEUTLlR4tBpJCZxL1kwpbK
# 2bIpNlcENhsZU69Jlldg8Pn5GnonIlL1gySd3dffRVBgw/8Us7u5GSh3GtAmV03B
# Luv5V1js/zMw8v+jzViYHTiPBGZPTi4vgPnEQ3ga5Xu/5hQnoTiVpflE5Y0uUQyz
# FBcVgCe4/FCQVKgjzuPStVOPbtDwUnaca3qw/MdcxXHCSgkyj4gxJ+nBqVFC6+Lj
# maTOXG2rdwJmOrOg98tmccrgOl2DLkMfpRKEdWXFyNXUC5jKKYZO8qISPBZB1Yvi
# RCwNdgOnEmv+EE+ih1sKlQHr8dlDHF1myjcG9A==
# SIG # End signature block
