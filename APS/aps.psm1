Clear-Host
if(!($Env:PSModulePath.Split(";") | Where-Object {$PSItem -like "*\Modules\APS*"})){
    $Env:PSModulePath = $Env:PSModulePath + ";$PSScriptRoot\Modules"
}
Write-Host "Windows PowerShell"
Write-Host "Hi! It is $(Get-Date -Format g)"
Write-Host "You are working as $env:UserName"
Write-Host $(Get-Weather)
Write-Host ""