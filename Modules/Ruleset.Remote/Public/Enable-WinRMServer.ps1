
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

<#
.SYNOPSIS
Configure WinRM server for CIM and PowerShell remoting

.DESCRIPTION
Configures local machine to accept remote CIM and PowerShell requests using WS-Management.
In addition it initializes specialized remoting session configuration as well as most common
issues are handled and attempted to be resolved or bypassed automatically.

If specified -Protocol is set to HTTPS, it will export public key (DER encoded CER file)
to default repository location (\Exports), which you should then copy to client machine
to be picked up by Set-WinRMClient and used for communication over SSL.

.PARAMETER Protocol
Specifies listener protocol to HTTP, HTTPS or both.
By default only HTTPS is configured.

.PARAMETER CertFile
Optionally specify custom certificate file.
By default new self signed certifcate is made and trusted if no suitable certificate exists.
This must be PFX file.

.PARAMETER CertThumbprint
Optionally specify certificate thumbprint which is to be used for SSL.
Use this parameter when there are multiple certificates with same DNS entries.

.PARAMETER Force
If specified, overwrites an existing exported certificate (*.cer) file,
unless it has the Read-only attribute set.

.EXAMPLE
PS> Enable-WinRMServer

Configures server machine to accept remote commands using SSL.
If there is no server certificate a new one self signed is made and put into trusted root.

.EXAMPLE
PS> Enable-WinRMServer -CertFile C:\Cert\Server2.pfx -Protocol Any

Configures server machine to accept remote commands using using either HTTPS or HTTP.
Client will authenticate with specified certificate for HTTPS.

.EXAMPLE
PS> Enable-WinRMServer -Protocol HTTP

Configures server machine to accept remoting commands trough HTTP.

.INPUTS
None. You cannot pipe objects to Enable-WinRMServer

.OUTPUTS
[void]
[System.Xml.XmlElement]
[Selected.System.Xml.XmlElement]

.NOTES
NOTE: Set-WSManQuickConfig -UseSSL will not work if certificate is self signed
TODO: How to control language? in WSMan:\COMPUTER\Service\DefaultPorts and
WSMan:\COMPUTERService\Auth\lang (-Culture and -UICulture?)
TODO: Authenticate users using certificates optionally or instead of credential object
TODO: Parameter to apply only additional config as needed instead of hard reset all options (-Strict)
TODO: Configure server remotely either with WSMan or trough SSH, to test and configure server
remotely use Connect-WSMan and New-WSManSessionOption

.LINK
https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.Remote/Help/en-US/Enable-WinRMServer.md

.LINK
https://docs.microsoft.com/en-us/powershell/module/microsoft.wsman.management

.LINK
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_session_configurations

.LINK
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_session_configuration_files

.LINK
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-pssessionconfiguration

.LINK
https://docs.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management

