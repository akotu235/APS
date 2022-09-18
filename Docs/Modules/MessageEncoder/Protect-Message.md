# Protect-Message

## SYNOPSIS
Encrypts the message.

## SYNTAX
```
Protect-Message [-Message] <String> [<CommonParameters>]
```

## DESCRIPTION
Encrypts the message with the indicated rsa public key and copies it to the clipboard.
## PARAMETERS

### -Message
Specifies the message to encrypt.
```yaml
Type: String
Required: true
Position: 1
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```
### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, [see about_CommonParameters](https://docs.microsoft.com/pl-pl/powershell/module/microsoft.powershell.core/about/about_commonparameters).

## RELATED LINKS
[New-EncryptionKey](New-EncryptionKey.md)

[Unprotect-Message](Unprotect-Message.md)

