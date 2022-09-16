# Get-Config

## SYNOPSIS
Returns the settings.

## SYNTAX
```
Get-Config [-ModuleBase] <String> [[-Field] <String>] [[-ConfigPath] <String>] [[-FileName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns configuration of the given module or contained in the indicated xml file.
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
Returns a single setting field based on the name.
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
### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, [see about_CommonParameters](https://docs.microsoft.com/pl-pl/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## RELATED LINKS
[Remove-Config](Remove-Config.md)

[Save-Config](Save-Config.md)

[Set-ConfigField](Set-ConfigField.md)


