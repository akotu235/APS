# Add-Signature

## SYNOPSIS
Adds an Authenticode signature to a PowerShell script or other file.

## SYNTAX
```
Add-Signature [-File] <String> [<CommonParameters>]
```

## DESCRIPTION
The ``Add-Signature`` cmdlet adds an Authenticode signature to the specified file using the installed local certificate. If no certificate is installed, the user is asked if he wants to create a new local certificate. In a PowerShell script file, the signature takes the form of a block of text that indicates the end of the instructions that are executed in the script. If there is a signature in the file when this cmdlet runs, that signature is removed.
## PARAMETERS

### -File
Specifies the file to be signed. If a directory is selected, all scripts in it and in subdirectories will be signed.
```yaml
Type: String
Required: true
Position: 1
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```
### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, [see about_CommonParameters](https://docs.microsoft.com/pl-pl/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## RELATED LINKS
[Remove-Signature](Remove-Signature.md)


