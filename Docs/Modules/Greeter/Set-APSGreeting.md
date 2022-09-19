# Set-APSGreeting

## SYNOPSIS
Saves in the configuration file which information is to be displayed using the ``Show-APSGreeting`` function.

## SYNTAX
```
Set-APSGreeting [-WhatIf] [-Confirm] [<CommonParameters>]
Set-APSGreeting [-Default] [-WhatIf] [-Confirm] [<CommonParameters>]
Set-APSGreeting [-Disable] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The ``Set-APSGreeting`` cmdlet running without parameters will help the user select the items to display.
## PARAMETERS

### -Default
Restores the default settings.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -Disable
Disables ``Show-APSGreeting`` functions.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -WhatIf
Prompts you for confirmation before running the `Set-APSGreeting`.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Confirm
Shows what would happen if the `Set-APSGreeting` runs. The cmdlet is not run.
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
[Show-APSGreeting](Show-APSGreeting.md)


