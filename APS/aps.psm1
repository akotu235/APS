if(-not $Env:PSModulePath.Contains($PSScriptRoot)){
    $Env:PSModulePath = $Env:PSModulePath + ";$PSScriptRoot\Modules"
}
Show-APSGreeting