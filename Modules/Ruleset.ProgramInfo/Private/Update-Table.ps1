
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2019-2022 metablaster zebal@protonmail.ch

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
Fill data table with information required to define firewall rule based on application.

.DESCRIPTION
Search system for specified program and add relevant program information such as
installation directory and principal to the table.
This information is sufficient to make a firewall rule based on executable.

.PARAMETER Search
Search string which is a partial name of the program name as shown in the Name property of
program search functions.

.PARAMETER Domain
Computer name which to check for installed programs

.PARAMETER UserProfile
True if user profile is to be searched in addition to system wide installations

.PARAMETER Executable
Optionally specify executable name which will be search first.
This method can be useful if the result is ambiguous, ex. multiple results.

.EXAMPLE
PS> Update-Table -Search "GoogleChrome"

.EXAMPLE
PS> Update-Table -Search "Microsoft Edge" -Executable "msedge.exe"

.EXAMPLE
PS> Update-Table -Search "Greenshot" -UserProfile

.EXAMPLE
PS> Update-Table -Executable "PowerShell.exe"

.INPUTS
None. You cannot pipe objects to Update-Table

.OUTPUTS
None. Update-Table does not generate any output

.NOTES
TODO: For programs in user profile rules should update LocalUser parameter accordingly,
currently it looks like we assign entire user group for program that applies to single user only.
TODO: Consider optional parameter for search by regex, wildcard, case sensitive or positional search
TODO: This function should make use of Out-DataTable function from Ruleset.Utility module
TODO: Using Format.psm1xml for DataTable would apply to all data tables, maybe reveting to PSCustomObject?
#>
function Update-Table
{
	[CmdletBinding(PositionalBinding = $false, SupportsShouldProcess = $true, ConfirmImpact = "None")]
	[OutputType([void])]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = "Search")]
		[string] $Search,

		[Parameter()]
		[Alias("ComputerName", "CN")]
		[string] $Domain = [System.Environment]::MachineName,

		[Parameter(ParameterSetName = "Search")]
		[switch] $UserProfile,

		[Parameter(ParameterSetName = "Search")]
		[Parameter(Mandatory = $true, ParameterSetName = "Executable")]
		[string] $Executable
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] ParameterSet = $($PSCmdlet.ParameterSetName):$($PSBoundParameters | Out-String)"

	if ($PSCmdlet.ShouldProcess("InstallTable", "Insert data into table"))
	{
		# Replace localhost and dot with NETBIOS computer name
		if (($Domain -eq "localhost") -or ($Domain -eq "."))
		{
			$Domain = [System.Environment]::MachineName
		}

		if ($Domain -ne $script:LastPolicyStore)
		{
			# If domain changed, need to update script cache
			$script:LastPolicyStore = $Domain
			$script:ExecutablePaths = Get-ExecutablePath -Domain $Domain
			$script:SystemPrograms = Get-SystemSoftware -Domain $Domain
			$script:AllUserPrograms = Get-InstallProperties -Domain $Domain
		}

		# To reduce typing and make code clear
		$UserGroups = Get-UserGroup -Domain $PolicyStore

		if (![string]::IsNullOrEmpty($Executable))
		{
			Write-Verbose -Message "[$($MyInvocation.InvocationName)] Searching executable names for: $Executable"

			# TODO: executable paths search is too weak, need to handle more properties here
			$InstallLocation = $ExecutablePaths |
			Where-Object -Property Name -EQ $Executable |
			Select-Object -ExpandProperty InstallLocation

			if ($InstallLocation)
			{
				# Create a row
				$Row = $InstallTable.NewRow()

				# TODO: Learn username from installation path, probably a function for this
				$UserInfo = $UserGroups | Where-Object -Property Group -EQ "Users"

				# Enter data into row
				$Row.ID = ++$RowIndex
				$Row.Domain = $UserInfo.Domain
				$Row.Group = $UserInfo.Group
				$Row.Principal = $UserInfo.Principal
				$Row.SID = $UserInfo.SID
				$Row.InstallLocation = $InstallLocation

				Write-Debug -Message "[$($MyInvocation.InvocationName)] Updating table for $($UserInfo.Principal) with $InstallLocation"

				# Add row to the table
				$InstallTable.Rows.Add($Row)

				# TODO: If the path is known there is no need to continue?
				return
			}

			if ($PSCmdlet.ParameterSetName -eq "Executable")
			{
				# Function was called to search by executable only
				return
			}
		}

		# TODO: try to search also for path in addition to program name
		# TODO: SearchString may pick up irrelevant paths (ie. unreal engine), or even miss
		$SearchString = "*$Search*"

		# Search system wide installed programs
		if ($SystemPrograms -and $SystemPrograms.Name -like $SearchString)
		{
			Write-Verbose -Message "[$($MyInvocation.InvocationName)] Searching system programs for $Search"

			# TODO: need better mechanism for multiple matches
			$TargetPrograms = $SystemPrograms | Where-Object -Property Name -Like $SearchString
			$UserInfo = $UserGroups | Where-Object -Property Group -EQ "Users"

			foreach ($Program in $TargetPrograms)
			{
				# Create a row
				$Row = $InstallTable.NewRow()

				$InstallLocation = $Program | Select-Object -ExpandProperty InstallLocation

				# Enter data into row
				$Row.ID = ++$RowIndex
				$Row.Domain = $UserInfo.Domain
				$Row.Group = $UserInfo.Group
				$Row.Principal = $UserInfo.Principal
				$Row.SID = $UserInfo.SID
				$Row.InstallLocation = $InstallLocation

				Write-Debug -Message "[$($MyInvocation.InvocationName)] Updating table for $($UserInfo.Principal) with $InstallLocation"

				# Add row to the table
				$InstallTable.Rows.Add($Row)
			}
		}
		# Program not found on system, attempt alternative search
		elseif ($AllUserPrograms -and $AllUserPrograms.Name -like $SearchString)
		{
			Write-Verbose -Message "[$($MyInvocation.InvocationName)] Searching program install properties for $Search"
			$TargetPrograms = $AllUserPrograms | Where-Object -Property Name -Like $SearchString

			foreach ($Program in $TargetPrograms)
			{
				# Create a row
				$Row = $InstallTable.NewRow()

				# Let see who owns the sub key which is the SID
				$KeyOwner = ConvertFrom-SID $Program.SIDKey -Domain $Domain
				if ($KeyOwner -eq "Users")
				{
					$UserInfo = $UserGroups | Where-Object -Property Group -EQ "Users"
				}
				else
				{
					# TODO: we need more registry samples to determine what is right, Administrators seems logical
					$UserInfo = $UserGroups | Where-Object -Property Group -EQ "Administrators"
				}

				$InstallLocation = $Program | Select-Object -ExpandProperty InstallLocation

				# Enter data into row
				$Row.ID = ++$RowIndex
				$Row.Domain = $UserInfo.Domain
				$Row.Group = $UserInfo.Group
				$Row.Principal = $UserInfo.Principal
				$Row.SID = $UserInfo.SID
				$Row.InstallLocation = $InstallLocation

				Write-Debug -Message "[$($MyInvocation.InvocationName)] Updating table for $($UserInfo.Caption) with $InstallLocation"

				# Add row to the table
				$InstallTable.Rows.Add($Row)
			}
		}

		# Search user profiles
		# NOTE: User profile should be searched even if there is an installation system wide
		if ($UserProfile)
		{
			$Principals = Get-GroupPrincipal "Users" -Domain $Domain

			foreach ($UserInfo in $Principals)
			{
				Write-Verbose -Message "[$($MyInvocation.InvocationName)] Searching $($UserInfo.Domain) programs for $Search"

				# TODO: We handle OneDrive case here but there may be more such programs in the future
				# so this obviously means we need better approach to handle this
				if ($Search -eq "OneDrive")
				{
					# NOTE: For one drive registry drilling procedure is different
					$UserPrograms = Get-OneDrive $UserInfo.User -Domain $Domain
				}
				else
				{
					# NOTE: the story is different here, each user might have multiple matches for search string
					# letting one match to have same principal would be mistake.
					$UserPrograms = Get-UserSoftware $UserInfo.User -Domain $Domain |
					Where-Object -Property Name -Like $SearchString
				}

				if ($UserPrograms)
				{
					foreach ($Program in $UserPrograms)
					{
						# NOTE: Avoid spamming
						# Write-Debug -Message "[$($MyInvocation.InvocationName)] Processing program: $Program"

						$InstallLocation = $Program | Select-Object -ExpandProperty InstallLocation

						# Create a row
						$Row = $InstallTable.NewRow()

						# Enter data into row
						$Row.ID = ++$RowIndex
						$Row.Domain = $UserInfo.Domain
						$Row.User = $UserInfo.User
						$Row.Group = $UserInfo.Group
						$Row.Principal = $UserInfo.Principal
						$Row.SID = $UserInfo.SID
						$Row.InstallLocation = $InstallLocation

						Write-Debug -Message "[$($MyInvocation.InvocationName)] Updating table for $($UserInfo.Principal) with $InstallLocation"

						# Add the row to the table
						$InstallTable.Rows.Add($Row)
					}
				}
			}
		}
	}
}
