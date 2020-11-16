---
external help file: Ruleset.Compatibility-help.xml
Module Name: Ruleset.Compatibility
online version: https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.Compatibility/Help/en-US/Import-WinModule.md
schema: 2.0.0
---

# Import-WinModule

## SYNOPSIS

Import a compatibility module.

## SYNTAX

```none
Import-WinModule [[-Name] <String[]>] [-Exclude <String[]>] [-ComputerName <String>]
 [-ConfigurationName <String>] [-Prefix <String>] [-DisableNameChecking] [-NoClobber] [-Force]
 [-Credential <PSCredential>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION

This command allows you to import proxy modules from a local or remote session.
These proxy modules will allow you to invoke cmdlets that are not directly supported in this version of PowerShell.

There are commands in the Windows PowerShell core modules that don't exist natively in PowerShell Core.
If these modules are imported, proxies will only be created for the missing commands.
Commands that already exist in PowerShell Core will not be overridden.
The modules subject to this restriction are:

- Microsoft.PowerShell.Management
- Microsoft.PowerShell.Utility
- Microsoft.PowerShell.Security
- Microsoft.PowerShell.Diagnostics

By default, when executing, the current compatibility session is used,
or, in the case where there is no existing session, a new default session will be created.
This behavior can be overridden using the additional parameters on the command.

## EXAMPLES

### EXAMPLE 1

```powershell
Import-WinModule PnpDevice; Get-Command -Module PnpDevice
```

This example imports the 'PnpDevice' module.

### EXAMPLE 2

```powershell
Import-WinModule Microsoft.PowerShell.Management; Get-Command Get-EventLog
```

This example imports one of the core Windows PowerShell modules containing commands
not natively available in PowerShell Core such as 'Get-EventLog'.
Only commands not already present in PowerShell Core will be imported.

### EXAMPLE 3

```powershell
Import-WinModule PnpDevice -Verbose -Force
```

This example forces a reload of the module 'PnpDevice' with verbose output turned on.

## PARAMETERS

### -Name

Specifies the name of the module to be imported.
Wildcards can be used.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: *
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclude

A list of wildcard patterns matching the names of modules that
should not be imported.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerName

If you don't want to use the default compatibility session, use
this parameter to specify the name of the computer on which to create
the compatibility session.
(Defaults to 'localhost')

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: cn

Required: False
Position: Named
Default value: localhost
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigurationName

Specifies the configuration to connect to when creating the compatibility session
(Defaults to 'Microsoft.PowerShell')

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Microsoft.PowerShell
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prefix

Prefix to prepend to the imported command names

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisableNameChecking

Disable warnings about non-standard verbs

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoClobber

Don't overwrite any existing function definitions.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Force reloading the module

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

The credential to use when creating the compatibility session using the target machine/configuration

```yaml
Type: System.Management.Automation.PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru

If present, the ModuleInfo objects will be written to the output pipe as deserialized (PSObject) objects.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Import-WinModule

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS