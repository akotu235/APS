<#
.SYNOPSIS
Reads the given text.
.EXAMPLE
Use-Speech "hello"
#>
function Use-Speech {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true, ValuefromPipeline=$true)]
    [string]$TextToSay
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
    } -ArgumentList $TextToSay -RunAs32 | Wait-Job | Receive-Job
}





# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtFMQ0TtmwWHVSbU8gqBOVD4h
# MTWgggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
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
# CQQxFgQUAhrZenh9dwjA5z5wwLGF8o7W5hkwDQYJKoZIhvcNAQEBBQAEggEAXOuM
# ERgsAbEAqv+N2PUy6gZGPUSxhpd9Znz372TQB1aFZaAyNck0cUca60BxQYIleV7c
# GpXwWf8j+dtEsj4kaQzc29P632hIfADL2ZSadB9dbcZybQ3hjtwaYAWAkEimqdgE
# wP0TfIQOs21oZP3Pz9YuFcpXB+wIbGe3Q86srvhmJY6OFBxAgs4whtu1rsXkv4K6
# Pslmfi+pcQvm6DKfhon2u3JDAGnCpYLbWgka2HYbi0/p/xnYZdatNdJBWCS/pCSV
# GCV+04k1SPkqja+072l/T6qNclNT9kGrKDJpGib/P1R3tNJtBx2pHRDOI7UBHsnd
# RxTXIBOg7FMfI3g3Kg==
# SIG # End signature block
