# Confirm-Admin

## SYNOPSIS
Run as administrator.

## SYNTAX
```
Confirm-Admin [[-ScriptBlock] <String>] [-NoExit] [<CommonParameters>]
```

## DESCRIPTION
Opens a new powershell session as administrator and executes the script block specified in the parameter.
## PARAMETERS

### -ScriptBlock
Specifies the commands to run as administrator. Enclose the commands in braces (``{ }``) to create a script block.
```yaml
Type: String
Required: false
Position: 1
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -NoExit
Does not exit after running commands.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: True
Accept pipeline input: false
Accept wildcard characters: false
```
### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, [see about_CommonParameters](https://docs.microsoft.com/pl-pl/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## RELATED LINKS
[Install-SSH](Install-SSH.md)

[New-CodeSigningCert](New-CodeSigningCert.md)

[Protect-SSH](Protect-SSH.md)

[Read-Password](Read-Password.md)

[Test-Admin](Test-Admin.md)


