# Get-Geolocation

## SYNOPSIS
Shows location information based on the network.

## SYNTAX
```
Get-Geolocation [-City] [<CommonParameters>]
```

## DESCRIPTION
If given without parameters, the ``Get-Geolocation`` cmdlet will return all data retrieved from ip-api.com such as: country, region, city, zip code, co-ordinates, timezone, isp name and ip addres
## PARAMETERS

### -City
Returns the city name of your location.
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

