
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2022, 2023 metablaster zebal@protonmail.ch

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
Unit test for Invoke-WinCommand

.DESCRIPTION
Test correctness of Invoke-WinCommand function

.PARAMETER Domain
If specified, only remoting tests against specified computer name are performed

.PARAMETER Force
If specified, this unit test runs without prompt to allow execute

.EXAMPLE
PS> Invoke-WinCommand

.INPUTS
None. You cannot pipe objects to Invoke-WinCommand

.OUTPUTS
None. Invoke-WinCommand does not generate any output

.NOTES
None.
#>

#Requires -Version 7.1
#Requires -PSEdition Core

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
#Endregion

Enter-Test "Invoke-WinCommand"

if ($Domain -ne [System.Environment]::MachineName)
{
	Start-Test "Remote default"
	Invoke-WinCommand { param ($name) "Hello $name, how are you?"; $PSVersionTable.PSVersion } Jeffrey -Domain $Domain
}
else
{
	Start-Test "Default test"
	$Result = Invoke-WinCommand { param ($name) "Hello $name, how are you?"; $PSVersionTable.PSVersion } Jeffrey
	$Result

	Test-Output $Result -Command Invoke-WinCommand
}

Update-Log
Exit-Test
