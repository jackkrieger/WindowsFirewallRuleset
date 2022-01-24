
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

<#
.SYNOPSIS
Unit test for Export-FirewallRule

.DESCRIPTION
Test correctness of Export-FirewallRule function

.PARAMETER Force
If specified, no prompt to run script is shown

.EXAMPLE
PS> .\Export-FirewallRule.ps1

.INPUTS
None. You cannot pipe objects to Export-FirewallRule.ps1

.OUTPUTS
None. Export-FirewallRule.ps1 does not generate any output

.NOTES
None.
#>

#Requires -Version 5.1

[CmdletBinding()]
param (
	[Parameter()]
	[switch] $Force
)

#region Initialization
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1 $PSCmdlet
. $PSScriptRoot\..\ContextSetup.ps1

Initialize-Project -Strict
if (!(Approve-Execute -Accept $Accept -Deny $Deny -Unsafe -Force:$Force)) { exit }
#endregion

Enter-Test "Export-FirewallRule"

$Exports = "$ProjectRoot\Exports"

# TODO: need to test failure cases, see also module todo's for more info

if ($Force -or $PSCmdlet.ShouldContinue("Export firewall rules", "Accept slow unit test"))
{
	Start-Test "-DisplayGroup"
	Export-FirewallRule -DisplayGroup "" -Outbound -Folder $Exports -FileName "GroupExport" # -DisplayName "Gwent"

	Start-Test "-DisplayGroup"
	Export-FirewallRule -DisplayGroup "Broadcast" -Outbound -Folder $Exports -FileName "GroupExport"

	Start-Test "-DisplayName NONEXISTENT"
	Export-FirewallRule -DisplayName "NONEXISTENT" -Folder $Exports -FileName "NamedExport1"

	Start-Test "-DisplayName"
	Export-FirewallRule -DisplayName "Domain Name System" -Folder $Exports -FileName "NamedExport1"

	Start-Test "-DisplayName -JSON"
	Export-FirewallRule -DisplayName "Domain Name System" -Folder $Exports -JSON -Append -FileName "NamedExport2"

	Start-Test "-Outbound -Disabled -Allow"
	Export-FirewallRule -Outbound -Disabled -Allow -Folder $Exports -FileName "OutboundExport"

	Start-Test "-Inbound -Enabled -Block -JSON"
	Export-FirewallRule -Inbound -Enabled -Block -Folder $Exports -JSON -FileName "InboundExport"

	Start-Test "-DisplayGroup"
	$Result = Export-FirewallRule -DisplayName "Microsoft.BingWeather" -Outbound -Folder $Exports -FileName "StoreAppExport" # -DisplayName "Gwent"
	$Result

	Test-Output $Result -Command Export-FirewallRule
}

Update-Log
Exit-Test
