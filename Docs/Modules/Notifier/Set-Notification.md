# Set-Notification

## SYNOPSIS
Sets a notification.

## SYNTAX
```
Set-Notification [[-Time] <DateTime>] [-Text] <String> [-Title <String>] [-Save] [-WhatIf] [-Confirm] [<CommonParameters>]
Set-Notification [[-Time] <DateTime>] [-Text] <String> [-Title <String>] [-OnlyVoiceNotification] [-Save] [-WhatIf] [-Confirm] [<CommonParameters>]
Set-Notification [[-Time] <DateTime>] [-Text] <String> [-Title <String>] [-DisableVoiceNotification] [-Save] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sets a notification at a specific time. By default, the notification is made both by voice and in the form of a pop-up toast.
## PARAMETERS

### -Time
Defines the time the message appears. If not set, the notification will show after 3 seconds.
```yaml
Type: DateTime
Required: false
Position: 1
Default value: $((Get-Date).AddSeconds(3))
Accept pipeline input: false
Accept wildcard characters: false
```

### -Text
Specifies the content of the notification. This content will be spoken when the voice prompts are not disabled.
```yaml
Type: String
Required: true
Position: 2
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Title
Specifies the title of the notification. It is not spoken but visible on the pop-up toste.
```yaml
Type: String
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -OnlyVoiceNotification
It turns off the toast pop-up, leaving voice prompts.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -DisableVoiceNotification
Determines whether the voice prompts are to be disabled. Enabled by default.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -Save
Saves the task in the task schedule. By default they are removed after execution.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -WhatIf
Prompts you for confirmation before running the `Set-Notification`.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Confirm
Shows what would happen if the `Set-Notification` runs. The cmdlet is not run.
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
[Show-Notification](Show-Notification.md)


