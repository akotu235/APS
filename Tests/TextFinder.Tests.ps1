BeforeAll{
    $ModuleName = "TextFinder"
    Get-Module $ModuleName | Remove-Module -Force
    Import-Module "$PSScriptRoot\..\APS\Modules\$ModuleName"
    $samples = "$env:TEMP\APSTests"
    $file1 = New-Item "$samples\file1.txt" -Force
    $file2 = New-Item "$samples\file2.txt" -Force
    $file3 = New-Item "$samples\directory\file3.txt" -Force
    $file1 | Set-Content -Value "Dog`nCat`nRabbit`nBird`nHorse`nBear`nDeer`nCat`n"
    $file2 | Set-Content -Value "Horse`nChicken`nSnake`nFish`nBird`nLion`nCowCowCow`n"
    $file3 | Set-Content -Value "Horse`nAnt`nPig`nDuck`nShark`nWolf`nMonkey`n"
    Mock Write-Line -ModuleName $ModuleName {}
}
AfterAll{
    Remove-Item -Recurse -Force -Path $samples
}
Describe 'Search-InFile'{
    Context 'in a specific file'{
        It 'returns true if a phrase exists in the searched file'{
            $result = Search-InFile -Phrase bit -Path $file1
            $result[-1] | Should -BeTrue
        }
        It 'returns false if the phrase does not exist in the searched file'{
            $result = Search-InFile -Phrase Duck -Path $file1
            $result[-1] | Should -BeFalse
        }
        It 'displays the correct number of matches found'{
            $result = Search-InFile -Phrase Cat -Path $file1
            $result[-2] | Should -BeLike "found: 2*"
        }
    }
    Context 'in a directory'{
        It 'returns true if a phrase exists in the searched directory'{
            $result = Search-InFile -Phrase sh -Path $samples
            $result[-1] | Should -BeTrue
        }
        It 'returns false if a phrase does not exist in the searched directory'{
            $result = Search-InFile -Phrase pwsh -Path $samples
            $result[-1] | Should -BeFalse
        }
        It 'returns false if a phrase does not exist in the searched directory and exists in the subdirectory'{
            $result = Search-InFile -Phrase Ant -Path $samples
            $result[-1] | Should -BeFalse
        }
        It 'displays the correct number of matches found'{
            $result = Search-InFile -Phrase Horse -Path $samples
            $result[-2] | Should -BeLike "*found: 2*"
        }
    }
    Context 'with -Recurse'{
        It 'returns true if a phrase exists in the searched subdirectory'{
            $result = Search-InFile -Phrase Shark -Path $samples -Recurse
            $result[-1] | Should -BeTrue
        }
        It 'returns false if a phrase does not exist in the searched directorys'{
            $result = Search-InFile -Phrase pwsh -Path $samples -Recurse
            $result[-1] | Should -BeFalse
        }
        It 'displays the correct number of matches found'{
            $result = Search-InFile -Phrase Horse -Path $samples -Recurse
            $result[-2] | Should -BeLike "*found: 3*"
        }
    }
    Context 'with -CaseSensitive'{
        It 'returns true if a casesensitive phrase exists in the searched file'{
            $result = Search-InFile -Phrase Dog -Path $file1 -CaseSensitive
            $result[-1] | Should -BeTrue
        }
        It 'returns false if a phrase exists, but it is not casesensitivein the searched file'{
            $result = Search-InFile -Phrase dOG -Path $file1 -CaseSensitive
            $result[-1] | Should -BeFalse
        }
        It 'returns true if a casesensitive phrase exists in the searched directory'{
            $result = Search-InFile -Phrase Dog -Path $samples -CaseSensitive
            $result[-1] | Should -BeTrue
        }
        It 'returns false if a phrase exists, but it is not casesensitivein the searched directory'{
            $result = Search-InFile -Phrase dOG -Path $samples -CaseSensitive
            $result[-1] | Should -BeFalse
        }
    }
    Context 'with -StopWhenFinds'{
        It 'displays the correct number of matches found in the searched file'{
            $result = Search-InFile -Phrase Cat -Path $file1 -StopWhenFinds
            $result[-2] | Should -BeLike "found: 1*"
        }
        It 'displays the correct number of matches found in the searched directory'{
            $result = Search-InFile -Phrase Horse -Path $samples -StopWhenFinds
            $result[-2] | Should -BeLike "*found: 1*"
        }
    }
    Context 'occurrences in one line'{
        It 'displays the correct number of matches found in the searched file'{
            $result = Search-InFile -Phrase Cow -Path $file2
            $result[-2] | Should -BeLike "found: 3*"
        }
        It 'displays the correct number of matches found in the searched directory'{
            $result = Search-InFile -Phrase Cow -Path $samples
            $result[-2] | Should -BeLike "*found: 3*"
        }
    }
    Context 'with wildcard characters'{
        It 'displays the correct number of matches found in the searched file'{
            $result = Search-InFile -Phrase Ra*it -Path $file1
            $result[-2] | Should -BeLike "found: 1*"
        }
        It 'displays the correct number of matches found in the searched directory'{
            $result = Search-InFile -Phrase C??c??C -Path $samples
            $result[-2] | Should -BeLike "*found: 1*"
        }
    }
    Context 'with -AsSecure in a specific file'{
        It 'returns true if a phrase exists in the searched file'{
            Mock Read-Secure -ModuleName $ModuleName {return "bit"}
            $result = Search-InFile -Path $file1 -AsSecure
            $result[-1] | Should -BeTrue
        }
        It 'returns false if the phrase does not exist in the searched file'{
            Mock Read-Secure -ModuleName $ModuleName {return "Duck"}
            $result = Search-InFile -Path $file1 -AsSecure
            $result[-1] | Should -BeFalse
        }
    }
    Context 'with -AsSecure in a directory'{
        It 'returns true if a phrase exists in the searched directory'{
            Mock Read-Secure -ModuleName $ModuleName {return "sh"}
            $result = Search-InFile -Path $samples -AsSecure
            $result[-1] | Should -BeTrue
        }
        It 'returns false if a phrase does not exist in the searched directory'{
            Mock Read-Secure -ModuleName $ModuleName {return "pwsh"}
            $result = Search-InFile -Path $samples -AsSecure
            $result[-1] | Should -BeFalse
        }
        It 'returns false if a phrase does not exist in the searched directory and exists in the subdirectory'{
            Mock Read-Secure -ModuleName $ModuleName {return "Ant"}
            $result = Search-InFile -Path $samples -AsSecure
            $result[-1] | Should -BeFalse
        }
    }
    Context 'with -AsSecure and -Recurse'{
        It 'returns true if a phrase exists in the searched subdirectory'{
            Mock Read-Secure -ModuleName $ModuleName {return "Shark"}
            $result = Search-InFile -Path $samples -Recurse -AsSecure
            $result[-1] | Should -BeTrue
        }
        It 'returns false if a phrase does not exist in the searched directorys'{
            Mock Read-Secure -ModuleName $ModuleName {return "pwsh"}
            $result = Search-InFile -Path $samples -Recurse -AsSecure
            $result[-1] | Should -BeFalse
        }
    }
    Context 'with -AsSecure and -CaseSensitive'{
        It 'returns true if a casesensitive phrase exists in the searched file'{
            Mock Read-Secure -ModuleName $ModuleName {return "Dog"}
            $result = Search-InFile -Path $file1 -CaseSensitive -AsSecure
            $result[-1] | Should -BeTrue
        }
        It 'returns false if a phrase exists, but it is not casesensitivein the searched file'{
            Mock Read-Secure -ModuleName $ModuleName {return "dOG"}
            $result = Search-InFile -Path $file1 -CaseSensitive -AsSecure
            $result[-1] | Should -BeFalse
        }
        It 'returns true if a casesensitive phrase exists in the searched directory'{
            Mock Read-Secure -ModuleName $ModuleName {return "Dog"}
            $result = Search-InFile -Path $samples -CaseSensitive -AsSecure
            $result[-1] | Should -BeTrue
        }
        It 'returns false if a phrase exists, but it is not casesensitivein the searched directory'{
            Mock Read-Secure -ModuleName $ModuleName {return "dOG"}
            $result = Search-InFile -Path $samples -CaseSensitive -AsSecure
            $result[-1] | Should -BeFalse
        }
    }
    Context 'with -AsSecure and wildcard characters'{
        It 'returns true if a phrase exists'{
            Mock Read-Secure -ModuleName $ModuleName {return "Ra*it"}
            $result = Search-InFile -Path $file1 -AsSecure
            $result[-1] | Should -BeTrue
        }
        It 'returns false if the phrase does not exist'{
            Mock Read-Secure -ModuleName $ModuleName {return "Ra?it"}
            $result = Search-InFile -Path $file1 -AsSecure
            $result[-1] | Should -BeFalse
        }
    }
}