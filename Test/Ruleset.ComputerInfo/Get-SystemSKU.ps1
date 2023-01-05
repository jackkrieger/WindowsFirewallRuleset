
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2020-2023 metablaster zebal@protonmail.ch

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
Unit test for Get-SystemSKU

.DESCRIPTION
Test correctness of Get-SystemSKU function

.PARAMETER Domain
If specified, only remoting tests against specified computer name are performed

.PARAMETER Force
If specified, no prompt to run script is shown

.EXAMPLE
PS> .\Get-SystemSKU.ps1

.INPUTS
None. You cannot pipe objects to Get-SystemSKU.ps1

.OUTPUTS
None. Get-SystemSKU.ps1 does not generate any output

.NOTES
None.
#>

#Requires -Version 5.1

[CmdletBinding()]
param (
	[Parameter()]
	[Alias("ComputerName", "CN")]
	[string] $Domain = [System.Environment]::MachineName,

	[Parameter()]
	[switch] $Force
)

#region Initialization
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1 $PSCmdlet -Domain $Domain
. $PSScriptRoot\..\ContextSetup.ps1

Initialize-Project
if (!(Approve-Execute -Accept $Accept -Deny $Deny -Force:$Force)) { exit }
#endregion

Enter-Test "Get-SystemSKU"

if ($Domain -ne [System.Environment]::MachineName)
{
	Start-Test "Remote CimSession"
	Get-SystemSKU -CimSession $CimServer

	Start-Test "Remote computer"
	Get-SystemSKU -Domain $Domain
}
else
{
	Start-Test "default"
	Get-SystemSKU -CimSession $CimServer

	Start-Test "-SKU 4"
	$Result = Get-SystemSKU -SKU 48
	$Result

	#
	# TODO: For these tests to succeed we need to have HTTP enabled WinRM server
	#
	Start-Test "Pipeline" -Command Get-SystemSKU -Force
	@($([System.Environment]::MachineName), "INVALID_COMPUTER") | Get-SystemSKU -EV +TestEV -EA SilentlyContinue
	Restore-Test

	Start-Test "-Domain"
	Get-SystemSKU -Domain $([System.Environment]::MachineName)

	Test-Output $Result -Command Get-SystemSKU
}

Update-Log
Exit-Test
