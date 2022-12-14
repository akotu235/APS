<#
.SYNOPSIS
Searches for a phrase in a file.
.DESCRIPTION
Searches a file line by line without consuming RAM memory.
.PARAMETER Phrase
Specifies the search term.
.PARAMETER Path
Specifies the path to the file or directory to be searched.
.PARAMETER Recurse
Searches for items in specified locations and in all location children.
.PARAMETER AsSecure
Hides the searched phrase.
.PARAMETER CaseSensitive
Matches a case-sensitive phrase.
.PARAMETER StopWhenFinds
Stops searching after the first found item.
.EXAMPLE
Search-InFile C:\File.txt 'phrase you are looking for'
#>
function Search-InFile{
    [OutputType([System.Boolean])]
    [CmdletBinding(DefaultParameterSetName = 'Default', HelpUri="https://github.com/akotu235/APS/blob/master/Docs/Modules/TextFinder/Search-InFile.md")]
    param(
        [SupportsWildcards()]
        [Parameter(ParameterSetName='Default', Position=0)]
        [System.String]$Phrase,
        [Parameter(Mandatory = $true, ParameterSetName='AsSecure')]
        [switch]$AsSecure,
        [Parameter(ParameterSetName='Default', Position=1)]
        [Parameter(ParameterSetName='AsSecure', Position=0)]
        [System.String]$Path = ".\",
        [switch]$Recurse,
        [switch]$CaseSensitive,
        [Parameter(ParameterSetName='Default')]
        [switch]$StopWhenFinds,
        [Parameter(ParameterSetName='Default')]
        [switch]$OnlyBooleanReturn
    )
    if($OnlyBooleanReturn){
        $StopWhenFinds = $true
    }
    if($AsSecure){
        $Phrase = Read-Secure
    }
    else{
        if(!$Phrase){
            $Phrase = Read-Host -Prompt "Enter a search term"
        }
    }
    $file = Get-Item $Path
    if($file.PSIsContainer){
        $files = Get-ChildItem $Path -File -Recurse:$Recurse
    }
    else{
        $files = @($file)
    }
    $occurrence = 0
    $startTime = Get-Date
    $scannedCount = 0
    foreach($f in $files){
        if(0 -lt $occurrence -and $StopWhenFinds){
            break
        }
        if(-not $OnlyBooleanReturn){
            Write-Output "Scaning $($f.FullName)..."
        }
        $scannedCount++
        $currentStartTime = Get-Date
        $currentOccurrence = 0
        $currentLine = 1
        $currentFile = $f.FullName
        if($CaseSensitive){
            foreach($line in [System.IO.File]::ReadLines($currentFile)){
                if($line -clike "*$Phrase*"){
                    $occurrence++
                    $currentOccurrence++
                    if(-not ($AsSecure -or $OnlyBooleanReturn)){
                        Write-Line -highlighted $Phrase -row $line.Trim() -number $currentLine -caseSensitive:$CaseSensitive
                    }
                    if($StopWhenFinds){
                        break
                    }
                    if(0 -le $line.IndexOf($Phrase)){
                        $tline = $line.Substring($line.IndexOf($Phrase) + $Phrase.Length)
                        while($tline -clike "*$Phrase*"){
                            $occurrence++
                            $currentOccurrence++
                            $tline = $tline.Substring($tline.IndexOf($Phrase) + $Phrase.Length)
                        }
                    }
                }
                $currentLine++
            }
        }
        else{
            foreach($line in [System.IO.File]::ReadLines($currentFile)){
                if($line -like "*$Phrase*"){
                    $occurrence++
                    $currentOccurrence++
                    if(-not ($AsSecure -or $OnlyBooleanReturn)){
                        Write-Line -highlighted $Phrase -row $line.Trim() -number $currentLine -caseSensitive:$CaseSensitive
                    }
                    if($StopWhenFinds){
                        break
                    }
                    $tline = $line.ToLower()
                    $tPhrase = $Phrase.ToLower()
                    if(0 -le $tline.IndexOf($tPhrase)){
                        $tline = $tline.Substring($tline.IndexOf($tPhrase) + $tPhrase.Length)
                        while($tline -like "*$tPhrase*"){
                            $occurrence++
                            $currentOccurrence++
                            $tline = $tline.Substring($tline.IndexOf($tPhrase) + $tPhrase.Length)
                        }
                    }
                }
                $currentLine++
            }
        }
        if(-not $OnlyBooleanReturn){
            Write-Result -startTime $currentStartTime -occurrence $currentOccurrence
        }
    }
    if($File.PSIsContainer){
        if(-not $OnlyBooleanReturn){
            Write-Result -startTime $startTime -occurrence $occurrence -scannedCount $scannedCount
        }
    }
    return [boolean]$occurrence
}

