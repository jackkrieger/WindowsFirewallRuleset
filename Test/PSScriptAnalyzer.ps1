
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
Run PSScriptAnalyzer on repository

.DESCRIPTION
Run PSScriptAnalyzer on repository and format detailed and relevant output

.PARAMETER Severity
Specify severity of rules which are to be reported.
By default all severities are reported.

.PARAMETER SuppressedOnly
If specified only suppressed rules are reported

.PARAMETER Log
If specified, analysis results are logged

.PARAMETER Force
If specified, this unit test runs without prompt to allow execute

.EXAMPLE
PS> .\PSScriptAnalyzer.ps1

Shows code analysis status in the terminal only

.EXAMPLE
PS> .\PSScriptAnalyzer.ps1 -Force -Log

Shows code analysis status in the terminal and writes results to log file

.INPUTS
None. You cannot pipe objects to PSScriptAnalyzer.ps1

.OUTPUTS
None. PSScriptAnalyzer.ps1 does not generate any output

.NOTES
None.
#>

#Requires -Version 5.1

[CmdletBinding()]
param (
	[Parameter()]
	[ValidateSet("Error", "Warning", "Information")]
	[string[]] $Severity,

	[Parameter()]
	[switch] $SuppressedOnly,

	[Parameter()]
	[switch] $Log,

	[Parameter()]
	[switch] $Force
)

. $PSScriptRoot\..\Config\ProjectSettings.ps1 $PSCmdlet

if (Approve-Execute -Accept "Run PSScriptAnalyzer on repository" -Deny "Skip code analysis operation" -Force:$Force)
{
	$ErrorActionPreference = "Stop"
	# NOTE: Importing the module explicitly resolves errors which the PSScriptAnalyzer may throw for first run
	Import-Module -Name PSScriptAnalyzer -RequiredVersion $RequireAnalyzerVersion

	if ($log)
	{
		$FileName = "$LogsFolder\Test\PSScriptAnalyzer_suppressed_$(Get-Date -Format "dd.MM.yy").log"
	}
	else
	{
		$FileName = "$LogsFolder\Test\PSScriptAnalyzer_$(Get-Date -Format "dd.MM.yy").log"
	}

	if (Test-Path -Path $FileName)
	{
		Write-Verbose -Message "[$ThisScript] Removing previous log '$FileName'"
		Remove-Item -Path $FileName
	}

	$Errors = 0
	$Warnings = 0
	$Infos = 0

	$AnalyzerParams = @{
		Path = $ProjectRoot
		Recurse = $true
		Settings = "$ProjectRoot\Config\PSScriptAnalyzerSettings.psd1"
	}

	if (![string]::IsNullOrEmpty($Severity))
	{
		$Severity = $Severity | Select-Object -Unique
		$AnalyzerParams.Severity = $Severity
	}

	Write-Information -Tags "Test" -MessageData "INFO: Analysing code..."

	if ($SuppressedOnly)
	{
		$AnalyzerParams.SuppressedOnly = $SuppressedOnly

		if ($Log)
		{
			$HeaderStack.Push("PSScryptAnalyzer surpressed rule analysis")
		}
	}
	elseif ($Log)
	{
		$HeaderStack.Push("PSScryptAnalyzer analysis")
	}

	Invoke-ScriptAnalyzer @AnalyzerParams |	ForEach-Object {
		switch ($_.Severity)
		{
			"Error" { ++$Errors; break }
			"Warning" { ++$Warnings; break }
			"Information" { ++$Infos; break }
		}

		Format-List -InputObject $_ -Property Severity, RuleName, Message, ScriptPath, Line

		if ($Log)
		{
			$HashMessage = [ordered] @{
				Severity = $_.Severity
				RuleName = $_.RuleName
				Message = $_.Message
				ScriptPath = $_.ScriptPath
				Line = $_.Line
			}

			Write-LogFile -Path $LogsFolder\Test -LogName PSScriptAnalyzer -Hash $HashMessage
		}
	}

	$Message = "PSScriptAnalyzer completed with "
	if ([string]::IsNullOrEmpty($Severity) -or ($Severity.Count -eq 3))
	{
		$Message += "$Errors errors, $Warnings warnings and $Infos information"
	}
	else
	{
		if ($Severity.Count -eq 2 ) { $Separator = " and " } else { $Separator = "" }
		switch ($Severity)
		{
			"Error" { $Message += "$Errors errors$Separator" }
			"Warning" { $Message += "$Warnings warnings$Separator" }
			"Information" { $Message += "$Infos information" }
		}

		$Message = $Message.TrimEnd($Separator)
	}

	Write-Information -Tags "Test" -MessageData "[$ThisScript] INFO: $Message"

	if ($Log)
	{
		Write-LogFile -Tags "PSScriptAnalyzer" -Path $LogsFolder\Test -LogName PSScriptAnalyzer -Message $Message
		$HeaderStack.pop() | Out-Null
	}

	Update-Log
}
