
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2020, 2021 metablaster zebal@protonmail.ch

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
# Module manifest for module "Ruleset.ProgramInfo"
#
# Generated by: metablaster
#
# Generated on: 11.2.2020.
#

@{
	# Script module or binary module file associated with this manifest, (alias: ModuleToProcess)
	# Previous versions of PowerShell called this element the ModuleToProcess.
	# NOTE: To create a manifest module this must be empty,
	# the name of a script module (.psm1) creates a script module,
	# the name of a binary module (.exe or .dll) creates a binary module.
	RootModule = "Ruleset.ProgramInfo.psm1"

	# Version number of this module.
	ModuleVersion = "0.10.1"

	# Supported PSEditions
	CompatiblePSEditions = @(
		"Core"
		"Desktop"
	)

	# ID used to uniquely identify this module
	GUID = "49f11777-b8b6-4fed-bd82-32c8f48db81e"

	# Author of this module
	Author = "metablaster zebal@protonmail.ch"

	# Company or vendor of this module
	# CompanyName = "Unknown"

	# Copyright statement for this module
	Copyright = "Copyright (C) 2019-2021 metablaster zebal@protonmail.ch"

	# Description of the functionality provided by this module
	Description = "Query software installed on local and remote Windows systems"

	# Minimum version of the PowerShell engine required by this module
	# Valid values are: 1.0 / 2.0 / 3.0 / 4.0 / 5.0 / 5.1 / 6.0 / 6.1 / 6.2 / 7.0 / 7.1
	PowerShellVersion = "5.1"

	# Name of the Windows PowerShell host required by this module
	# PowerShellHostName = ""

	# Minimum version of the Windows PowerShell host required by this module
	# PowerShellHostVersion = ""

	# Minimum version of Microsoft .NET Framework required by this module.
	# This prerequisite is valid for the PowerShell Desktop edition only.
	# Valid values are: 1.0 / 1.1 / 2.0 / 3.0 / 3.5 / 4.0 / 4.5
	DotNetFrameworkVersion = "4.5"

	# Minimum version of the common language runtime (CLR) required by this module.
	# This prerequisite is valid for the PowerShell Desktop edition only.
	# Valid values are: 1.0 / 1.1 / 2.0 / 4.0
	CLRVersion = "4.0"

	# Processor architecture (None, X86, Amd64) required by this module.
	# Valid values are: x86 / AMD64 / Arm / IA64 / MSIL / None (unknown or unspecified).
	ProcessorArchitecture = "None"

	# Modules that must be imported into the global environment prior to importing this module
	# RequiredModules = @()

	# Assemblies that must be loaded prior to importing this module
	# Required by Get-AppCapability
	RequiredAssemblies = @("Microsoft.Windows.Appx.PackageManager.Commands")

	# Script files (.ps1) that are run in the caller's environment prior to importing this module.
	ScriptsToProcess = @(
		"Scripts\AppxModule.ps1"
		"Scripts\TargetProgram.ps1"
	)

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @()

	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @("Ruleset.ProgramInfo.Format.ps1xml")

	# Modules to import as nested modules of the module specified in RootModule.
	# Loading (.ps1) files here is equivalent to dot sourcing the script in your root module.
	# NestedModules = @()

	# Functions to export from this module, for best performance, do not use wildcards and do not
	# delete the entry, use an empty array if there are no functions to export.
	FunctionsToExport = @(
		"Confirm-Installation"
		"Format-Path"
		"Get-AppCapability"
		"Get-AppSID"
		"Get-ExecutablePath"
		"Get-InstallProperties"
		"Get-NetFramework"
		"Get-OneDrive"
		"Get-SqlManagementStudio"
		"Get-SqlServerInstance"
		"Get-SystemApps"
		"Get-SystemSoftware"
		"Get-UserApps"
		"Get-UserSoftware"
		"Get-WindowsDefender"
		"Get-WindowsKit"
		"Get-WindowsSDK"
		"Search-Installation"
		"Test-ExecutableFile"
		"Test-FileSystemPath"
		"Test-Service"
		# TODO: Following exports only for unit testing
		# NOTE: Control import with if ($Develop) { Export-ModuleMember ... }
		# "Edit-Table"
		# "Initialize-Table"
		# "Show-Table"
		# "Update-Table"
	)

	# Cmdlets to export from this module, for best performance, do not use wildcards and do not
	# delete the entry, use an empty array if there are no cmdlets to export.
	CmdletsToExport = @()

	# Variables to export from this module.
	# Wildcard characters are permitted, by default, all variables ("*") are exported.
	VariablesToExport = @(
		# TODO: Following exports only for unit testing
		# "InstallTable"
	)

	# Aliases to export from this module, for best performance, do not use wildcards and do not
	# delete the entry, use an empty array if there are no aliases to export.
	AliasesToExport = @()

	# DSC resources to export from this module
	# DscResourcesToExport = @()

	# List of all modules packaged with this module.
	# These modules are not automatically processed.
	# ModuleList = @()

	# List of all files packaged with this module.
	# As with ModuleList, FileList is an inventory list.
	FileList = @(
		"en-US\about_Ruleset.ProgramInfo.help.txt"
		"en-US\Ruleset.ProgramInfo-help.xml"
		"Help\en-US\about_Ruleset.ProgramInfo.md"
		"Help\en-US\Confirm-Installation.md"
		"Help\en-US\Format-Path.md"
		"Help\en-US\Get-AppCapability.md"
		"Help\en-US\Get-AppSID.md"
		"Help\en-US\Get-ExecutablePath.md"
		"Help\en-US\Get-InstallProperties.md"
		"Help\en-US\Get-NetFramework.md"
		"Help\en-US\Get-OneDrive.md"
		"Help\en-US\Get-SqlManagementStudio.md"
		"Help\en-US\Get-SqlServerInstance.md"
		"Help\en-US\Get-SystemApps.md"
		"Help\en-US\Get-SystemSoftware.md"
		"Help\en-US\Get-UserApps.md"
		"Help\en-US\Get-UserSoftware.md"
		"Help\en-US\Get-WindowsDefender.md"
		"Help\en-US\Get-WindowsKit.md"
		"Help\en-US\Get-WindowsSDK.md"
		"Help\en-US\Ruleset.ProgramInfo.md"
		"Help\en-US\Search-Installation.md"
		"Help\en-US\Test-ExecutableFile.md"
		"Help\en-US\Test-FileSystemPath.md"
		"Help\en-US\Test-Service.md"
		"Help\README.md"
		"Private\Edit-Table.ps1"
		"Private\Initialize-Table.ps1"
		"Private\README.md"
		"Private\Show-Table.ps1"
		"Private\Update-Table.ps1"
		"Public\Confirm-Installation.ps1"
		"Public\Format-Path.ps1"
		"Public\Get-AppCapability.ps1"
		"Public\Get-AppSID.ps1"
		"Public\Get-ExecutablePath.ps1"
		"Public\Get-InstallProperties.ps1"
		"Public\Get-NetFramework.ps1"
		"Public\Get-OneDrive.ps1"
		"Public\Get-SqlManagementStudio.ps1"
		"Public\Get-SqlServerInstance.ps1"
		"Public\Get-SystemApps.ps1"
		"Public\Get-SystemSoftware.ps1"
		"Public\Get-UserApps.ps1"
		"Public\Get-UserSoftware.ps1"
		"Public\Get-WindowsDefender.ps1"
		"Public\Get-WindowsKit.ps1"
		"Public\Get-WindowsSDK.ps1"
		"Public\README.md"
		"Public\Search-Installation.ps1"
		"Public\Test-ExecutableFile.ps1"
		"Public\Test-FileSystemPath.ps1"
		"Public\Test-Service.ps1"
		"Scripts\README.md"
		"Scripts\TargetProgram.ps1"
		"Ruleset.ProgramInfo_49f11777-b8b6-4fed-bd82-32c8f48db81e_HelpInfo.xml"
		"Ruleset.ProgramInfo.Format.ps1xml"
		"Ruleset.ProgramInfo.psd1"
		"Ruleset.ProgramInfo.psm1"
	)

	# Specifies any private data that needs to be passed to the root module specified by the RootModule.
	# This contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{

		PSData = @{

			# Tags applied to this module.
			# These help with module discovery in online galleries.
			Tags = @(
				"Program"
				"ProgramInfo"
				"Software"
				"SoftwareInfo"
			)

			# A URL to the license for this module.
			LicenseUri = "https://raw.githubusercontent.com/metablaster/WindowsFirewallRuleset/master/LICENSE"

			# A URL to the main website for this project.
			ProjectUri = "https://github.com/metablaster/WindowsFirewallRuleset"

			# A URL to an icon representing this module.
			# The specified icon is displayed on the gallery webpage for the module
			IconUri = "https://raw.githubusercontent.com/metablaster/WindowsFirewallRuleset/master/Readme/Screenshots/bluewall.png"

			# ReleaseNotes of this module
			# ReleaseNotes = ""

			# A PreRelease string that identifies the module as a prerelease version in online galleries.
			Prerelease = "https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Readme/CHANGELOG.md"

			# Flag to indicate whether the module requires explicit user acceptance for
			# install, update, or save.
			RequireLicenseAcceptance = $true

			# A list of external modules that this module is dependent upon.
			ExternalModuleDependencies = @(
				"Ruleset.ComputerInfo"
				"Ruleset.UserInfo"
				"Ruleset.Utility"
			)
		} # End of PSData hashtable
	} # End of PrivateData hashtable

	# HelpInfo URI of this module
	# HelpInfoURI = "https://raw.githubusercontent.com/metablaster/WindowsFirewallRuleset/master/Modules/Ruleset.ProgramInfo/Ruleset.ProgramInfo_49f11777-b8b6-4fed-bd82-32c8f48db81e_HelpInfo.xml"

	# Default prefix for commands exported from this module.
	# Override the default prefix using Import-Module -Prefix.
	# DefaultCommandPrefix = ""
}
