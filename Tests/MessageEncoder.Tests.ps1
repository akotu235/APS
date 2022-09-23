BeforeAll{
    $ModuleName = "MessageEncoder"
    Get-Module $ModuleName | Remove-Module -Force
    Import-Module "$PSScriptRoot\..\APS\Modules\$ModuleName"

    Mock Read-Password -ModuleName $ModuleName {("pass" | ConvertTo-SecureString -AsPlainText -Force)}
    Mock explorer.exe -ModuleName $ModuleName {}
    Mock Read-Key -ModuleName $ModuleName {return "CN=APS_$keyName"}
    $keysDir = "$HOME\.keys\My"
    $keyName = "test_key$(Get-Random)"
    New-EncryptionKey -Name $keyName
}
AfterAll{
    Remove-Item -Force "$HOME\.keys\My\$keyName*"
    Get-ChildItem Cert:\CurrentUser\My | Where-Object -Property Subject -Like *$keyName  | Remove-Item -Force 
}
Describe 'New-EncryptionKey'{
    It 'creates private key'{
        "$keysDir\$keyName.pfx" | Should -Exist
    }
    It 'creates public key'{
        "$keysDir\$keyName.pub.cer" | Should -Exist
    }
    It 'installs the certificate in the appropriate store'{
        $cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object -Property Subject -Like *$keyName 
        $cert | Should -BeOfType "System.Security.Cryptography.X509Certificates.X509Certificate2"
    }
}
Describe 'Protect-Message'{
    It 'returns an encrypted message'{
        $result = (Protect-Message "Test message")[-1]
        $result | Should -BeLike "`";*;`""
        $result.Length | Should -BeGreaterThan 700
    }
}
Describe 'Unprotect-Message'{
    It 'returns an decrypted message'{
        $cipher = (Protect-Message "Test message")[-1]
        $result = Unprotect-Message $cipher
        $result | Should -BeExactly "Test message"
    }
}
