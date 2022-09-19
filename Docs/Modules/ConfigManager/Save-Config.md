# Save-Config

## SYNOPSIS
Creates a configuration file.

## SYNTAX
```
Save-Config [-ModuleBase] <String> [-Config] <PSObject> [-WhatIf] [-Confirm] [<CommonParameters>]
Save-Config [-CustomPath] <String> [-Config] <PSObject> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a configuration file or overwrites an existing one. Returns the current configuration.
## PARAMETERS

### -ModuleBase
Specifies the location of the module.
```yaml
Type: String
Required: true
Position: 1
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -CustomPath
Specifies a custom settings file path.
```yaml
Type: String
Required: true
Position: 1
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Config
Specifies the psobject type configurations to save.
```yaml
Type: PSObject
Required: true
Position: 2
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -WhatIf
Prompts you for confirmation before running the `Save-Config`.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Confirm
Shows what would happen if the `Save-Config` runs. The cmdlet is not run.
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
[Get-Config](Get-Config.md)

[Remove-Config](Remove-Config.md)

[Set-ConfigField](Set-ConfigField.md)


