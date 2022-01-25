---
external help file: Ruleset.Remote-help.xml
Module Name: Ruleset.Remote
online version: https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.Remote/Help/en-US/Unregister-SslCertificate.md
schema: 2.0.0
---

# Unregister-SslCertificate

## SYNOPSIS

Unregister SSL certificate for CIM and PowerShell remoting

## SYNTAX

```powershell
Unregister-SslCertificate [[-CertThumbprint] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Unregister-SslCertificate uninstalls SSL certificate and undoes changes
previously done by Register-SslCertificate

## EXAMPLES

### EXAMPLE 1

```powershell
Unregister-SslCertificate
```

## PARAMETERS

### -CertThumbprint

Certificate thumbprint which is to be uninstalled

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Unregister-SslCertificate

## OUTPUTS

### None. Unregister-SslCertificate does not generate any output

## NOTES

TODO: Does not undo registration with WinRM listener

## RELATED LINKS