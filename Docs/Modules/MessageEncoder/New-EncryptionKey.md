# New-EncryptionKey

## SYNOPSIS
Generates public and private key for encryption.

## SYNTAX
```
New-EncryptionKey [-Name] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Generates a 4096-bit RSA key pair and places them in the appropriate certificate stores. The keys are also saved in the ``$HOME\.keys`` location, and the private key is password protected. The public key is used to encrypt the message using the ``Protect-Message`` cmdlet and the corresponding private key is used to decrypt it using the ``Unprotect-Message`` cemdlet.
## PARAMETERS

### -Name
Specifies the name of the certificate. This name will be used by users who encrypt the message with the public key.
```yaml
Type: String
Required: true
Position: 1
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -WhatIf
Prompts you for confirmation before running the `New-EncryptionKey`.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Confirm
Shows what would happen if the `New-EncryptionKey` runs. The cmdlet is not run.
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
[Protect-Message](Protect-Message.md)

[Unprotect-Message](Unprotect-Message.md)

