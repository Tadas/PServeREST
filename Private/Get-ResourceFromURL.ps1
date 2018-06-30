<#
	.SYNOPSIS
		Extracts the resource name from the URL
		
	.DESCRIPTION
		Takes "/time/month?SomeQuery=1" and returns "time" i.e the first node in the URL path
#>
function Get-ResourceFromURL {
	Param(
		[Parameter(Mandatory=$true)]
		[string]$RawURL
	)
	Write-Verbose "Get-ResourceFromURL| RawURL: $RawURL"

	$Resource = (($RawURL -split "\?")[0] -split "/")[1] # element 0 is empty because of leading "/"
	Write-Verbose "Get-ResourceFromURL| Extracted resource: $Resource"

	$VerificationRegex = '^(?:[a-zA-Z0-9]+|favicon.ico)$'
	if (-not ($Resource -match $VerificationRegex)){
		Write-Verbose "Get-ResourceFromURL| Resource name does not match the verification RegEx: $VerificationRegex"
		throw "Resource identifier contains invalid characters"
	}
	$Resource
}