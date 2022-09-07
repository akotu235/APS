<#
.SYNOPSIS
Reads the given text.
.EXAMPLE
Use-Speech "hello"
#>
function Use-Speech {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true, ValuefromPipeline=$true)]
    [string]$TextToSay
    )
    Start-Job {
        $sc = New-Object -ComObject MSScriptControl.ScriptControl.1
        $sc.Language = 'VBScript'
        $sc.AddCode('
            Function Speech(byval t)
            Set objVoice = CreateObject ("SAPI.SpVoice")
            ObjVoice.speak t
            End Function
        ')
        $sc.codeobject.Speech("$args")
    } -ArgumentList $TextToSay -RunAs32 | Wait-Job | Receive-Job
}