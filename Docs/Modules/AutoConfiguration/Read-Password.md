# Read-Password

## SYNOPSIS
Reads the password from the user.

[\\]: # (END SYNOPSIS)

## SYNTAX
```
Read-Password [[-Prompt] <String>] [[-MinimumLength] <Int32>] [-UppercaseAndLowercaseRequired] [-NumberRequired] [-SpecialCharacterRequired] [<CommonParameters>]
```

[\\]: # (END SYNTAX)

## DESCRIPTION
Reads a password of input from the console. Cmdlet displays asterisks (``*``) in place of the characters that the user types as input. The output of the ``Read-Password`` cmdlet is a SecureString object (System.Security.SecureString). The password is read until the password requirements are met.

[\\]: # (END DESCRIPTION)

## PARAMETERS

### -Prompt
Specifies the text of the prompt. Type a string. If the string includes spaces, enclose it in quotation marks. PowerShell appends a colon (``:``) to the text that you enter.
```yaml
Type: String
Required: false
Position: 1
Default value: Create a password
Accept pipeline input: false
Accept wildcard characters: false
```

### -MinimumLength
Specifies the minimum length of a password.
```yaml
Type: Int32
Required: false
Position: 2
Default value: 0
Accept pipeline input: false
Accept wildcard characters: false
```

### -UppercaseAndLowercaseRequired
Specifies whether uppercase or lowercase letters are required.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -NumberRequired
Specifies whether a digit is required.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -SpecialCharacterRequired
Specifies whether special characters are required.
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

[\\]: # (END PARAMETERS)

## RELATED LINKS
[Confirm-Admin](Confirm-Admin.md)

[Install-SSH](Install-SSH.md)

[New-CodeSigningCert](New-CodeSigningCert.md)

[Protect-SSH](Protect-SSH.md)

[Test-Admin](Test-Admin.md)

[\\]: # (END RELATED LINKS)

[\\]: # (Generated by PSDocsGenerator)
[\\]: # (https://github.com/akotu235/PSDocsGenerator)
