# New-APSTask

## SYNOPSIS
Registers a scheduled task definition on a local computer.

## SYNTAX
```
New-APSTask [-Command] <String> [[-StartTime] <DateTime>] [[-TaskName] <String>] [[-WindowStyle] <String>] [-Save] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The ``New-APSTask`` cmdlet registers a scheduled task definition on a local computer. This task executes PowerShell commands at the specified time.
## PARAMETERS

### -Command
Specifies the commands to be executed.
```yaml
Type: String
Required: true
Position: 1
Default value: none
Accept pipeline input: true (ByValue)
Accept wildcard characters: false
```

### -StartTime
Defines the execution time of the commands given in the ``-Command`` parameter.
```yaml
Type: DateTime
Required: false
Position: 2
Default value: $((Get-Date).AddSeconds(3))
Accept pipeline input: false
Accept wildcard characters: false
```

### -TaskName
Specifies the name of the task. By default APS Task (<cmdlet>).
```yaml
Type: String
Required: false
Position: 3
Default value: APS Task($($Command.TrimStart('"& {').Split(" ")[0]))
Accept pipeline input: false
Accept wildcard characters: false
```

### -WindowStyle
Set the window style for the session. Valid values are Normal, Minimized, Maximized and Hidden. Default Hidden.
```yaml
Type: String
Required: false
Position: 4
Default value: Hidden
Accept pipeline input: false
Accept wildcard characters: false
```

### -Save
Specifies whether the task after execution is to be kept in the task schedule.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -WhatIf
Prompts you for confirmation before running the `New-APSTask`.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Confirm
Shows what would happen if the `New-APSTask` runs. The cmdlet is not run.
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


