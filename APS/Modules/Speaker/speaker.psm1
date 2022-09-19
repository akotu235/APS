<#
.SYNOPSIS
Changes text to speech.
.DESCRIPTION
Speaks the text specified in the parameter aloud.
.EXAMPLE
Use-Speech "hello"
#>
function Use-Speech {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true, ValuefromPipeline=$true)]
    [System.String]$TextToSpeech
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
    } -ArgumentList $TextToSpeech -RunAs32 >> $null
}