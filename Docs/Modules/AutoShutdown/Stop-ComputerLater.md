# Stop-ComputerLater

## SYNOPSIS
Stops (shuts down) local computer at a specified time.

## SYNTAX
```
Stop-ComputerLater [[-Minutes] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
Stop-ComputerLater [-Cancel] [-WhatIf] [-Confirm] [<CommonParameters>]
Stop-ComputerLater [-ShutdownNow] [-WhatIf] [-Confirm] [<CommonParameters>]
Stop-ComputerLater [-ShutdownInMinute] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The ``Stop-ComputerLater`` cmdlet shuts down the local computer after two hours by default. You can use the parameters of Stop-ComputerLater to specify the shutdown time or cancel a scheduled shutdown. A minute before the computer is stopped, a notification will be displayed.
## PARAMETERS

### -Minutes
Specifies the time in minutes until the computer stops. Default 120 minutes.
```yaml
Type: String
Required: false
Position: 1
Default value: 120
Accept pipeline input: false
Accept wildcard characters: false
```

### -Cancel
Cancels a scheduled computer shutdown.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -ShutdownNow
Shuts down the computer now.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -ShutdownInMinute
Shuts down the computer in a minue.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -WhatIf
Prompts you for confirmation before running the `Stop-ComputerLater`.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Confirm
Shows what would happen if the `Stop-ComputerLater` runs. The cmdlet is not run.
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

