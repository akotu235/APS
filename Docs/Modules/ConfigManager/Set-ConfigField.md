# Set-ConfigField

## SYNOPSIS
Sets a single field in the settings file.

## SYNTAX
```
Set-ConfigField [-ModuleBase] <String> [-Field] <String> [-Value] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
Set-ConfigField [-CustomPath] <String> [-Field] <String> [-Value] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a new field or overwrites an existing one in the settings file. Returns an updated psobject configuration.
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

### -Field
Specifies the name of the setting to save. If it already exists, it overwrites it.
```yaml
Type: String
Required: true
Position: 2
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Value
Specifies the setting value for the field.
```yaml
Type: String
Required: true
Position: 3
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -WhatIf
Prompts you for confirmation before running the `Set-ConfigField`.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Confirm
Shows what would happen if the `Set-ConfigField` runs. The cmdlet is not run.
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

[Save-Config](Save-Config.md)


