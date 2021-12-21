
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2021 metablaster zebal@protonmail.ch

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
# Module manifest for module "Ruleset.Remote"
#
# Generated by: metablaster
#
# Generated on: 10.4.2021.
#

@{
	# Script module or binary module file associated with this manifest, (alias: ModuleToProcess)
	# Previous versions of PowerShell called this element the ModuleToProcess.
	# NOTE: To create a manifest module this must be empty,
	# the name of a script module (.psm1) creates a script module,
	# the name of a binary module (.exe or .dll) creates a binary module.
	RootModule = "Ruleset.Remote.psm1"

	# Version number of this module.
	ModuleVersion = "0.11.0"

	# Supported PSEditions
	CompatiblePSEditions = @(
		"Core"
		"Desktop"
	)

	# ID used to uniquely identify this module
	GUID = "28ed593c-ae6e-4067-8a50-28f0d32d2edd"

	# Author of this module
	Author = "metablaster zebal@protonmail.ch"

	# Company or vendor of this module
	# CompanyName = "Unknown"

	# Copyright statement for this module
	Copyright = "Copyright (C) 2021 metablaster zebal@protonmail.ch"

	# Description of the functionality provided by this module
	Description = "Module used for remoting configuration of WinRM, CIM and remote registry"

	# Minimum version of the PowerShell engine required by this module
	# Valid values are: 1.0 / 2.0 / 3.0 / 4.0 / 5.0 / 5.1 / 6.0 / 6.1 / 6.2 / 7.0 / 7.1
	PowerShellVersion = "5.1"

	# Name of the Windows PowerShell host required by this module
	# PowerShellHostName = "ConsoleHost"

	# Minimum version of the PowerShell host required by this module
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
	RequiredAssemblies = @("Microsoft.WSMan.Management")

	# Script files (.ps1) that are run in the caller's environment prior to importing this module.
	# ScriptsToProcess = @("Scripts\WinRMSettings.ps1")

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @()

	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @("Ruleset.Remote.Format.ps1xml")

	# Modules to import as nested modules of the module specified in RootModule.
	# Loading (.ps1) files here is equivalent to dot sourcing the script in your root module.
	# NestedModules = @()

	# Functions to export from this module, for best performance, do not use wildcards and do not
	# delete the entry, use an empty array if there are no functions to export.
	# NOTE: When the value of any *ToExport key is an empty array,
	# no objects of that type are exported, regardless of the value in the Export-ModuleMember
	FunctionsToExport = @(
		"Connect-Computer"
		"Disable-RemoteRegistry"
		"Disable-WinRMServer"
		"Disconnect-Computer"
		"Enable-RemoteRegistry"
		"Enable-WinRMServer"
		"Export-WinRM"
		"Publish-SshKey"
		"Register-SslCertificate"
		"Reset-WinRM"
		"Set-WinRMClient"
		"Show-WinRMConfig"
		"Test-WinRM"
		"Unregister-SslCertificate"
		# NOTE: Temporarily exporting for testing
		"Initialize-WinRM"
		"Restore-NetProfile"
		"Unblock-NetProfile"
	)

	# Cmdlets to export from this module, for best performance, do not use wildcards and do not
	# delete the entry, use an empty array if there are no cmdlets to export.
	CmdletsToExport = @()

	# Variables to export from this module.
	# Wildcard characters are permitted, by default, all variables ("*") are exported.
	# VariablesToExport = @()

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
		"en-US\about_Ruleset.Remote.help.txt"
		"en-US\Ruleset.Remote-help.xml"
		"Help\en-US\Connect-Computer.md"
		"Help\en-US\Disable-RemoteRegistry.md"
		"Help\en-US\Disable-WinRMServer.md"
		"Help\en-US\Enable-WinRMServer.md"
		"Help\en-US\Export-WinRM.md"
		"Help\en-US\Publish-SshKey.md"
		"Help\en-US\README.md"
		"Help\en-US\Register-SslCertificate.md"
		"Help\en-US\Reset-WinRM.md"
		"Help\en-US\Set-WinRMClient.md"
		"Help\en-US\Show-WinRMConfig.md"
		"Help\en-US\Test-WinRM.md"
		"Help\en-US\Unregister-SslCertificate.md"
		"Private\Initialize-WinRM.ps1"
		"Private\README.md"
		"Private\Restore-NetProfile.ps1"
		"Private\Unblock-NetProfile.ps1"
		"Public\Connect-Computer.ps1"
		"Public\Disable-RemoteRegistry.ps1"
		"Public\Disable-WinRMServer.ps1"
		"Public\Enable-WinRMServer.ps1"
		"Public\README.md"
		"Public\Export-WinRM.ps1"
		"Public\Publish-SshKey.ps1"
		"Public\Register-SslCertificate.ps1"
		"Public\Reset-WinRM.ps1"
		"Public\Set-WinRMClient.ps1"
		"Public\Show-WinRMConfig.ps1"
		"Public\Test-WinRM.ps1"
		"Public\Unregister-SslCertificate.ps1"
		"Scripts\README.md"
		"Scripts\WinRMSettings.ps1"
		"Ruleset.Remote_28ed593c-ae6e-4067-8a50-28f0d32d2edd_HelpInfo.xml"
		"Ruleset.Remote.psd1"
		"Ruleset.Remote.psm1"
	)

	# Specifies any private data that needs to be passed to the root module specified by the RootModule.
	# This contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{

		PSData = @{

			# Tags applied to this module.
			# These help with module discovery in online galleries.
			Tags = @(
				"WinRM"
				"CIM"
				"Remote"
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
			# ExternalModuleDependencies = @()
		} # End of PSData hashtable
	} # End of PrivateData hashtable

	# Updatable Help uses the HelpInfoURI key in the module manifest to find the Help information
	# (HelpInfo XML) file that contains the location of the updated help files for the module.
	# HelpInfoURI = "https://raw.githubusercontent.com/metablaster/WindowsFirewallRuleset/develop/Modules/Ruleset.Remote/Ruleset.Remote_28ed593c-ae6e-4067-8a50-28f0d32d2edd_HelpInfo.xml"

	# Default prefix for commands exported from this module.
	# Override the default prefix using Import-Module -Prefix.
	# DefaultCommandPrefix = ""
}
