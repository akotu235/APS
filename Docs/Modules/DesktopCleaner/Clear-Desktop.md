# Clear-Desktop

## SYNOPSIS
Cleans the desktop.

## SYNTAX
```
Clear-Desktop [-SetDefaultExceptionList] [-ExceptionList] [-SaveCurrentDesktopState] [-AddException <String>] [-Archives] [<CommonParameters>]
Clear-Desktop -Autorun [-SetDefaultExceptionList] [-ExceptionList] [-SaveCurrentDesktopState] [-AddException <String>] [-Archives] [<CommonParameters>]
Clear-Desktop -Disable [-SetDefaultExceptionList] [-ExceptionList] [-SaveCurrentDesktopState] [-AddException <String>] [-Archives] [<CommonParameters>]
```

## DESCRIPTION
Moves all files not in the exceptions list to the desktop archive.
## PARAMETERS

### -Autorun
Runs cleanup on system startup.
```yaml
Type: SwitchParameter
Required: true
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -Disable
Disable autorun.
```yaml
Type: SwitchParameter
Required: true
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -SetDefaultExceptionList
Restores the default exception list.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -ExceptionList
Opens the exception list in the notepad.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -SaveCurrentDesktopState
Adds all files currently on the desktop to the exceptions.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -AddException
Specifies the name of the exception to be added.
```yaml
Type: String
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Archives
Opens the desktop archive in the file explorer.
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


