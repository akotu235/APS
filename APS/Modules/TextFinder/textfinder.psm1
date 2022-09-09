<#
.SYNOPSIS
Find the phrase in the file.
.DESCRIPTION
Searches a file line by line without consuming RAM memory.
.PARAMETER Phrase
Enter a search term.
.PARAMETER Path
Enter a file path.
.PARAMETER Recurse
Gets the items in the specified locations and in all child items of the locations.
.PARAMETER RegularExpression
Search using regular expression.
.PARAMETER AsSecure
Set if you want to hide the searched phrase.
.PARAMETER CaseSensitive
Be case sensitive.
.PARAMETER StopWhenFinds
Stops searching after the first found item.
.EXAMPLE
Search-InFile C:\File.txt 'phrase you are looking for'
#>
function Search-InFile{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param(
        [string]$Phrase,
        [string]$Path = ".\",
        [switch]$Recurse,
        [switch]$RegularExpression,
        [switch]$AsSecure,
        [switch]$CaseSensitive,
        [switch]$StopWhenFinds
    )
    $DisplayResult = {
        param (
            [Parameter(Mandatory)]
            [string]$startTime,
            [int]$occurrence = 0,
            [int]$scannedCount
        )
        $result = "found: $(if(-not $AsSecure){"$occurrence "}else{[boolean]$occurrence}), time: $(&$TimeMeasurement $startTime)"
        if($scannedCount){
            $result = "scanned: $scannedCount, $result"
        }
        Write-Output "$result`n"
    }
    $TimeMeasurement = {
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
    $ActionWhenFound = {
        param (
            [Parameter(Mandatory)]
            [System.DateTime]$startTime,
            [Parameter(Mandatory)]
            [int]$currentLine,
            [Parameter(Mandatory)]
            [boolean]$stopSearching,
            [string]$line
        )
        if($AsSecure){
            $stopSearching = $true
        }
        if($stopSearching){
            if(-not $AsSecure){
                Write-Host "[$currentLine] $($line.Trim(" "))"
            }
            &$DisplayResult $startTime
            return $true
        }
        else{
            if(-not $AsSecure){
                Write-Host "[$currentLine] $($line.Trim(" "))"
            }
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
    $Phrase = "*$Phrase*"
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
        if(0 -lt $occurrence -and $stopWhenFinds){
            break
        }
        Write-Output "Scaning $($f.FullName)..."
        $scannedCount++
        $currentStartTime = Get-Date
        $currentOccurrence = 0
        $currentLine = 0
        $currentFile = $f.FullName
        if($RegularExpression){
            if($CaseSensitive){
                foreach($line in [System.IO.File]::ReadLines($currentFile)){
                    if($line -cmatch $Phrase){
                        $occurrence++
                        $currentOccurrence++
                        if(&$ActionWhenFound $startTime $currentLine $StopWhenFinds $line){
                            break
                        }
                    }
                    $currentLine++
                }
            }
            else{
                foreach($line in [System.IO.File]::ReadLines($CurrentFile)){
                    if($line -match $Phrase){
                        $occurrence++
                        $currentOccurrence++
                        if(&$ActionWhenFound $startTime $currentLine $StopWhenFinds $line){
                            break
                        }
                    }
                    $currentLine++
                }
            }
        }
        else{
            if($CaseSensitive){
                foreach($line in [System.IO.File]::ReadLines($CurrentFile)){
                    if($line -clike $Phrase){
                        $occurrence++
                        $currentOccurrence++
                        if(&$ActionWhenFound $startTime $currentLine $StopWhenFinds $line){
                            break
                        }
                    }
                    $currentLine++
                }
            }
            else{
                foreach($line in [System.IO.File]::ReadLines($CurrentFile)){
                    if($line -like $Phrase){
                        $occurrence++
                        $currentOccurrence++
                        if(&$ActionWhenFound $startTime $currentLine $StopWhenFinds $line){
                            break
                        }
                    }
                    $currentLine++
                }
            }
        }
        &$DisplayResult $currentStartTime $currentOccurrence
    }
    if($File.PSIsContainer){
        &$DisplayResult $startTime $occurrence $scannedCount
    }
    return [boolean]$occurrence
}