.LINK
winrm help config
#>
function Enable-WinRMServer
{
	[CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = "Default", SupportsShouldProcess = $true, ConfirmImpact = "High",
		HelpURI = "https://github.com/metablaster/WindowsFirewallRuleset/blob/master/Modules/Ruleset.Remote/Help/en-US/Enable-WinRMServer.md")]
	[OutputType([void], [System.Xml.XmlElement])]
	param (
		[Parameter()]
		[ValidateSet("HTTP", "HTTPS", "Any")]
		[string] $Protocol = "HTTPS",

		[Parameter(ParameterSetName = "File")]
		[string] $CertFile,

		[Parameter(ParameterSetName = "ThumbPrint")]
		[string] $CertThumbprint,

		[Parameter()]
		[switch] $Force
	)

	Write-Debug -Message "[$($MyInvocation.InvocationName)] ParameterSet = $($PSCmdlet.ParameterSetName):$($PSBoundParameters | Out-String)"

	. $PSScriptRoot\..\Scripts\WinRMSettings.ps1 -IncludeServer
	$Domain = [System.Environment]::MachineName

	<# MSDN: The Enable-PSRemoting cmdlet performs the following operations:
	Runs the Set-WSManQuickConfig cmdlet, which performs the following tasks:
	1. Starts the WinRM service.
	2. Sets the startup type on the WinRM service to Automatic.
	3. Creates a listener to accept requests on any IP address.
	4. Enables a firewall exception for WS-Management communications.
	5. Creates the simple and long name session endpoint configurations if needed.
	6. Enables all session configurations.
	7. Changes the security descriptor of all session configurations to allow remote access.
	Restarts the WinRM service to make the preceding changes effective.
	#>
	Write-Information -Tags $MyInvocation.InvocationName -MessageData "INFO: Configuring WinRM service"

	Initialize-WinRM

	if ($PSVersionTable.PSEdition -eq "Core")
	{
		# "PowerShell." + "current PowerShell version"
		# "PowerShell.7", untied to any specific PowerShell version.
		$DefaultSession = "PowerShell.$($PSVersionTable.PSVersion.Major)*"
	}
	else
	{
		# "Microsoft.PowerShell" is used for sessions by default
		# "Microsoft.PowerShell32" is used for sessions by 32bit host
		# "Microsoft.PowerShell.Workflow" is used by workflows
		$DefaultSession = "Microsoft.PowerShell*"
	}

	if ($PSCmdlet.ShouldProcess("WS-Management (WinRM) service", "Remove default session configurations"))
	{
		# Remove all default and repository specifc session configurations
		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Removing default session configurations"
		Get-PSSessionConfiguration | Where-Object {
			$_.Name -like $DefaultSession -or
			$_.Name -eq $script:FirewallSession
		} | Unregister-PSSessionConfiguration -NoServiceRestart -Force
	}

	# Re-register repository specific session configuration
	Write-Verbose -Message "[$($MyInvocation.InvocationName)] Registering custom session configuration"

	# A null value does not affect the session configuration.
	# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/new-pstransportoption
	$TransportConfig = @{
		# Limits the number of sessions that use the session configuration.
		# The MaxSessions parameter corresponds to the MaxShells property of a session configuration.
		# The default value is 25.
		MaxSessions = 1

		# Determines how command output is managed in disconnected sessions when the output buffer becomes full
		# "Block", When the output buffer is full, execution is suspended until the buffer is clear
		OutputBufferingMode = "Block"
	}

	# [Microsoft.WSMan.Management.WSManConfigContainerElement]
	$SessionConfigParams = @{
		Name = $script:FirewallSession
		Path = "$ProjectRoot\Config\RemoteFirewall.pssc"

		# Determines whether a 32-bit or 64-bit version of the PowerShell process is started in sessions
		# x86 or amd64,
		# The default value is determined by the processor architecture of the computer that hosts the session configuration.
		ProcessorArchitecture = "amd64"

		# Maximum amount of data that can be sent to this computer in any single remote command.
		# The default is 50 MB
		MaximumReceivedDataSizePerCommandMB = 50

		# Maximum amount of data that can be sent to this computer in any single object.
		# The default is 10 MB
		MaximumReceivedObjectSizeMB = 10

		# Disabled, this configuration cannot be used for remote or local access to the computer.
		# Local, allows users of the local computer to create a loopback session on the same computer.
		# Remote, allows local and remote users to create sessions and run commands on this computer.
		AccessMode = "Remote"

		# The apartment state of the threading module to be used:
		# MTA: The Thread will create and enter a multithreaded apartment.
		# STA: The Thread will create and enter a single-threaded apartment.
		# Unknown: The ApartmentState property has not been set.
		# https://docs.microsoft.com/en-us/dotnet/api/system.threading.apartmentstate
		ThreadApartmentState = "Unknown"

		# The specified script runs in the new session that uses the session configuration.
		# If the script generates an error, even a non-terminating error, the session is not created.
		# TODO: Following path is created by "MountUserDrive" option in RemoteFirewall.pssc (another option is: ScriptsToProcess in *.pssc)
		# StartupScript = "$env:LOCALAPPDATA\Microsoft\Windows\PowerShell\DriveRoots\$env:USERDOMAIN_$env:USERNAME\ProjectSettings.ps1"

		# The default value is UseCurrentThread.
		# https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.runspaces.psthreadoptions
		ThreadOptions = "UseCurrentThread"

		# Advanced options for a session configuration
		TransportOption = New-PSTransportOption @TransportConfig

		# Specifies credentials for commands in the session.
		# By default, commands run with the permissions of the current user.
		# RunAsCredential = Get-Credential
	}

	if ($PSCmdlet.ShouldProcess("WS-Management (WinRM) service", "Register custom session configuration"))
	{
		# NOTE: Register-PSSessionConfiguration may fail in Windows PowerShell
		Set-StrictMode -Off

		# TODO: -RunAsCredential $RemoteCredential -UseSharedProcess -SessionTypeOption `
		# -SecurityDescriptorSddl "O:NSG:BAD:P(A;;GA;;;BA)(A;;GR;;;IU)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)"
		Register-PSSessionConfiguration @SessionConfigParams -NoServiceRestart -Force | Out-Null
		Set-StrictMode -Version Latest
	}

	if ($PSCmdlet.ShouldProcess("WS-Management (WinRM) service", "Recreate default session configurations"))
	{
		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Recreating default session configurations"

		try
		{
			Unblock-NetProfile

			# TODO: Use Set-WSManQuickConfig since or if recreating default session configurations is not absolutely needed
			Enable-PSRemoting -Force | Out-Null
		}
		catch [System.OperationCanceledException]
		{
			Write-Warning -Message "Operation incomplete because $($_.Exception.Message)"
		}
		catch
		{
			Write-Error -ErrorRecord $_
		}
	}

	if ($PSCmdlet.ShouldProcess("WS-Management (WinRM) service", "Disable unneeded default session configurations"))
	{
		# Disable unused built in session configurations
		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Disabling unneeded default session configurations"

		if ($PSVersionTable.PSEdition -eq "Core")
		{
			Disable-PSSessionConfiguration -Name "PowerShell.$($PSVersionTable.PSVersion.Major)" -NoServiceRestart -Force
			Disable-PSSessionConfiguration -Name "PowerShell.$($PSVersionTable.PSVersion.ToString())" -NoServiceRestart -Force
		}
		else
		{
			Disable-PSSessionConfiguration -Name Microsoft.PowerShell32 -NoServiceRestart -Force
			Disable-PSSessionConfiguration -Name Microsoft.Powershell.Workflow -NoServiceRestart -Force
		}
	}

	if ($PSCmdlet.ShouldProcess("WS-Management (WinRM) service", "Configure WinRM server listener"))
	{

		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Configuring WinRM server listener"
		Get-ChildItem WSMan:\localhost\listener | Remove-Item -Recurse

		if ($Protocol -ne "HTTPS")
		{
			# Add new HTTP listener
			Write-Verbose -Message "[$($MyInvocation.InvocationName)] Configuring HTTP listener options"
			New-WSManInstance -ResourceURI winrm/config/Listener -ValueSet @{ Enabled = $true } `
				-SelectorSet @{ Address = "*"; Transport = "HTTP" } | Out-Null
		}

		if ($Protocol -ne "HTTP")
		{
			Write-Verbose -Message "[$($MyInvocation.InvocationName)] Configuring HTTPS listener options"

			# SSL certificate
			[hashtable] $SSLCertParams = @{
				ProductType = "Server"
				Force = $Force
				PassThru = $true
			}

			if (![string]::IsNullOrEmpty($CertFile)) { $SSLCertParams["CertFile"] = $CertFile }
			elseif (![string]::IsNullOrEmpty($CertThumbprint)) { $SSLCertParams["CertThumbprint"] = $CertThumbprint }
			$Cert = Register-SslCertificate @SSLCertParams

			if ($Cert)
			{
				# Add new HTTPS listener
				New-WSManInstance -ResourceURI winrm/config/Listener -SelectorSet @{ Address = "*"; Transport = "HTTPS" } `
					-ValueSet @{ Hostname = $Domain; Enabled = $true; CertificateThumbprint = $Cert.Thumbprint } | Out-Null
			}
		}
	}

	# NOTE: If this plugin is disabled, PS remoting will work but CIM commands will fail
	$WmiPlugin = Get-Item WSMan:\localhost\Plugin\"WMI Provider"\Enabled
	if ($WmiPlugin.Value -ne $true)
	{
		if ($PSCmdlet.ShouldProcess("WS-Management (WinRM) service", "Enable WMI Provider plugin"))
		{
			Write-Information -Tags $MyInvocation.InvocationName -MessageData "INFO: Enabling WMI Provider plugin"
			Set-Item WSMan:\localhost\Plugin\"WMI Provider"\Enabled -Value $true -WA Ignore
		}
	}

	# Specify acceptable client authentication methods
	Write-Verbose -Message "[$($MyInvocation.InvocationName)] Configuring WinRM server authentication options"

	# NOTE: Not assuming WinRM responds, contact localhost
	if (Get-CimInstance -Class Win32_ComputerSystem | Select-Object -ExpandProperty PartOfDomain)
	{
		$AuthenticationOptions["Kerberos"] = $true
	}

	if ($Protocol -ne "HTTP")
	{
		$AuthenticationOptions["Certificate"] = $true
	}

	if ($PSCmdlet.ShouldProcess("WS-Management (WinRM) service", "Configure WinRM authentication and default ports"))
	{
		Set-WSManInstance -ResourceURI winrm/config/service/auth -ValueSet $AuthenticationOptions | Out-Null

		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Configuring WinRM default server ports"
		Set-WSManInstance -ResourceURI winrm/config/service/DefaultPorts -ValueSet $PortOptions | Out-Null
	}

	Write-Verbose -Message "[$($MyInvocation.InvocationName)] Configuring WinRM server options"

	if ($Protocol -eq "HTTPS")
	{
		$ServerOptions["AllowUnencrypted"] = $false
	}

	if ($PSCmdlet.ShouldProcess("WS-Management (WinRM) service", "Configure WinRM server options"))
	{
		# NOTE: This will fail if any adapter is on public network, using winrm gives same result:
		# cmd.exe /C 'winrm set winrm/config/service @{MaxConnections=300}'
		Set-WSManInstance -ResourceURI winrm/config/service -ValueSet $ServerOptions | Out-Null
	}

	if ($PSCmdlet.ShouldProcess("WS-Management (WinRM) service", "Configure WinRM protocol options"))
	{
		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Configuring WinRM protocol options"
		Set-WSManInstance -ResourceURI winrm/config -ValueSet $ProtocolOptions | Out-Null
	}

	Restore-NetProfile

	if ($PSCmdlet.ShouldProcess("Windows firewall, persistent store", "Remove 'Windows Remote Management - Compatibility Mode' firewall rules"))
	{
		# Remove WinRM predefined compatibility rules
		Remove-NetFirewallRule -Group $WinRMCompatibilityRules -Direction Inbound -PolicyStore PersistentStore
	}

	if ($script:Workstation)
	{
		if ($PSCmdlet.ShouldProcess("Windows firewall, persistent store", "Restore 'Windows Remote Management' firewall rules to default"))
		{
			# Restore public profile rules to local subnet which is the default
			Get-NetFirewallRule -Group $WinRMRules -PolicyStore PersistentStore | Where-Object {
				$_.Profile -like "*Public*"
			} | Set-NetFirewallRule -RemoteAddress LocalSubnet
		}
	}

	if ($PSCmdlet.ShouldProcess("WS-Management (WinRM) service", "restart service"))
	{
		Write-Verbose -Message "[$($MyInvocation.InvocationName)] Restarting WinRM service"
		$WinRM.Stop()
		$WinRM.WaitForStatus([ServiceControllerStatus]::Stopped, $ServiceTimeout)
		$WinRM.Start()
		$WinRM.WaitForStatus([ServiceControllerStatus]::Running, $ServiceTimeout)
	}

	$TokenKey = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
	$TokenValue = $TokenKey.GetValue("LocalAccountTokenFilterPolicy")

	if (!$WhatIfPreference -and ($TokenValue -ne 1))
	{
		Write-Error -Category InvalidResult -TargetObject $TokenValue `
			-Message "LocalAccountTokenFilterPolicy was not enabled"
	}

	Write-Information -Tags $MyInvocation.InvocationName -MessageData "INFO: WinRM server configuration was successful"
}