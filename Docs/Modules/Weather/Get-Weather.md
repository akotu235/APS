# Get-Weather

## SYNOPSIS
Shows the current weather.

## SYNTAX
```
Get-Weather [[-City] <String>] [-Units <String>] [<CommonParameters>]
Get-Weather [[-City] <String>] [-Data] [-Units <String>] [<CommonParameters>]
Get-Weather [[-City] <String>] [-Detailed] [-Units <String>] [<CommonParameters>]
Get-Weather [-RestoreDefaultConfig] [<CommonParameters>]
Get-Weather [-SetDefaultCity <String>] [-SetUnits <String>] [-Geolocalization <String>] [-SetAppId <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets current weather data from openweathermap.org.
## PARAMETERS

### -City
Defines for which city the weather data is to be displayed.
```yaml
Type: String
Required: false
Position: 1
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Detailed
Shows detailed data.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -Data
Returns the original object taken from openweathermap.org.
```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -Units
Determines the units of displayed results. Valid values are standard, metric and imperial.
```yaml
Type: String
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -RestoreDefaultConfig

```yaml
Type: SwitchParameter
Required: false
Position: named
Default value: False
Accept pipeline input: false
Accept wildcard characters: false
```

### -SetDefaultCity
Specifies the default city.
```yaml
Type: String
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -SetUnits
Specifies the default units.
```yaml
Type: String
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -Geolocalization
Defines the settings for retrieving location data based on the network. Valid values are enable and disable.
```yaml
Type: String
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```

### -SetAppId
Specifies the AppId.
```yaml
Type: String
Required: false
Position: named
Default value: none
Accept pipeline input: false
Accept wildcard characters: false
```
### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, [see about_CommonParameters](https://docs.microsoft.com/pl-pl/powershell/module/microsoft.powershell.core/about/about_commonparameters).


