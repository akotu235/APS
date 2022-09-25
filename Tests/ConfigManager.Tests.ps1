BeforeAll{
    $ModuleName = "ConfigManager"
    Remove-Module $ModuleName -Force -ErrorAction SilentlyContinue
    Import-Module "$PSScriptRoot\..\APS\Modules\$ModuleName"
    $samples = "$([System.IO.Path]::GetTempPath())\APSTests"
    $sampleConfig = "$([System.IO.Path]::GetTempPath())\APSTests\test.config.xml"
    $sampleModuleBase = "$([System.IO.Path]::GetTempPath())\APSTests\Test"
    Mock Get-ConfigPath -ModuleName $ModuleName {return "$sampleConfig"}
}
Context 'config exists'{
    BeforeEach{
        $testConfig = New-Object PSObject -Property @{
            Field1 = "Value1"
            Field2 = "Value2"
            Field3 = "Value3"
        }
        New-Item -Path $samples -ItemType Directory -Force
        $testConfig | Export-Clixml -Path $sampleConfig -Force
    }
    AfterEach{
        Remove-Item $samples -Recurse -Force -ErrorAction SilentlyContinue
    }
    Describe 'Get-Config'{
        It 'returns config'{
            $result = Get-Config $sampleModuleBase
            $result.Field1 | Should -BeExactly "Value1"
            $result.Field2 | Should -BeExactly "Value2"
            $result.Field3 | Should -BeExactly "Value3"
        }
    }
    Describe 'Set-ConfigField'{
        It 'returns updated config'{
            $result = Set-ConfigField $sampleModuleBase Field1 "Value4"
            $result.Field1 | Should -BeExactly "Value4"
            $result.Field2 | Should -BeExactly "Value2"
            $result.Field3 | Should -BeExactly "Value3"
        }
        It 'updated config'{
            Set-ConfigField $sampleModuleBase Field1 "Value4"
            $result = Get-Config $sampleModuleBase
            $result.Field1 | Should -BeExactly "Value4"
            $result.Field2 | Should -BeExactly "Value2"
            $result.Field3 | Should -BeExactly "Value3"
        }
    }
    Describe 'Remove-Config'{
        Context 'deletes all config'{
            It 'return $null'{
                $result = Remove-Config $sampleModuleBase
                $result | Should -BeNullOrEmpty
            }
            It 'deleted config'{
                Remove-Config $sampleModuleBase
                Test-Path($sampleConfig) | Should -BeFalse
            }
        }
        Context 'witch -Field'{
            It 'returns updated config'{
                $result = Remove-Config $sampleModuleBase "Field2"
                $result.Field1 | Should -BeExactly "Value1"
                $result.Field2 | Should -BeNullOrEmpty
                $result.Field3 | Should -BeExactly "Value3"
            }
            It 'updated config'{
                Remove-Config $sampleModuleBase "Field2"
                $result = Get-Config $sampleModuleBase
                $result.Field1 | Should -BeExactly "Value1"
                $result.Field2 | Should -BeNullOrEmpty
                $result.Field3 | Should -BeExactly "Value3"
            }
            It 'returns not updated config if the field does not exist'{
                $result = Remove-Config $sampleModuleBase "NotExist"
                $result.Field1 | Should -BeExactly "Value1"
                $result.Field2 | Should -BeExactly "Value2"
                $result.Field3 | Should -BeExactly "Value3"
            }
            It 'does not break the configuration file if the field does not exist'{
                Remove-Config $sampleModuleBase "NotExist"
                $result = Get-Config $sampleModuleBase
                $result.Field1 | Should -BeExactly "Value1"
                $result.Field2 | Should -BeExactly "Value2"
                $result.Field3 | Should -BeExactly "Value3"
            }
        }
    }
    Describe 'Save-Config'{
        It 'returns updated config'{
            $Config = New-Object PSObject -Property @{
                Field4 = "Value1"
                Field5 = "Value2"
                Field1 = "Value1"
            }
            $result = Save-Config $sampleModuleBase $Config
            $result.Field1 | Should -BeExactly "Value1"
            $result.Field2 | Should -BeNullOrEmpty
            $result.Field3 | Should -BeNullOrEmpty
            $result.Field4 | Should -BeExactly "Value1"
            $result.Field5 | Should -BeExactly "Value2"
        }
        It 'updated config'{
            $Config = New-Object PSObject -Property @{
                Field4 = "Value1"
                Field5 = "Value2"
                Field1 = "Value1"
            }
            Save-Config $sampleModuleBase $Config
            $result = Get-Config $sampleModuleBase
            $result.Field1 | Should -BeExactly "Value1"
            $result.Field2 | Should -BeNullOrEmpty
            $result.Field3 | Should -BeNullOrEmpty
            $result.Field4 | Should -BeExactly "Value1"
            $result.Field5 | Should -BeExactly "Value2"
        }
    }
}
Context 'configuration does not exist'{
    AfterAll{
        Remove-Item $samples -Recurse -Force -ErrorAction SilentlyContinue
    }
    Context 'witch -ModuleBase'{
        Describe 'Get-Config'{
            It 'returns $null'{
                $result = Get-Config $sampleModuleBase
                $result | Should -BeNullOrEmpty
            }
        }
        Describe 'Set-ConfigField'{
            It 'returns new config'{
                $result = Set-ConfigField $sampleModuleBase Field1 "Value1"
                $result.Field1 | Should -BeExactly "Value1"
            }
            It 'creates config'{
                Set-ConfigField $sampleModuleBase Field1 "Value1"
                $result = Get-Config $sampleModuleBase
                $result.Field1 | Should -BeExactly "Value1"
            }
        }
        Describe 'Remove-Config'{
            Context 'deletes all config'{
                It 'return $null'{
                    $result = Remove-Config $sampleModuleBase
                    $result | Should -BeNullOrEmpty
                }
                It 'does not create a configuration file'{
                    Remove-Config $sampleModuleBase
                    Test-Path($sampleConfig) | Should -BeFalse
                }
            }
            Context 'witch -Field'{
                It 'returns $null'{
                    $result = Remove-Config $sampleModuleBase "Field1"
                    $result | Should -BeNullOrEmpty
                }
                It 'does not create a configuration file'{
                    Remove-Config $sampleModuleBase "Field2"
                    Test-Path($sampleConfig) | Should -BeFalse
                }
            }
        }
        Describe 'Save-Config'{
            It 'returns new config'{
                $Config = New-Object PSObject -Property @{
                    Field1 = "Value1"
                    Field2 = "Value2"
                    Field3 = "Value3"
                }
                $result = Save-Config $sampleModuleBase $Config
                $result.Field1 | Should -BeExactly "Value1"
                $result.Field2 | Should -BeExactly "Value2"
                $result.Field3 | Should -BeExactly "Value3"
            }
            It 'creates a valid configuration file'{
                $Config = New-Object PSObject -Property @{
                    Field1 = "Value1"
                    Field2 = "Value2"
                    Field3 = "Value3"
                }
                Save-Config $sampleModuleBase $Config
                $result = Get-Config $sampleModuleBase
                $result.Field1 | Should -BeExactly "Value1"
                $result.Field2 | Should -BeExactly "Value2"
                $result.Field3 | Should -BeExactly "Value3"
            }
        }
    }
}