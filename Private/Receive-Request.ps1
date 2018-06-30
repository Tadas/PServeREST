<#
	.SYNOPSIS
		Receives HTTP request body
#>
function Receive-Request {
	Param(
		[Parameter(Mandatory,ValueFromPipelineByPropertyName)]
		[System.Net.HttpListenerRequest]$Request
	)
	$Output = ""
 
	$Size = $Request.ContentLength64 + 1
	   
	$buffer = New-Object byte[] $Size
	do {
		$count = $Request.InputStream.Read($buffer, 0, $Size)
		Write-Verbose "Receive-Request | Received $count bytes"
		$Output += $Request.ContentEncoding.GetString($buffer, 0, $count)
	} until($count -lt $Size)
 
	$Request.InputStream.Close()
	$Output
}