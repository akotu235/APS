$ModulePath = Convert-Path "$PSScriptRoot\..\APS"
Publish-Module -Path $ModulePath -NuGetApiKey $Env:APIKEY