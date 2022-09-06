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
    [OutputType([System.Boolean])]
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
        Write-Output "$Result`n"
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
            Write-Output "[$CurrentLine] $Line"
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
        Write-Output "Scaning $($f.Name)..."
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
