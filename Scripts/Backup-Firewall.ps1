
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2020-2022 metablaster zebal@protonmail.ch

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

<#PSScriptInfo

.VERSION 0.13.1

.GUID bdaf45b1-a6cf-48b8-a87d-cde4f30eb574

.AUTHOR metablaster zebal@protonmail.com

.REQUIREDSCRIPTS ProjectSettings.ps1

.EXTERNALMODULEDEPENDENCIES Ruleset.Logging, Ruleset.Initialize, Ruleset.Utility, Ruleset.Firewall
#>

<#
.SYNOPSIS
Export all firewall rules and settings

.DESCRIPTION
Backup-Firewall.ps1 script exports all GPO firewall rules and settings to "Exports" directory

.PARAMETER Domain
Target computer from which to backup firewall, default is local GPO.

.PARAMETER Path
Path into which to save file.
Wildcard characters are supported.

.PARAMETER Force
If specified, no prompt for confirmation is shown to perform actions

.EXAMPLE
PS> Backup-Firewall

.EXAMPLE
PS> Backup-Firewall -Domain Server01

.EXAMPLE
PS> Backup-Firewall -Path "C:\MyFolder" -Force

.INPUTS
None. You cannot pipe objects to Backup-Firewall.ps1

.OUTPUTS
None. Backup-Firewall.ps1 does not generate any output

.NOTES
None.

.LINK
https://github.com/metablaster/WindowsFirewallRuleset/tree/master/Scripts
#>

#Requires -Version 5.1

[CmdletBinding()]
[OutputType([void])]
param (
	[Parameter()]
	[Alias("ComputerName", "CN", "PolicyStore")]
	[string] $Domain = [System.Environment]::MachineName,

	[Parameter()]
	[SupportsWildcards()]
	[System.IO.DirectoryInfo] $Path = "$ProjectRoot\Exports",

	[Parameter()]
	[switch] $Force
)

#region Initialization
. $PSScriptRoot\..\Config\ProjectSettings.ps1 $PSCmdlet
Write-Debug -Message "[$ThisScript] ParameterSet = $($PSCmdlet.ParameterSetName):$($PSBoundParameters | Out-String)"
Initialize-Project -Strict

# User prompt
$Accept = "Accpet exporting firewall rules and settings to file"
$Deny = "Abort operation, no firewall rules or settings will be exported"
if (!(Approve-Execute -Accept $Accept -Deny $Deny -Force:$Force)) { exit }
#endregion

$Path = Resolve-FileSystemPath $Path -Create
if (!$Path)
{
	# Errors if any, reported by Resolve-FileSystemPath
	return
}

$StopWatch = [System.Diagnostics.Stopwatch]::new()
$StopWatch.Start()

# Export all rules and settings from GPO
Export-RegistryRule -Path $Path -FileName "FirewallRules.csv" -Domain $Domain
Export-FirewallSetting -Path $Path -FileName "FirewallSettings.json" -Domain $Domain

$StopWatch.Stop()

$TotalHours = $StopWatch.Elapsed | Select-Object -ExpandProperty Hours
$TotalMinutes = $StopWatch.Elapsed | Select-Object -ExpandProperty Minutes
$TotalSeconds = $StopWatch.Elapsed | Select-Object -ExpandProperty Seconds
Write-Information -Tags $ThisScript -MessageData "INFO: Time needed to export firewall was: $TotalHours hours and $TotalMinutes minutes and $TotalSeconds seconds"

Update-Log

<# STATS for Export-FirewallRule
# NOTE: With Export-FirewallRule Export speed is 10 rules per minute
# 450 rules in 46 minutes on 3,6 Ghz quad core CPU with 16GB single channel RAM @2400 Mhz
# NOTE: to speed up a little add following to defender exclusions:
# C:\Windows\System32\wbem\WmiPrvSE.exe

Outbound export took over 1h and the result was 1 minute
Time needed to export inbound rules was: 33 minutes
Total time needed to export entire firewall was: 34 minutes (1h 34m)

With Export-RegistryRule export speed is less than a minute!
#>
