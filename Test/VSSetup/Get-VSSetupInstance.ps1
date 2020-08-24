
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

#
# Unit test for Get-VSSetupInstance
#
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1

# Check requirements for this project
Initialize-Project

# Imports
. $PSScriptRoot\ContextSetup.ps1
Import-Module -Name Project.AllPlatforms.Logging

# Ask user if he wants to load these rules
Update-Context $TestContext $ThisScript @Logs
if (!(Approve-Execute @Logs)) { exit }

Enter-Test $ThisScript

$NullVariable = $null
$EmptyVariable = Get-VSSetupInstance -All @Logs |
Select-VSSetupInstance -Require 'FailureTest' -Latest @Logs |
Select-Object -ExpandProperty InstallationPath @Logs

Start-Test "Get-VSSetupInstance"
Get-VSSetupInstance @Logs

Start-Test "Get-VSSetupInstance path"
Get-VSSetupInstance @Logs |
Select-VSSetupInstance -Latest @Logs |
Select-Object -ExpandProperty InstallationPath @Logs

Start-Test "Test-Installation 'NullVariable' $NullVariable"
Test-Installation "MicrosoftOffice" ([ref] $NullVariable) @Logs

Start-Test "Test-Installation 'EmptyVariable' $EmptyVariable"
Test-Installation "MicrosoftOffice" ([ref] $EmptyVariable) @Logs

Update-Log
Exit-Test
