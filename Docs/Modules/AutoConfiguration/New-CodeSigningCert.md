# New-CodeSigningCert

## SYNOPSIS
Creates a new code signing certificate.

## SYNTAX
```
New-CodeSigningCert [[-Name] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates and secures a script signing certificate and places it in the appropriate certificate store.
## PARAMETERS

### -Name

```yaml
Type: String
Required: false
Position: 1
Default value: PowerShell Local CA
Accept pipeline input: false
Accept wildcard characters: false
```

### -WhatIf
Prompts you for confirmation before running the `New-CodeSigningCert`.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Confirm
Shows what would happen if the `New-CodeSigningCert` runs. The cmdlet is not run.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```
### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, [see about_CommonParameters](https://docs.microsoft.com/pl-pl/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## RELATED LINKS
[Confirm-Admin](Confirm-Admin.md)

[Install-SSH](Install-SSH.md)

[Protect-SSH](Protect-SSH.md)

[Read-Password](Read-Password.md)

[Test-Admin](Test-Admin.md)


