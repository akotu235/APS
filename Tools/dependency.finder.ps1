$modules = (Get-ChildItem  "$PSScriptRoot\..\APS\Modules").Name
$functionsList = @()
$modules | ForEach-Object{
    $functionsList += "#$_`n"
    $functions = ((Get-Module "$PSScriptRoot\..\APS\Modules\$_" -ListAvailable).ExportedFunctions).Keys | ForEach-Object {$functionsList += "$_`n"}
}
$functionsList = $functionsList.Split()
Get-ChildItem ".\..\APS\Modules" -Recurse | Where-Object Extension -Like ".psm1" | ForEach-Object {
    $module = $_
    Write-Host "$($_.Directory.Name): "-NoNewline -ForegroundColor DarkYellow
    $dependency = @()
    $functionsList | ForEach-Object {
        if($_ -like "#*"){
            $current = $_.TrimStart('#')
        }
        else{
            if($_){
                if((Search-InFile -Phrase $_ -Path $($module.FullName) -OnlyBooleanReturn)){
                   $dependency += $current
                }
            }
        }
    }
    $dependency = $($dependency | Sort-Object -Unique | ForEach-Object {if($_ -notlike $($module.Directory.Name)){$_}})
    if(0 -eq $dependency.Count){
        Write-Host "no dependency" -ForegroundColor DarkGreen
    }
    else{
        Write-Host "$($dependency -join ", " )" -ForegroundColor DarkCyan
    }
}


# SIG # Begin signature block
# MIIIWAYJKoZIhvcNAQcCoIIISTCCCEUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUau9rzhAEiV7ooriF0/LDA8NS
# OX+gggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBRyxRqW+1JiRr1GKCJR87oPuOLqaDANBgkqhkiG9w0BAQEFAASCAgC7rBad
# xkBCe8ufiMjanPFOKaSu1nXaUBxRsMkRpDxrPcgahBicDPCp9nkyPaeTYqCt8oPC
# OIIniKms9xPY8Mysqy0Yo5nQ55J70v931dChXOdzxaPbVxtOL0j2PGoYHk7m4Jfl
# 1ULtgo3ozqQ1jjg0Hent1iNjfW1clRDeP1c8L5uP55qb8zLEzi7g/JisCe3KhERt
# DyIFXXA/HHmcZYSUMRbq+5nJeCDS92cptYBAtJ+aC47L/9Z0BSaPi5GerHeLfSi0
# JmH+iKTNheDonPiwPWtAgWiq+DbwbJ0HrO7ncFQIpCM+UNLFjOu2gesa986+7Qru
# YK5BWfCV48JxdC8zz5YobqWaUAGL1fdSWqNPsIMbjokpbieJP2aV8y5Dw92IyQbK
# rG9KubEtm8TPytJ5J96JaDG9kmcWtw0PFrHF6Sqi+huAYtyM96nx3GlTkMfy4vje
# 7tXrmffrDz8qbCBqbLKVVquj41lgsJLofjKI88cm8ZrIMQrX2FO3fo7uJt5xTWqy
# CeNCIZfbguDtxBm/IaGeBb6+Rv3JQAqg3kbIiF4l6t1LYvjwBjiu9uNDPDEF6ItI
# HLkRBdDrFZYO030Ldy8fpcx2PuYSQPcL3ddVkZkz7B2HNmz9moH7vHBqCmSB2XcD
# 7z7DmAoTAltOriO0ZHfgu+fcXit+b/6Yf82qiQ==
# SIG # End signature block
