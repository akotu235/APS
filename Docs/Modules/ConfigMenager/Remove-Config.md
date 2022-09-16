# Remove-Config

## SYNOPSIS
Deletes a configuration file or a single configuration field.

## SYNTAX
```
Remove-Config [-ModuleBase] <String> [[-Field] <String>] [[-ConfigPath] <String>] [[-FileName] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Deletes the configuration file, unless a specific field is specified. Returns the current configuration or ``$null``.
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

### -Field
Specifies the name of the field to be deleted.
```yaml
Type: String
Required: false
Position: 2
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -ConfigPath
Specifies a custom settings file path.
```yaml
Type: String
Required: false
Position: 3
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -FileName
Specifies a custom name for the settings file.
```yaml
Type: String
Required: false
Position: 4
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -WhatIf
Prompts you for confirmation before running the `Remove-Config`.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Confirm
Shows what would happen if the `Remove-Config` runs. The cmdlet is not run.
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

[Save-Config](Save-Config.md)

[Set-ConfigField](Set-ConfigField.md)


