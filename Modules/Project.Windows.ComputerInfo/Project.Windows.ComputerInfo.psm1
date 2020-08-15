
<#
MIT License

Project: "Windows Firewall Ruleset" serves to manage firewall on Windows systems
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

Set-StrictMode -Version Latest
Set-Variable -Name ThisModule -Scope Script -Option ReadOnly -Force -Value ($MyInvocation.MyCommand.Name -replace ".{5}$")

# Includes
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1

#
# Module preferences
#

if ($Develop)
{
	$ErrorActionPreference = $ModuleErrorPreference
	$WarningPreference = $ModuleWarningPreference
	$DebugPreference = $ModuleDebugPreference
	$VerbosePreference = $ModuleVerbosePreference
	$InformationPreference = $ModuleInformationPreference

	Write-Debug -Message "[$ThisModule] ErrorActionPreference is $ErrorActionPreference"
	Write-Debug -Message "[$ThisModule] WarningPreference is $WarningPreference"
	Write-Debug -Message "[$ThisModule] DebugPreference is $DebugPreference"
	Write-Debug -Message "[$ThisModule] VerbosePreference is $VerbosePreference"
	Write-Debug -Message "[$ThisModule] InformationPreference is $InformationPreference"
}
else
{
	# Everything is default except InformationPreference should be enabled
	$InformationPreference = "Continue"
}

# Includes
Import-Module -Name $PSScriptRoot\..\Indented.Net.IP

<#
.SYNOPSIS
Get localhost name
.DESCRIPTION
TODO: add description
.EXAMPLE
Get-ComputerName
.INPUTS
None. You cannot pipe objects to Get-ComputerName
.OUTPUTS
[string] computer name in form of COMPUTERNAME
.NOTES
TODO: implement querying computers on network by specifying IP address
#>
function Get-ComputerName
{
	[OutputType([System.String])]
	[CmdletBinding()]
	param ()

	Write-Debug -Message "[$($MyInvocation.InvocationName)] params($($PSBoundParameters.Values))"

	$ComputerName = [System.Environment]::MachineName
	Write-Verbose -Message "[$($MyInvocation.InvocationName)] Learning computer name: $ComputerName"

	return $ComputerName
}

