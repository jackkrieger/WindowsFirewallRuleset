
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
Unit test for Uninstall-DuplicateModule

.DESCRIPTION
Test correctness of Uninstall-DuplicateModule function

.PARAMETER Force
If specified, no prompt to run script is shown

.EXAMPLE
PS> .\Uninstall-DuplicateModule.ps1

.INPUTS
None. You cannot pipe objects to Uninstall-DuplicateModule.ps1

.OUTPUTS
None. Uninstall-DuplicateModule.ps1 does not generate any output

.NOTES
None.
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param (
	[Parameter()]
	[switch] $Force
)

#region Initialization
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1 $PSCmdlet
. $PSScriptRoot\..\ContextSetup.ps1

if (!(Approve-Execute -Accept $Accept -Deny $Deny -Unsafe -Force:$Force)) { exit }
#endregion

if ($Force -or $PSCmdlet.ShouldContinue("Uninstall duplicate modules for testing", "Accept potentially dangerous unit test"))
{
	Enter-Test
	$ModulesToRemove = @("PSReadline", "PowerShellGet", "PackageManagement", "Pester")

	Start-Test "Find-DuplicateModule"
	Find-DuplicateModule -Name $ModulesToRemove

	Start-Test "Uninstall-DuplicateModule -Name Pester"
	Uninstall-DuplicateModule -Name Pester

	Start-Test "Uninstall-DuplicateModule -Name $ModulesToRemove"
	$Result = Uninstall-DuplicateModule -Name $ModulesToRemove
	$Result

	Test-Output $Result -Command Uninstall-DuplicateModule

	Update-Log
	Exit-Test
}
