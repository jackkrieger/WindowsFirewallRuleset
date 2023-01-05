
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
Unit test for Convert-ArrayToList

.DESCRIPTION
Test correctness of Convert-ArrayToList function

.PARAMETER Force
If specified, no prompt to run script is shown

.EXAMPLE
PS> .\Convert-ArrayToList.ps1

.INPUTS
None. You cannot pipe objects to Convert-ArrayToList.ps1

.OUTPUTS
None. Convert-ArrayToList.ps1 does not generate any output
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

Initialize-Project
if (!(Approve-Execute -Accept $Accept -Deny $Deny -Force:$Force)) { exit }
#endregion

Enter-Test -Private "Convert-ArrayToList"

Start-Test "null"
Convert-ArrayToList
$null | Convert-ArrayToList

Start-Test "default"
$Result = Convert-ArrayToList -InputObject @("192.168.1.1", "192.168.2.1", "172.24.33.100")
$Result

Start-Test "pipeline"
@("192.168.1.1", "192.168.2.1", $null, "172.24.33.100") | Convert-ArrayToList

Test-Output $Result -Command Convert-ArrayToList

Update-Log
Exit-Test -Private
