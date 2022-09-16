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
    [CmdletBinding()]
    param(
        [SupportsWildcards()]
        [Parameter(ParameterSetName='Default', Position=0)]
        [System.String]$Phrase,
        [Parameter(ParameterSetName='AsSecure')]
        [switch]$AsSecure,
        [System.String]$Path = ".\",
        [switch]$Recurse,
        [switch]$CaseSensitive,
        [Parameter(ParameterSetName='Default')]
        [switch]$StopWhenFinds
    )
    $DisplayResult = {
        param (
            [Parameter(Mandatory)]
            [System.String]$startTime,
            [int]$occurrence,
            [int]$scannedCount
        )
        $result = "found: $(if(-not $AsSecure){"$occurrence "}else{[boolean]$occurrence}), time: $(&$TimeMeasurement $startTime)"
        if($scannedCount){
            $result = "scanned: $scannedCount, $result"
        }
        Write-Output "$result`n"
    }
    $DisplayLine = {
        param (
            [Parameter(Mandatory)]
            [System.String]$highlighted,
            [Parameter(Mandatory)]
            [System.String]$row,
            [int]$number,
            [switch]$CaseSensitive
        )
        if($number){
            Write-Host "[$number] " -NoNewline
        }
        $itab = @()
        $c=0
        if($CaseSensitive){
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
    if($AsSecure){
        $SecurePhrase = Read-Host "Enter a search term" -AsSecureString
        $Phrase = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePhrase))
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
        Write-Output "Scaning $($f.FullName)..."
        $scannedCount++
        $currentStartTime = Get-Date
        $currentOccurrence = 0
        $currentLine = 0
        $currentFile = $f.FullName
        if($CaseSensitive){
            foreach($line in [System.IO.File]::ReadLines($currentFile)){
                if($line -clike "*$Phrase*"){
                    $occurrence++
                    $currentOccurrence++
                    if(-not $AsSecure){
                        &$DisplayLine $Phrase $line.Trim() $currentLine
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
                    if(-not $AsSecure){
                        &$DisplayLine $Phrase $line.Trim() $currentLine
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
        &$DisplayResult $currentStartTime $currentOccurrence
    }
    if($File.PSIsContainer){
        &$DisplayResult $startTime $occurrence $scannedCount
    }
    return [boolean]$occurrence
}