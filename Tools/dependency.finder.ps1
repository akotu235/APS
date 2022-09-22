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
    $dependency = $($dependency | Sort-Object –Unique | ForEach-Object {if($_ -notlike $($module.Directory.Name)){$_}})
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdZtynL6iuQgCxeaCJy6A4fh9
# 6D2gggT6MIIE9jCCAt6gAwIBAgIQYYPyfUBBC6pE/rAfOslXOzANBgkqhkiG9w0B
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
# BDEWBBRNRbELrEffsAZrOptCcs97q+EBwjANBgkqhkiG9w0BAQEFAASCAgAE9WSe
# rvRjU4MNpBkyhDaZ0P1afivh7o6dF8wa/GkwdSiM2YSfvM1FKYQUBoI/pSEVyuUg
# uaYie/iM7/bJIi/zXSW1+wasIiiaYIa7KWnrTc3JHF6r0PuSZg+h8wXO0+7YO05+
# xxRjw4v+19gT9fpf7JA6Sp85ujU6Xkw1GEG4L56vhDN3OLK8PtaVBkclIHzIB2qp
# tKC9QBFS6+ybv3E3Dz8msTNGjeyvR+ararVRWZ++nIzU6duTvQ0eDCGwjW8SQm9t
# 6IF+R5knqxdcNr600sBgQNL4Fi7ro15OrMT0jNmCFO7+Cv1cgskwPbtvn0+m3zsH
# IT22U1tBhIuxgOJ8Y5mC4GtTYJZYVmRzH7f8LzZPzlFsT/sNG+GL3InQDDMLThu7
# wwTRe16BzPGCDKsecOMAgtR0h4i3HdjtHEhc4qbyRS0Xyqu2US60YGeskzP3d7rC
# GAaVRDCHF7yEgTj04vfl4mlxEcSd3fO5bA3YP9HiPa18gJhO2OT3NZHEV63PSYmZ
# KLpPKdt3TVJk4SpFot1QJjmwp4WCA/YdfdsmzSYdgva1y/0RSFiK7D7PBLo9TN09
# 3iIPVinz5daMTyzYeo68O1SI+ndQMy8dlD1ODWnHv1CnI5H/9Zv3FuF4h3xCIvKQ
# Mj4heK555939vOsN9xBFB+3AWjnldi/0/S73QA==
# SIG # End signature block
