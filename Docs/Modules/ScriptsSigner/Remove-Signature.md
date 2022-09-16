# Remove-Signature

## SYNOPSIS
Removes the script signature.

## SYNTAX
```
Remove-Signature [-File] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
If the indicated file has a signature block it will be removed.
## PARAMETERS

### -File
Specifies the file to remove the signature.
```yaml
Type: String
Required: true
Position: 1
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -WhatIf
Prompts you for confirmation before running the `Remove-Signature`.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Confirm
Shows what would happen if the `Remove-Signature` runs. The cmdlet is not run.
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
[Add-Signature](Add-Signature.md)


