# Show-Notification

## SYNOPSIS
Shows the notification.

## SYNTAX
```
Show-Notification [-Text] <String> [-Title <String>] [<CommonParameters>]
Show-Notification [-Text] <String> [-Title <String>] [-OnlyVoiceNotification] [<CommonParameters>]
Show-Notification [-Text] <String> [-Title <String>] [-VoiceNotification] [<CommonParameters>]
```

## DESCRIPTION
Immediately shows the notification without saving to the schedule of tasks. It can be called when an event occurs.
## PARAMETERS

### -Text
Specifies the content of the notification. This content will be spoken when the voice prompts are not disabled.
```yaml
Type: String
Required: true
Position: 1
Default value: none
Accept pipeline input: true (ByValue)
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

### -VoiceNotification
Determines whether the voice prompts are to be enabled. Disabled by default.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```
### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, [see about_CommonParameters](https://docs.microsoft.com/pl-pl/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## RELATED LINKS
[Set-Notification](Set-Notification.md)


