<#
.SYNOPSIS
Cleans the desktop.
.DESCRIPTION
Moves all files not in the exceptions list to the desktop archive.
.PARAMETER Autorun
Runs cleanup on system startup.
.PARAMETER Disable
Disable autorun.
.PARAMETER ExceptionList
Opens the exception list in the notepad.
.PARAMETER AddException
Specifies the name of the exception to be added.
.PARAMETER SetDefaultExceptionList
Restores the default exception list.
.PARAMETER SaveCurrentDesktopState
Adds all files currently on the desktop to the exceptions.
.PARAMETER Archives
Opens the desktop archive in the file explorer.
.EXAMPLE
Clear-Desktop
.EXAMPLE
Clear-Desktop -Autorun
.EXAMPLE
Clear-Desktop -SetDefaultExceptionList
#>
function Clear-Desktop{
    [CmdletBinding(DefaultParameterSetName = 'NoParameter')]
    Param(
        [Parameter(Mandatory = $true, ParameterSetName='Autorun')]
        [switch]$Autorun,
        [Parameter(Mandatory = $true, ParameterSetName='Disable')]
        [switch]$Disable,
        [switch]$SetDefaultExceptionList,
        [switch]$ExceptionList,
        [switch]$SaveCurrentDesktopState,
        [System.String]$AddException,
        [switch]$Archives
        
    )
    $ExceptionsFile = "$HOME\AppData\Local\APS\Configuration\desktopcleaner.exceptions.txt"
    $ArchivesDir ="$HOME\Desktop archive\"
    if($ExceptionList){
        $Skip=$true
        Write-Verbose "The exception list has been opened with a notepad."
        Start-Process notepad $ExceptionsFile
    }
    if($SaveCurrentDesktopState){
        $Skip=$true
        $Src = Get-ChildItem ~\Desktop
        Write-Verbose "The contents of the desktop have been read."
        Set-Content $ExceptionsFile "desktop.ini`r`ndesktop_backup.ini"
        Write-Verbose "The contents of the Exceptions File have been removed."
        foreach($file in $Src){
            Add-Content $ExceptionsFile $file
            Write-Verbose "Exception `"$file`" added to the list."
        }
        Write-Verbose "New exception list has been created."
    }
    if($SetDefaultExceptionList){
        $Skip=$true
        Set-Content $ExceptionsFile "desktop.ini`r`ndesktop_backup.ini`r`nTODO.txt`r`ntemp"
        Write-Verbose "Default file list has been restored."
    }
    if($AddException){
        $Skip=$true
        Add-Content $ExceptionsFile $AddException
        Write-Verbose "Exception `"$AddException`" added to the list."
    }
    if($Archives){
        $Skip=$true
        explorer.exe $($ArchivesDir)
        Write-Verbose "The desktop archive has been opened in the file explorer."
    }
    if($Autorun){
        $Disable=$false
        $action=New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoLogo -NonInteractive -WindowStyle Hidden -command Clear-Desktop"
        $options=New-ScheduledTaskSettingsSet -Hidden
        $triger=New-ScheduledTaskTrigger -User $env:UserName -AtLogOn
        $task=Get-ScheduledTaskInfo -TaskName "Clear-Desktop" -ErrorAction Ignore
        if(!($task)){
            Register-ScheduledTask -TaskName "Clear-Desktop" -Settings $options -Trigger $triger -Action $action –Force >> $null
            Write-Verbose "Created Scheduled Task."
        }
        else{
            Write-Output "Autostart was already on."
        }
    }
    if($Disable){
        $Skip=$true
        $task=Get-ScheduledTaskInfo -TaskName "Clear-Desktop" -ErrorAction Ignore
        if($task){
            Unregister-ScheduledTask -TaskName "Clear-Desktop"
            Write-Verbose "Removed from autostart."
        }
        else{
            Write-Output "Autostart was already turned off."
        }
    }
    if(!$Skip){
        $Src = Get-ChildItem ~\Desktop
        Write-Verbose "The contents of the desktop have been read."
        $DestPath = $ArchivesDir + (get-date).toString('MM.yyyy')
        if(!(Test-Path -Path $ArchivesDir)){
            mkdir $ArchivesDir >> $null
            Write-Verbose "Created path: $ArchivesDir."
        }
        if(!(Test-Path $DestPath)){
            mkdir $DestPath >> $null
            Write-Verbose "Created path: $DestPath."
        }
         if(!(Test-Path $ExceptionsFile)){
            Clear-Desktop -SetDefaultExceptionList
        }
        $exceptions = Get-Content $ExceptionsFile
        foreach($file in $Src){
            $filename = $file.Name
            $filebase = $file.BaseName
            $fileext = $file.Extension
            $filenameNU = $filename
            if($exceptions.Contains($file.Name)){
                Write-Verbose "Kept file: $file."
            }
            else{
                if(Test-Path $DestPath\$file){
                    $n = 1
                    while (Test-Path $DestPath\$filenameNU){
                        $filenameNU = $filebase + " (" + ++$n + ")" + $fileext
                    }
                    Write-Verbose "File name changed! $filenameNU"
                }
                Move-Item $file.FullName (Join-Path $DestPath $filenameNU)
                Write-Verbose "Moved the file: $filenameNU."
            }
        }
        Write-Verbose "Cleaning complete."
    }
}

# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQZ50/KctYXZ1ajWEG319dKS+
# +KGgggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBSH8wzWDvTAL0vXjlvoNDV86HdtGjANBgkqhkiG9w0BAQEFAASCAgBqjZJ9
# PiVICIRu5Aju5HEFwfSRHQqf+WkUkcWLCCHPLo2Erb20/6L4mQDJTr0AnAc9ouS0
# r7s8sKGc3cU0V7Eo7vPea3VW2BNpcUVc90R1uIPrJoam8KyaQ74Yi5u6pT4uqm8L
# h9+ECrYevuzN6mayYXYVzdpHmhsx7e/GcuP+y2DYMpn0R2axIEayAsiCB/77ZDV9
# +fOIuAXwPzgMTgbNPZfvjb2as2YMQid9//JDuHHcgh6G6YS0j6fNACCtuVjuGSor
# zD43ufm4Agg76Cy7nhDYpVxFKdSkQA8S6VPECBedLD4M+bE9MSIYjdhAKeoYEygx
# KwFh4XgJtB3r+lLs5crv39Y7y8w40dE5rOIbU1fekGX0b0WFWWXjeA30Rpcs8BIV
# zc6JGiso34sTvDL6JrbDn1PswZbSaP7+OluSmz/0PC6VaGZdHiYwR1CfGQflDr15
# T1PZuhJ8r/b7W4eulizlKc+jiHDQJVeVXI2lyLxinDZb0qKy3RnUvwalKdeawpzT
# +u6ReHOdMJnxeTlyag43Xyo7Fx19Rpbmxb+ynl03kGWDdVLKj+fushAl1xAvUcDk
# bc54Gu8ZCI25KeULrCx3Xuwi8671EnoEnSfQ5h1rm2D3XC951cJznj/MJKQ8F5DT
# s9md/ze16lcZ6/+RGzJILqdwl4dCe69b6bx+pQ==
# SIG # End signature block
