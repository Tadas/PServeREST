$ErrorActionPreference = "Stop"

Get-ChildItem -Path $PSScriptRoot\Modules\ -Directory -ErrorAction SilentlyContinue | ForEach-Object {
	Write-Verbose "[[[ Importing $($_.FullName) ]]]"
	Import-Module $_.FullName -Force
}

Set-LoggingDefaultLevel -Level 'NOTSET'
Add-LoggingTarget -Name Console


$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

foreach($Import in @($Public + $Private)){
	Write-Verbose "[[[ Loading $($Import.FullName) ]]]"
	try {
		. $Import.FullName
	} catch {
		Write-Error -Message "Failed to import function $($Import.FullName): $_"
	}
}

Export-ModuleMember -Function $Public.Basename