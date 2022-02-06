
<#
MIT License

This file is part of "Windows Firewall Ruleset" project
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2021, 2022 metablaster zebal@protonmail.ch

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
Connect to remote computer

.DESCRIPTION
Connect to remote computer onto which to deploy firewall.
This script will perform necessary initialization to enter PS session to remote computer,
in addition required authentication is made to use remote registry service and to run commands
against remote CIM server.

Following global variables or objects are created:
CimServer (variable), to be used by CIM commandlets to specify cim session to use
RemoteRegistry (PSDrive), administrative share C$ to remote computer (needed for authentication)
RemoteSession (PSSession), PS session object which represent remote session
RemoteCim (CimSession), CIM session object

.PARAMETER Domain
Computer name with which to connect for remoting

.PARAMETER Credential
Specify credentials which to use to connect to remote computer.
If not specified, you'll be asked for credentials

.PARAMETER Protocol
Specify protocol to use for test, HTTP, HTTPS or any.
The default value is "Any" which means HTTPS is used for connection to remote computer
and HTTP for local machine.

.PARAMETER Port
Optionally specify port number if the WinRM server specified by
-Domain parameter listens on non default port

.PARAMETER CertThumbprint
Optionally specify certificate thumbprint which is to be used for SSL.
Use this parameter when there are multiple certificates with same DNS entries.

.PARAMETER SessionOption
Specify custom PSSessionOption object to use for remoting.
The default value is controlled with PSSessionOption variable from caller scope

.PARAMETER ConfigurationName
Specify session configuration to use for remoting, this session configuration must
be registered and enabled on remote computer.
The default value is controlled with PSSessionConfigurationName preference variable

.PARAMETER ApplicationName
Specify application name use for remote connection,
Currently only "wsman" is supported.
The default value is controlled with PSSessionApplicationName preference variable

.PARAMETER CimOptions
Specify custom CIM session object to fine tune CIM sessions.
By default new blank CIM options object is made and set to use SSL if protocol is HTTPS

.EXAMPLE
PS> Connect-Computer COMPUTERNAME

.INPUTS
None. You cannot pipe objects to Connect-Computer

.OUTPUTS
None. Connect-Computer does not generate any output

