<#
.SYNOPSIS
Find the phrase in the file.
.DESCRIPTION
Searches a file line by line without consuming RAM memory.
.PARAMETER Phrase 
Enter a search term.
.PARAMETER Path
Enter a file path.
.PARAMETER RegularExpression
Search using regular expression.
.PARAMETER AsSecure
Set if you want to hide the searched phrase.
.PARAMETER CaseSensitive
Change to $false if you want to turn off case sensitivity.
.EXAMPLE
Search-InFile C:\File.txt 'phrase you are looking for'
.EXAMPLE
Search-InFile C:\File.txt '^regular?expression$' -RegularExpression
.EXAMPLE
Search-InFile C:\File.txt -AsSecure
#>
function Search-InFile{
    [CmdletBinding()] 
    param(
        [string]$Phrase,
        [string]$Path,
        [switch]$RegularExpression,
        [switch]$AsSecure, 
        [switch]$CaseSensitive = $true
    )

    $DisplayResult = {
        param (
            [Parameter(Mandatory)]
            [string]$StartTime,
            [int]$Occurrence = 0,
            [string]$Scanned
        )
        
        $Result = "found: $Occurrence  time: $(&$TimeMeasurement $StartTime)"

        if($Scanned){
            $Result = "scanned: $Scanned  $Result"
        }
        
        Write-Host $Result
        Write-Host ""
    }

    $TimeMeasurement = {
        param (
            [Parameter(Mandatory)]
            [System.DateTime]$StartTime
        )
        $EndTime = Get-Date
        $TotalTime = $EndTime - $StartTime
        if($EndTime -lt $StartTime.AddSeconds(5)){
            return "$($TotalTime.TotalSeconds) sec"
        }
        elseif($EndTime -lt $StartTime.AddMinutes(1)){
            return "$([int]$TotalTime.Seconds) sec"
        }
        elseif($EndTime -lt $StartTime.AddHours(1)){
            return "$($TotalTime.Minutes) min $($TotalTime.ToString('ss')) sec"
        }
        else{
            return "$([int]($TotalTime.TotalHours)) h $($TotalTime.ToString('mm')) min $($TotalTime.ToString('ss')) sec"
        }
    }

    $FindOperations = {
        param (
            [Parameter(Mandatory)]
            [System.DateTime]$StartTime,
            [Parameter(Mandatory)]
            $CurrentLine,
            [Parameter(Mandatory)]
            [boolean]$StopSearching,
            $Line
        )

        if($StopSearching){
            &$DisplayResult $StartTime
            return $true
        }
        else{
            Write-Host "[$CurrentLine] $Line"
        }

        return $false
    }

    if($AsSecure){
        $SecurePhrase = Read-Host "Enter a search term" -AsSecureString
        $Phrase = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePhrase))
       
    } 
    else{
        if(!$Phrase){
            $Phrase = Read-Host -Prompt "Enter a search term"
        }
    }

    if(!$Path){
        $Path = ".\"
    }
    $File = Get-Item $Path
    if($File.PSIsContainer){
        $Files = Get-ChildItem $Path -File | Sort-Object Length
    }
    else{
        $Files = @($File)
    }

    $Occurrence = 0
    $StartTime = Get-Date

    foreach($f in $Files){
        Write-Host "Scaning $($f.Name)..."
        $CurrentStartTime = Get-Date
        $CurrentOccurrence = 0
        $CurrentLine = 0
        $CurrentFile = $f.FullName
        if($RegularExpression){
            if($CaseSensitive){
                foreach($line in [System.IO.File]::ReadLines($CurrentFile)){
                    if($line -cmatch $Phrase){
                        $Occurrence++
                        $CurrentOccurrence++
                        if(&$FindOperations $StartTime $CurrentLine $AsSecure $line){
                            return $true
                        }
                    }
                    $CurrentLine++
                }
            }
            else{
                foreach($line in [System.IO.File]::ReadLines($CurrentFile)){
                    if($line -match $Phrase){
                        $Occurrence++
                        $CurrentOccurrence++
                        if(&$FindOperations $StartTime $CurrentLine $AsSecure $line){
                            return $true
                        }
                    }
                    $CurrentLine++
                }
            }
        }
        else{
            if($CaseSensitive){
                foreach($line in [System.IO.File]::ReadLines($CurrentFile)){
                    if($line -clike $Phrase){
                        $Occurrence++
                        $CurrentOccurrence++
                        if(&$FindOperations $StartTime $CurrentLine $AsSecure $line){
                            return $true
                        }
                    }
                    $CurrentLine++
                }
            }
            else{
                foreach($line in [System.IO.File]::ReadLines($CurrentFile)){
                    if($line -like $Phrase){
                        $Occurrence++
                        $CurrentOccurrence++
                        if(&$FindOperations $StartTime $CurrentLine $AsSecure $line){
                            return $true
                        }
                    }
                    $CurrentLine++
                }
            }
        }
        &$DisplayResult $CurrentStartTime $CurrentOccurrence
    }
    
    if($File.PSIsContainer){
        &$DisplayResult $StartTime $Occurrence $($Files.Count)
    }

    return [boolean]$Occurrence
}
# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1WvOyL4oTjIsCc9Okn7MK+yL
# rpWgggMQMIIDDDCCAfSgAwIBAgIQfziWHbCKBoRNGa23h81cKTANBgkqhkiG9w0B
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
# CQQxFgQUfldN4QkJQaeE6O8UMpKfwAUoCMUwDQYJKoZIhvcNAQEBBQAEggEAFmC9
# anAPOULV+JOPRW5wUfQRRt7dXSWIc/YKAij4TOxdT/Opb4dy513rloUudBue3h5P
# CcPcydyFMC9TYNfq1ywWwEh/Yv7Jic/4A7bxzmlJCMqV2dwgYDq3tPsvzXprkX5k
# DJujv8SVUuFtAlYUfookbh2jT9BUy/hUMN3quAclSDQ0e9XipMmwtucJApw6PaPN
# T1xwTdtnqeKjXUA6j3VMHOqPCKf28R8US1vq3zkjttt2pbZWYxBawaMroJ81jIp2
# zy8/GJ3B4n80NaEQWcYNupXJAReI2buA6szwGjeCWEHeP10K+d2sD6SPGog69k1K
# YqFZY0K3bWbkhH0nLw==
# SIG # End signature block
