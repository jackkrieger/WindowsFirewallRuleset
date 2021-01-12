
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2019-2021 metablaster zebal@protonmail.ch

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
Outbound firewall rules for WarThunder

.DESCRIPTION
Outbound firewall rules for War Thunder MMO game

.PARAMETER Force
If specified, no prompt to run script is shown.

.PARAMETER Trusted
If specified, rules will be loaded for executables with missing or invalid digital signature.
By default an error is generated and rule isn't loaded.

.EXAMPLE
PS> .\WarThunder.ps1

.INPUTS
None. You cannot pipe objects to WarThunder.ps1

.OUTPUTS
None. WarThunder.ps1 does not generate any output

.NOTES
None.
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param (
	[Parameter()]
	[switch] $Trusted,

	[Parameter()]
	[switch] $Force
)

#region Initialization
. $PSScriptRoot\..\..\..\..\Config\ProjectSettings.ps1 $PSCmdlet
. $PSScriptRoot\..\DirectionSetup.ps1

Initialize-Project -Strict
Import-Module -Name Ruleset.UserInfo

# Setup local variables
$Group = "Games - War Thunder"
$Accept = "Outbound rules for War Thunder game will be loaded, recommended if War Thunder game is installed to let it access to network"
$Deny = "Skip operation, outbound rules for War Thunder game will not be loaded into firewall"

if (!(Approve-Execute -Accept $Accept -Deny $Deny -ContextLeaf $Group -Force:$Force)) { exit }
$PSDefaultParameterValues["Test-ExecutableFile:Force"] = $Trusted -or $SkipSignatureCheck
#endregion

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction Ignore

#
# Steam installation directories
#
$WarThunderRoot = "%ProgramFiles(x86)%\Steam\steamapps\common\War Thunder"

#
# Rules for WarThunder game
#

# Test if installation exists on system
if ((Confirm-Installation "WarThunder" ([ref] $WarThunderRoot)) -or $ForceLoad)
{
	$Program = "$WarThunderRoot\win64\aces.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -Platform $Platform `
			-DisplayName "WarThunder - aces" -Service Any -Program $Program `
			-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $DefaultProfile -InterfaceType $DefaultInterface `
			-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443, 7800-7802, 7850-7854 `
			-LocalUser $UsersGroupSDDL `
			-Description "" | Format-RuleOutput

		New-NetFirewallRule -Platform $Platform `
			-DisplayName "WarThunder - aces" -Service Any -Program $Program `
			-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $DefaultProfile -InterfaceType $DefaultInterface `
			-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 1900, 20010-20500 `
			-LocalUser $UsersGroupSDDL -LocalOnlyMapping $false -LooseSourceMapping $false `
			-Description "" | Format-RuleOutput
	}

	$Program = "$WarThunderRoot\gaijin_downloader.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -Platform $Platform `
			-DisplayName "WarThunder - gajin_downloader" -Service Any -Program $Program `
			-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $DefaultProfile -InterfaceType $DefaultInterface `
			-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 443 `
			-LocalUser $UsersGroupSDDL `
			-Description "" | Format-RuleOutput

		New-NetFirewallRule -Platform $Platform `
			-DisplayName "WarThunder - gajin_downloader" -Service Any -Program $Program `
			-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $DefaultProfile -InterfaceType $DefaultInterface `
			-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 20010 `
			-LocalUser $UsersGroupSDDL -LocalOnlyMapping $false -LooseSourceMapping $false `
			-Description "" | Format-RuleOutput
	}

	$Program = "$WarThunderRoot\gjagent.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -Platform $Platform `
			-DisplayName "WarThunder - gjagent" -Service Any -Program $Program `
			-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $DefaultProfile -InterfaceType $DefaultInterface `
			-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 20010 `
			-LocalUser $UsersGroupSDDL -LocalOnlyMapping $false -LooseSourceMapping $false `
			-Description "" | Format-RuleOutput
	}

	$Program = "$WarThunderRoot\launcher.exe"
	if ((Test-ExecutableFile $Program) -or $ForceLoad)
	{
		New-NetFirewallRule -Platform $Platform `
			-DisplayName "WarThunder - Launcher" -Service Any -Program $Program `
			-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $DefaultProfile -InterfaceType $DefaultInterface `
			-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
			-LocalUser $UsersGroupSDDL `
			-Description "" | Format-RuleOutput

		New-NetFirewallRule -Platform $Platform `
			-DisplayName "WarThunder - Launcher" -Service Any -Program $Program `
			-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $DefaultProfile -InterfaceType $DefaultInterface `
			-Direction $Direction -Protocol UDP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 20010 `
			-LocalUser $UsersGroupSDDL -LocalOnlyMapping $false -LooseSourceMapping $false `
			-Description "" | Format-RuleOutput
	}
}

if ($UpdateGPO)
{
	Invoke-Process gpupdate.exe -NoNewWindow -ArgumentList "/target:computer"
}

Update-Log