.NOTES
None.
#>
function Connect-Computer
{
	[CmdletBinding(PositionalBinding = $false,
		HelpURI = "https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.Remote/Help/en-US/Connect-Computer.md")]
	[OutputType([void])]
	param (
		[Parameter(Position = 0)]
		[Alias("ComputerName", "CN")]
		[string] $Domain = [System.Environment]::MachineName,

		[Parameter()]
		[PSCredential] $Credential,

		[Parameter()]
		[ValidateSet("HTTP", "HTTPS", "Any")]
		[string] $Protocol = "Any",

		[Parameter()]
		[ValidateRange(1, 65535)]
		[int32] $Port,

		[Parameter(ParameterSetName = "ThumbPrint")]
		[string] $CertThumbprint,

		[Parameter()]
		[System.Management.Automation.Remoting.PSSessionOption]
		$SessionOption = $PSSessionOption,

		[Parameter()]
		[string] $ConfigurationName = $PSSessionConfigurationName,

		[Parameter()]
		[string] $ApplicationName = $PSSessionApplicationName,

		[Parameter()]
		[Microsoft.Management.Infrastructure.Options.CimSessionOptions]
		$CimOptions
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] ParameterSet = $($PSCmdlet.ParameterSetName):$($PSBoundParameters | Out-String)"

	# Replace localhost and dot with NETBIOS computer name
	if (($Domain -eq "localhost") -or ($Domain -eq "."))
	{
		$Domain = [System.Environment]::MachineName
	}

	if (($Domain -eq $PolicyStore) -and (Get-Variable -Name SessionEstablished -Scope Global -ErrorAction Ignore))
	{
		Write-Error -Category ConnectionError -TargetObject $Domain `
			-Message "Connection already established to $Domain, run Disconnect-Computer to disconnect"
		return
	}

	if (Get-Variable -Name SessionEstablished -Scope Global -ErrorAction Ignore)
	{
		Disconnect-Computer $PolicyStore
	}

	if ($PSSessionConfigurationName -ne $script:FirewallSession)
	{
		Write-Warning -Message "[$($MyInvocation.InvocationName)] Unexpected session configuration $PSSessionConfigurationName"
	}

	if (($Protocol -eq "HTTPS") -and ($Domain -eq [System.Environment]::MachineName))
	{
		Write-Error -Category NotImplemented -TargetObject $Protocol `
			-Message "HTTPS for localhost not implemented"
	}

	# WinRM service must be running at this point
	if ($WinRM.Status -ne [ServiceControllerStatus]::Running)
	{
		Write-Warning -Message "[$($MyInvocation.InvocationName)] WS-Management service supposed to be already running, starting now..."

		# NOTE: Unable to start if it's disabled
		if ($WinRM.StartType -eq [ServiceStartMode]::Disabled)
		{
			Set-Service -InputObject $WinRM -StartupType Manual
		}

		$WinRM.Start()
		$WinRM.WaitForStatus([ServiceControllerStatus]::Running, $ServiceTimeout)
	}

	$PSSessionParams = @{
		# PS session name
		Name = "RemoteSession"
		Authentication = "Default"
		ApplicationName = $ApplicationName
		SessionOption = $SessionOption
	}

	if (![string]::IsNullOrEmpty($CertThumbprint))
	{
		$PSSessionParams["CertificateThumbprint"] = $CertThumbprint
	}

	if ($Protocol -eq "Any")
	{
		$PSSessionParams["UseSSL"] = $Domain -ne [System.Environment]::MachineName
	}
	else
	{
		$PSSessionParams["UseSSL"] = $Protocol -eq "HTTPS"
	}

	if ($PSSessionParams["UseSSL"])
	{
		if (!$Port)
		{
			$PSSessionParams["Port"] = 5986
		}

		if (!$CimOptions)
		{
			# TODO: LocalStore needs a better place for adjustment
			# TODO: There is global variable for encoding
			$CimOptions = New-CimSessionOption -UseSsl -Encoding "Default" -UICulture $DefaultUICulture -Culture $DefaultCulture
		}
	}
	else
	{
		if (!$Port)
		{
			$PSSessionParams["Port"] = 5985
		}

		if (!$CimOptions)
		{
			$CimOptions = New-CimSessionOption -Protocol Wsman -UICulture $DefaultUICulture -Culture $DefaultCulture
		}
	}

	$CimParams = @{
		# CIM session name
		Name = "RemoteCim"
		Authentication = "Default"
		Port = $PSSessionParams["Port"]
		SessionOption = $CimOptions
		OperationTimeoutSec = $SessionOption.OperationTimeout.TotalSeconds
	}

	if ($CertThumbprint)
	{
		$CimParams["CertificateThumbprint"] = $CertThumbprint
	}

	# Remote computer or localhost over SSL
	if ($PSSessionParams["UseSSL"])
	{
		if (!$Credential)
		{
			# TODO: -Credential param, specify SERVER\UserName
			$Credential = Get-Credential -Message "Credentials are required to access '$Domain'"

			if (!$Credential)
			{
				# Will happen if credential request was dismissed using ESC key.
				Write-Error -Category InvalidOperation -Message "Credentials are required for remote session on '$Domain'"
			}
			elseif ($Credential.Password.Length -eq 0)
			{
				# Will happen when no password is specified
				Write-Error -Category InvalidData -Message "User '$($Credential.UserName)' must have a password"
				$Credential = $null
			}
		}

		$CimParams["Credential"] = $Credential
		$CimParams["ComputerName"] = $Domain

		$PSSessionParams["Credential"] = $Credential
		$PSSessionParams["ComputerName"] = $Domain
	}

	try
	{
		# MSDN: A CIM session is a client-side object representing a connection to a local computer or a remote computer.
		if (!(Get-CimSession -Name RemoteCim -ErrorAction Ignore))
		{
			Write-Information -Tags $MyInvocation.InvocationName -MessageData "INFO: Creating new CIM session to $Domain"

			# MSDN: -SkipTestConnection, by default it verifies port is open and credentials are valid,
			# verification is accomplished using a standard WS-Identity operation.
			# NOTE: Specifying computer name may fail if WinRM listens on loopback only
			Set-Variable -Name CimServer -Scope Global -Option ReadOnly -Force -Value (New-CimSession @CimParams)
		}
	}
	catch
	{
		Write-Error -Category ConnectionError -TargetObject $Domain `
			-Message "Creating CIM session to '$Domain' failed with: $($_.Exception.Message)"
		return
	}

	if ($Domain -ne ([System.Environment]::MachineName))
	{
		try
		{
			if (!(Get-PSDrive -Name RemoteRegistry -Scope Global -ErrorAction Ignore))
			{
				Write-Information -Tags $MyInvocation.InvocationName `
					-MessageData "INFO: Authenticating '$($Credential.UserName)' to computer '$Domain'"

				# Authentication is required to access remote registry
				# NOTE: Registry provider does not support credentials
				# TODO: More limited drive would be better
				[string] $SystemDrive = Get-CimInstance -Class Win32_OperatingSystem -CimSession $CimServer |
				Select-Object -ExpandProperty SystemDrive
				$SystemDrive = $SystemDrive.TrimEnd(":")

				New-PSDrive -Credential $Credential -PSProvider FileSystem -Scope Global -Name RemoteRegistry `
					-Root "\\$Domain\$SystemDrive$" -Description "Remote registry authentication" | Out-Null
			}
		}
		catch
		{
			Remove-CimSession -Name RemoteCim
			Remove-Variable -Name CimServer -Scope Global -Force

			Write-Error -Category AuthenticationError -TargetObject $Credential `
				-Message "Authenticating $($Credential.UserName) to '$Domain' failed with: $($_.Exception.Message)"
			return
		}
	}

	try
	{
		if (!(Get-PSSession -Name RemoteSession -ErrorAction Ignore))
		{
			Write-Information -Tags $MyInvocation.InvocationName -MessageData "INFO: Creating PS session to computer '$Domain'"
			New-PSSession @PSSessionParams | Out-Null
		}

		# TODO: For VM without external switch use -VMName
		# TODO: Temporarily not using because not in need to enter session
		# Write-Information -Tags $MyInvocation.InvocationName -MessageData "INFO: Entering remote session to computer '$Domain'"
		# Enter-PSSession -Name RemoteSession
	}
	catch
	{
		if (Get-CimSession -Name RemoteCim -ErrorAction Ignore)
		{
			Write-Verbose -Message "[$($MyInvocation.InvocationName)] Removing CIM session 'RemoteCim'"
			Remove-CimSession -Name RemoteCim
		}

		if (Get-Variable -Name CimServer -Scope Global -ErrorAction Ignore)
		{
			Write-Verbose -Message "[$($MyInvocation.InvocationName)] Removing variable 'CimServer'"
			Remove-Variable -Name CimServer -Scope Global -Force
		}

		if (Get-PSDrive -Name RemoteRegistry -Scope Global -ErrorAction Ignore)
		{
			Write-Verbose -Message "[$($MyInvocation.InvocationName)] Removing PSDrive 'RemoteRegistry'"
			Remove-PSDrive -Name RemoteRegistry -Scope Global
		}

		Write-Error -Category ConnectionError -TargetObject $Domain `
			-Message "Creating PS session to computer '$Domain' failed with: $($_.Exception.Message)"

		return
	}

	Set-Variable -Name SessionEstablished -Scope Global -Option ReadOnly -Value $true
}
