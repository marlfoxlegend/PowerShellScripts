function Add-Aliases () {
	[CmdletBinding(DefaultParameterSetName = "Single")]
	Param(
		[Parameter(ParameterSetName = "Single", Mandatory = $true, Position = 1)]
		[System.Management.Automation.AliasInfo]
		$AliasInfo,
		[Parameter(ParameterSetName="Single", Mandatory=$false, Position=0)]
		,
		[Parameter(ParameterSetName = "Multi", Mandatory = $false, Position = 1)]
		[String[]]
		$AliasNames
	)

	$ALIAS_PATH = "$env:USERPROFILE\Documents\PowerShell\alias_test.ps1";
	if (!(Test-Path $ALIAS_PATH)) {
		New-Item $ALIAS_PATH | Out-Null;
	}
	try {
		$Exports = @{"Path" = $ALIAS_PATH; "Name" = $AliasInfo; }
		if ($PSCmdlet.ParameterSetName -ilike "M*") {
			# $Exports["Name"]
			$Exports.Name = $AliasNames.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
		}
		Export-Alias -As Script -Append -NoClobber @Exports;
		"`nSUCCESS!`n" | Out-Host;
	}
	catch {
		$Error[0].ErrorDetails.Message | Out-Host;
	}

}

function Main() {
	# Initialize testing variables
	$single_alias = Get-Alias gcal;
	$multi_alias = Get-Alias
	# Test single instance of AliasInfo
	try {
		"Testing Single Alias" | Out-Host;
		Add-Aliases $test_onealias;
	}
	catch {
		("Error adding single alias: `n " + $Error[0].ErrorDetails.Message) | Out-Host
	}

	try {
		"Testing multiple aliases" | Out-Host;
		Add-Aliases -Many $test_aliases.ToString();
	}
	catch {
		("Error adding multiple aliases: `n " + $Error[0].ErrorDetails.Message) | Out-Host;
	}
	finally {
		"Cleaning up..." | Out-Host;
		Remove-Variable -Force -ErrorAction Continue -Name test_aliases, test_onealias;
		Remove-Item -Path Function:\Add-Aliases -Force -ErrorAction Continue;
		"Clean up completed!" | Out-Host;
	}
}