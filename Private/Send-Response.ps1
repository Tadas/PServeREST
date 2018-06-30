<#
	.SYNOPSIS
		Writes the response and closes Response object
#>
function Send-Response {
	Param(
		[Parameter(Position=0, Mandatory=$true)]
		[System.Net.HttpListenerResponse]$Response,
		
		[Parameter(Position=1, Mandatory=$true)]
		[int]$StatusCode = 200,
		
		[Parameter(Position=2, ValueFromPipeline=$true)]
		$Content = ""
	)
	# Seems like we need to set the status code first before we write data. Otherwise 200 is set by default
	$Response.StatusCode = $StatusCode

	Write-Verbose "Send-ResponseNew| Content type is $($Content.GetType().ToString())"
	switch($Content.GetType().ToString()){
		"System.Object[]" { $buffer = $Content }
		default { $buffer = [System.Text.Encoding]::UTF8.GetBytes($Content) }
	}
	
	$Response.ContentLength64 = $buffer.Length
	$Response.OutputStream.Write($buffer, 0, $buffer.Length)
	$Response.Close()
}