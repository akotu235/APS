BeforeAll{
    $ModuleName = "Geolocalization"
    Get-Module $ModuleName | Remove-Module -Force
    Import-Module "$PSScriptRoot\..\APS\Modules\$ModuleName"
}
Describe 'Get-Geolocation'{
    Context 'no parameters' {
        It 'contains a status field equal to "success"'{
            $status = (Get-Geolocation | select status).status
            $status  | Should -Be 'success'
        }
    }
    Context 'with -City'{
        It 'returns the name of the city'{
            $city = Get-Geolocation -City
            $city  | Should -BeOfType string
        }
    }
}