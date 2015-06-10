function GET-favicon.ico {
	Param($Context)

	$Context.Response.Headers.Add("Content-Type","image/x-icon")
	[System.IO.File]::ReadAllBytes($(Resolve-Path (Join-Path $PSScriptRoot "favicon.ico")))
}