function Read-Secure{
    return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($(Read-Host "Enter a search term" -AsSecureString)))
}

function Write-Result{
    param (
        [Parameter(Mandatory = $true)]
        [System.String]$startTime,
        [int]$occurrence,
        [int]$scannedCount
    )
    $result = "found: $(if(-not $AsSecure){"$occurrence "}else{[boolean]$occurrence}), time: $(Measure-Time $startTime)"
    if($scannedCount){
        $result = "scanned: $scannedCount, $result"
    }
    Write-Output "$result`n"
}

function Write-Line{
    param (
        [Parameter(Mandatory)]
        [System.String]$highlighted,
        [Parameter(Mandatory)]
        [System.String]$row,
        [int]$number,
        [switch]$caseSensitive
    )
    if($number){
        Write-Host "[$number] " -NoNewline
    }
    $itab = @()
    $c=0
    if($caseSensitive){
        $tline = $row
        while($tline.Contains($highlighted)){
            $itab += $tline.IndexOf("$highlighted")
            $tline = $tline.Remove($itab[-1], $highlighted.Length)
            $itab[-1] = $itab[-1] + ($highlighted.Length)*$c
            $c++
        }
    }
    else{
        $tline = $row.ToLower()
        $thighlighted = $highlighted.ToLower()
        while($tline.Contains($thighlighted)){
            $itab += $tline.IndexOf("$thighlighted")
            $tline = $tline.Remove($itab[-1], $highlighted.Length)
            $itab[-1] = $itab[-1] + ($highlighted.Length)*$c
            $c++
        }
    }
    $c = 0
    foreach($i in $itab){
        $j=$i-$c
        Write-Host $row.Substring($c, $j) -NoNewline
        Write-Host $row.Substring($c+$j, $highlighted.Length) -NoNewline -BackgroundColor Yellow -ForegroundColor Black
        $c+=($highlighted.Length)+$j
    }
    Write-Host $row.Substring($c) -ErrorAction Continue
}


function Measure-Time{
    param (
        [Parameter(Mandatory)]
        [System.DateTime]$startTime
    )
    $endTime = Get-Date
    $totalTime = $endTime - $startTime
    if($endTime -lt $startTime.AddSeconds(5)){
        return "$($totalTime.TotalSeconds) sec"
    }
    elseif($endTime -lt $startTime.AddMinutes(1)){
        return "$([int]$totalTime.Seconds) sec"
    }
    elseif($endTime -lt $startTime.AddHours(1)){
        return "$($totalTime.Minutes) min $($totalTime.ToString('ss')) sec"
    }
    else{
        return "$([int]($totalTime.TotalHours)) h $($totalTime.ToString('mm')) min $($totalTime.ToString('ss')) sec"
    }
}

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU8u5QMRqhuIJDvAVCc4EfmA46
# 16KgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBRnEyJlDo7UdOikZPOcxoVURmlHZzANBgkqhkiG9w0BAQEFAASCAgBg4wGC
# BgnyWIkVRQD5yl+SUKfh4zRCeHqxqVV+Eo3RSlSFWUprwuRdqHLwpJSDrylWq3xM
# cfx51YKP2AX5R+H836laORfOuRPiZSKe67ddyHQ+c0u3gEZZiBobxFq45TWOF2zP
# TzUM2ubSSVOGuFz5/UR3jw/obWUDu1qPl/Guu3a9ZD8GsNnPTdoUruP4YppCKh9/
# dmKYC0/DmcgLu6SRh3slE7IWxYyMjVW8iym1XGai5Tf71JozxAM8eFgqZAwan40M
# UUicQnhpJGpu+Utzhk8mfgzFNDMPcImRAINiowS9vwTeS2MlFhRdUrrCNUeXv0Fw
# hQ/MEeTgi+v/uYslfNu7I35WaaCiDv0myS6qSQ+OeXHfkCasCyskJ7oDOfo2bdlk
# 7Ft6qVevbvrdkGSmMXPruqDXgNRQ6qdyF0wY/pJAXK3fd6qDEPHI5WsylupqmNTj
# H/rqYICDdN18Baxoru/fTV9n7vUr3MEwVigvZNaMpeKR3mzCPCGcTEqGne6P2EqA
# +o9MZGi1jfW5z88JbHOvKG4+hk+w67pMukYyRxEUucPKZrm+9MFXg+MWFcC6nlNw
# g3ygFzbDiBFmAzN54D94uPIATf/+5rQo++IZxSlNSwHuTrp9apcZMDlT2BjxXNys
# 8ZPjlhZcS1YXVIqSSaof77AcF+X7DVL8VOg8Kg==
# SIG # End signature block