<#
.SYNOPSIS
Method to get configured adapters
.DESCRIPTION
Return list of all configured adapters and their configuration.
Applies to adapters which have an IP assigned regardless if connected to network.
This conditionally includes virtual and hidden adapters such as Hyper-V adapters on all compartments.
.PARAMETER AddressFamily
IP version for which to obtain adapters, IPv4 or IPv6
.PARAMETER ExcludeHardware
Exclude hardware/physical network adapters
.PARAMETER IncludeAll
Include all possible adapter types present on target computer
.PARAMETER IncludeVirtual
Whether to include virtual adapters
.PARAMETER IncludeHidden
Whether to include hidden adapters
.PARAMETER IncludeDisconnected
Whether to include disconnected
.EXAMPLE
Get-ConfiguredAdapter "IPv4"
.EXAMPLE
Get-ConfiguredAdapter "IPv6"
.INPUTS
None. You cannot pipe objects to Get-ConfiguredAdapter
.OUTPUTS
[NetIPConfiguration] or error message if no adapter configured
.NOTES
TODO: Loopback interface is missing in the output
#>
function Get-ConfiguredAdapter
{
	# TODO: doesn't work [OutputType([System.Net.NetIPConfiguration])]
	[CmdletBinding(DefaultParameterSetName = "Individual")]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateSet("IPv4", "IPv6")]
		[Parameter(ParameterSetName = "All")]
		[Parameter(ParameterSetName = "Individual")]
		[string] $AddressFamily,

		[Parameter(ParameterSetName = "All")]
		[Parameter(ParameterSetName = "Individual")]
		[switch] $ExcludeHardware,

		[Parameter(ParameterSetName = "All")]
		[switch] $IncludeAll,

		[Parameter(ParameterSetName = "Individual")]
		[switch] $IncludeVirtual,

		[Parameter(ParameterSetName = "Individual")]
		[switch] $IncludeHidden,

		[Parameter(ParameterSetName = "Individual")]
		[switch] $IncludeDisconnected
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] params($($PSBoundParameters.Values))"
	Write-Verbose -Message "[$($MyInvocation.InvocationName)] Getting connected adapters for $AddressFamily network"

	if ($AddressFamily.ToString() -eq "IPv4")
	{
		if ($IncludeDisconnected -or $IncludeAll)
		{
			$AllConfiguredAdapters = Get-NetIPConfiguration -AllCompartments | Where-Object -Property IPv4Address
		}
		else
		{
			$AllConfiguredAdapters = Get-NetIPConfiguration -AllCompartments | Where-Object {
				$_.IPv4Address -and $_.IPv4DefaultGateway
			}
		}
	}
	else
	{
		if ($IncludeDisconnected -or $IncludeAll)
		{
			$AllConfiguredAdapters = Get-NetIPConfiguration -AllCompartments | Where-Object -Property IPv6Address
		}
		else
		{
			$AllConfiguredAdapters = Get-NetIPConfiguration -AllCompartments | Where-Object {
				$_.IPv6Address -and $_.IPv6DefaultGateway
			}
		}
	}

	if (!$AllConfiguredAdapters)
	{
		Write-Error -Category ObjectNotFound -TargetObject "AllConfiguredAdapters" `
			-Message "None of the adapters is configured for $AddressFamily"
		return $null
	}

	# Get-NetIPConfiguration does not tell us adapter type (hardware, hidden or virtual)
	[PSCustomObject[]] $RequestedAdapters = @()
	if (!$ExcludeHardware)
	{
		$RequestedAdapters = Get-NetAdapter |
		Where-Object { $_.HardwareInterface -eq "True" }
	}

	# Include virtual or hidden to hardware interfaces
	if ($IncludeVirtual -or $IncludeAll)
	{
		$RequestedAdapters += Get-NetAdapter |
		Where-Object { $_.Virtual -eq "True" }
	}
	if ($IncludeHidden -or $IncludeAll)
	{
		$RequestedAdapters += Get-NetAdapter -IncludeHidden |
		Where-Object { $_.Hidden -eq "True" }
	}

	if (!$RequestedAdapters)
	{
		Write-Error -Category ObjectNotFound -TargetObject "RequestedAdapters" `
			-Message "None of the adapters matches search criteria for $AddressFamily"
		return $null
	}

	[Uint32[]] $ValidAdapters = $RequestedAdapters | Select-Object -ExpandProperty ifIndex

	$ConfiguredAdapters = @()
	if (![string]::IsNullOrEmpty($ValidAdapters))
	{
		$ConfiguredAdapters = $AllConfiguredAdapters | Where-Object {
			[array]::Find($ValidAdapters, [System.Predicate[Uint32]] { $_.InterfaceIndex -eq $args[0] })
		}
	}

	$Count = ($ConfiguredAdapters | Measure-Object).Count
	if ($Count -eq 0)
	{
		Write-Error -Category ObjectNotFound -TargetObject "ConfiguredAdapters" `
			-Message "None of the adapters is configured for $AddressFamily with given criteria"
	}
	elseif ($Count -gt 1)
	{
		Write-Information -Tags "User" -MessageData "INFO: Multiple adapters are configured for $AddressFamily"
	}

	return $ConfiguredAdapters
}

<#
.SYNOPSIS
Method to get aliases of configured adapters
.DESCRIPTION
Return list of interface aliases of all configured adapters.
Applies to adapters which have an IP assigned regardless if connected to network.
This may include virtual adapters as well such as Hyper-V adapters on all compartments.
.PARAMETER AddressFamily
IP version for which to obtain adapters, IPv4 or IPv6
.PARAMETER IncludeAll
Include all possible adapter types present on target computer
.PARAMETER IncludeVirtual
Whether to include virtual adapters
.PARAMETER IncludeHidden
Whether to include hidden adapters
.PARAMETER IncludeDisconnected
Whether to include disconnected
.EXAMPLE
Get-InterfaceAlias "IPv4"
.EXAMPLE
Get-InterfaceAlias "IPv6"
.INPUTS
None. You cannot pipe objects to Get-InterfaceAlias
.OUTPUTS
WildcardPattern[] Array of interface aliases
.NOTES
None.
#>
function Get-InterfaceAlias
{
	[OutputType([System.Management.Automation.WildcardPattern[]])]
	[CmdletBinding(DefaultParameterSetName = "Individual")]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateSet("IPv4", "IPv6")]
		[Parameter(ParameterSetName = "All")]
		[Parameter(ParameterSetName = "Individual")]
		[string] $AddressFamily,

		[Parameter(Mandatory = $false)]
		[Parameter(ParameterSetName = "All")]
		[Parameter(ParameterSetName = "Individual")]
		[System.Management.Automation.WildcardOptions]
		$WildCardOption = [System.Management.Automation.WildcardOptions]::None,

		[Parameter(ParameterSetName = "All")]
		[Parameter(ParameterSetName = "Individual")]
		[switch] $ExcludeHardware,

		[Parameter(ParameterSetName = "All")]
		[switch] $IncludeAll,

		[Parameter(ParameterSetName = "Individual")]
		[switch] $IncludeVirtual,

		[Parameter(ParameterSetName = "Individual")]
		[switch] $IncludeHidden,

		[Parameter(ParameterSetName = "Individual")]
		[switch] $IncludeDisconnected
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] params($($PSBoundParameters.Values))"
	Write-Verbose -Message "[$($MyInvocation.InvocationName)] Getting connected adapters for $AddressFamily network"

	if ($IncludeAll)
	{
		$ConfiguredInterfaces = Get-ConfiguredAdapter $AddressFamily `
			-IncludeAll:$IncludeAll -ExcludeHardware:$ExcludeHardware
	}
	else
	{
		$ConfiguredInterfaces = Get-ConfiguredAdapter $AddressFamily `
			-IncludeVirtual:$IncludeVirtual -ExcludeHardware:$ExcludeHardware `
			-IncludeHidden:$IncludeHidden -IncludeDisconnected:$IncludeDisconnected
	}

	if (!$ConfiguredInterfaces)
	{
		# NOTE: Error should be generated and shown by Get-ConfiguredAdapter
		return $null
	}

	[string[]] $InterfaceAliases = $ConfiguredInterfaces | Select-Object -ExpandProperty InterfaceAlias
	if ($InterfaceAliases.Length -eq 0)
	{
		Write-Error -Category ObjectNotFound -TargetObject $InterfaceAliases `
			-Message "None of the adapters matches search criteria to get interface aliases from"
		return
	}

	[WildcardPattern[]] $InterfaceAliasPattern = @()
	foreach ($Alias in $InterfaceAliases)
	{
		if ([WildcardPattern]::ContainsWildcardCharacters($Alias))
		{
			Write-Warning -Message "$Alias Interface alias contains wildcard pattern"
		}
		else
		{
			Write-Verbose -Message "[$($MyInvocation.InvocationName)] Interface alias '$Alias' does not contain wildcard pattern"
		}

		$InterfaceAliasPattern += [WildcardPattern]::new($Alias, $WildCardOption)
	}

	if ($InterfaceAliasPattern.Length -eq 0)
	{
		Write-Error -Category ObjectNotFound -TargetObject $InterfaceAliasPattern `
			-Message "Creating interface alias patterns failed"
	}
	elseif ($InterfaceAliasPattern.Length -gt 1)
	{
		Write-Information -Tags "User" -MessageData "INFO: Got multiple adapter aliases"
	}

	return $InterfaceAliasPattern
}

