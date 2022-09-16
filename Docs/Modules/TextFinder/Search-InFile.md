# Search-InFile

## SYNOPSIS
Searches for a phrase in a file.

## SYNTAX
```
Search-InFile [[-Phrase] <String>] [-Path <String>] [-Recurse] [-CaseSensitive] [-StopWhenFinds] [<CommonParameters>]
Search-InFile [-AsSecure] [-Path <String>] [-Recurse] [-CaseSensitive] [<CommonParameters>]
```

## DESCRIPTION
Searches a file line by line without consuming RAM memory.
## PARAMETERS

### -Phrase
Specifies the search term.
```yaml
Type: String
Required: false
Position: 1
Default value: none
Accept pipeline input: false
Accept wildcard characters: true
```

### -AsSecure
Hides the searched phrase.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -Path
Specifies the path to the file or directory to be searched.
```yaml
Type: String
Required: false
Position: named
Default value: .\
Accept pipeline input: false
Accept wildcard characters: false
```

### -Recurse
Searches for items in specified locations and in all location children.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -CaseSensitive
Matches a case-sensitive phrase.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -StopWhenFinds
Stops searching after the first found item.
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


