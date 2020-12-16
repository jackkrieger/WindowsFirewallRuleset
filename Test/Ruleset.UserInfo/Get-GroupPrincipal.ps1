
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2019, 2020 metablaster zebal@protonmail.ch

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
Unit test for Get-GroupPrincipal

.DESCRIPTION
Unit test for Get-GroupPrincipal

.EXAMPLE
PS> .\Get-GroupPrincipal.ps1

.INPUTS
None. You cannot pipe objects to Get-GroupPrincipal.ps1

.OUTPUTS
None. Get-GroupPrincipal.ps1 does not generate any output

.NOTES
None.
#>

#region Initialization
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1
New-Variable -Name ThisScript -Scope Private -Option Constant -Value ((Get-Item $PSCommandPath).Basename)

# Check requirements
Initialize-Project -Abort

# Imports
. $PSScriptRoot\ContextSetup.ps1
Import-Module -Name Ruleset.UserInfo

# User prompt
Update-Context $TestContext $ThisScript
if (!(Approve-Execute -Accept $Accept -Deny $Deny)) { exit }
#endregion

Enter-Test

Start-Test "Get-GroupPrincipal Users"
$UsersTest = Get-GroupPrincipal "Users"
$UsersTest

Start-Test "Get-GroupPrincipal Disabled Administrators"
Get-GroupPrincipal "Administrators" -Disabled

Start-Test "Get-GroupPrincipal Users, Administrators -CIM"
$CIMTest = Get-GroupPrincipal "Users", "Administrators" -Computer "localhost" -CIM
$CIMTest

Start-Test "Get-GroupPrincipal Disabled Users, Administrators -CIM"
Get-GroupPrincipal "Users", "Administrators" -Computer "localhost" -CIM -Disabled

Start-Test "Failure test"
$FailedUsers = Get-GroupPrincipal "Nonexistent Users" -ErrorAction SilentlyContinue
$FailedUsers

Test-Output $UsersTest -Command Get-GroupPrincipal

Update-Log
Exit-Test