<#
.SYNOPSIS
Method to get list of IP addresses on local machine
.DESCRIPTION
Returns list of IP addresses for all adapters connected to network
Return list of IP addresses for all configured adapter.
This includes both physical and virtual adapters.
.PARAMETER AddressFamily
IP version for which to obtain address, IPv4 or IPv6
.PARAMETER IncludeAll
Include all possible adapter types present on target computer
.PARAMETER IncludeVirtual
Whether to include virtual adapters
.PARAMETER IncludeHidden
Whether to include hidden adapters
.PARAMETER IncludeDisconnected
Whether to include disconnected
.EXAMPLE
Get-IPAddress "IPv4"
.EXAMPLE
Get-IPAddress "IPv6"
.INPUTS
None. You cannot pipe objects to Get-IPAddress
.OUTPUTS
[IPAddress[]] Array of IP addresses  and warning message if no adapter connected
.NOTES
None.
#>
function Get-IPAddress
{
	[OutputType([System.Net.IPAddress[]])]
	[CmdletBinding(DefaultParameterSetName = "Individual")]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateSet("IPv4", "IPv6")]
		[Parameter(ParameterSetName = "All")]
		[Parameter(ParameterSetName = "Individual")]
		[string] $AddressFamily,

		[Parameter(ParameterSetName = "All")]
		[Parameter(ParameterSetName = "Individual")]
		[switch] $ExcludeHardware,

		[Parameter(ParameterSetName = "All")]
		[switch] $IncludeAll,

		[Parameter(ParameterSetName = "Individual")]
		[switch] $IncludeVirtual,

		[Parameter(ParameterSetName = "Individual")]
		[switch] $IncludeHidden,

		[Parameter(ParameterSetName = "Individual")]
		[switch] $IncludeDisconnected
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] params($($PSBoundParameters.Values))"
	Write-Verbose -Message "[$($MyInvocation.InvocationName)] Getting IP's of connected adapters for $AddressFamily network"

	if ($IncludeAll)
	{
		$ConfiguredAdapters = Get-ConfiguredAdapter $AddressFamily `
			-IncludeAll:$IncludeAll -ExcludeHardware:$ExcludeHardware
	}
	else
	{
		$ConfiguredAdapters = Get-ConfiguredAdapter $AddressFamily `
			-IncludeVirtual:$IncludeVirtual -ExcludeHardware:$ExcludeHardware `
			-IncludeHidden:$IncludeHidden -IncludeDisconnected:$IncludeDisconnected
	}

	[IPAddress[]] $IPAddress = $ConfiguredAdapters |
	Select-Object -ExpandProperty ($AddressFamily + "Address") |
	Select-Object -ExpandProperty IPAddress

	$Count = ($IPAddress | Measure-Object).Count
	if ($Count -gt 1)
	{
		# TODO: bind result to custom function
		Write-Information -Tags "Result" -MessageData "INFO: Computer has multiple IP addresses: $IPAddress"
	}
	elseif ($Count -eq 0)
	{
		Write-Warning -Message "Computer not connected to $AddressFamily network, IP address will be missing"
	}

	return $IPAddress
}

<#
.SYNOPSIS
Method to get broadcast addresses on local machine
.DESCRIPTION
Return multiple broadcast addresses, for each configured adapter.
This includes both physical and virtual adapters.
Returned broadcast addresses are only for IPv4
.PARAMETER IncludeAll
Include all possible adapter types present on target computer
.PARAMETER IncludeVirtual
Whether to include virtual adapters
.PARAMETER IncludeHidden
Whether to include hidden adapters
.PARAMETER IncludeDisconnected
Whether to include disconnected
.EXAMPLE
Get-Broadcast
.INPUTS
None. You cannot pipe objects to Get-Broadcast
.OUTPUTS
[IPAddress[]] Array of broadcast addresses
#>
function Get-Broadcast
{
	[OutputType([System.Net.IPAddress[]])]
	[CmdletBinding(DefaultParameterSetName = "Individual")]
	param (
		[Parameter(ParameterSetName = "All")]
		[switch] $IncludeAll,

		[Parameter(ParameterSetName = "All")]
		[Parameter(ParameterSetName = "Individual")]
		[switch] $ExcludeHardware,

		[Parameter(ParameterSetName = "Individual")]
		[switch] $IncludeVirtual,

		[Parameter(ParameterSetName = "Individual")]
		[switch] $IncludeHidden,

		[Parameter(ParameterSetName = "Individual")]
		[switch] $IncludeDisconnected
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] params($($PSBoundParameters.Values))"
	Write-Verbose -Message "[$($MyInvocation.InvocationName)] Getting broadcast address of connected adapters"

	# Broadcast address makes sense only for IPv4
	if ($IncludeAll)
	{
		$ConfiguredAdapters = Get-ConfiguredAdapter IPv4 `
			-IncludeAll:$IncludeAll -ExcludeHardware:$ExcludeHardware
	}
	else
	{
		$ConfiguredAdapters = Get-ConfiguredAdapter IPv4 `
			-IncludeVirtual:$IncludeVirtual -ExcludeHardware:$ExcludeHardware `
			-IncludeHidden:$IncludeHidden -IncludeDisconnected:$IncludeDisconnected
	}

	$ConfiguredAdapters = $ConfiguredAdapters | Select-Object -ExpandProperty IPv4Address
	$Count = ($ConfiguredAdapters | Measure-Object).Count

	if ($Count -gt 0)
	{
		[IPAddress[]] $Broadcast = @()
		foreach ($Adapter in $ConfiguredAdapters)
		{
			[IPAddress] $IPAddress = $Adapter | Select-Object -ExpandProperty IPAddress
			$SubnetMask = ConvertTo-Mask ($Adapter | Select-Object -ExpandProperty PrefixLength)

			$Broadcast += Get-NetworkSummary $IPAddress $SubnetMask |
			Select-Object -ExpandProperty BroadcastAddress |
			Select-Object -ExpandProperty IPAddressToString
		}

		Write-Information -Tags "Result" -MessageData "INFO: Network broadcast addresses are: $Broadcast"
		return $Broadcast
	}

	Write-Debug -Message "[$($MyInvocation.InvocationName)] returns null"
}

#
# Function exports
#

Export-ModuleMember -Function Get-ComputerName
Export-ModuleMember -Function Get-ConfiguredAdapter
Export-ModuleMember -Function Get-InterfaceAlias
Export-ModuleMember -Function Get-IPAddress
Export-ModuleMember -Function Get-Broadcast
