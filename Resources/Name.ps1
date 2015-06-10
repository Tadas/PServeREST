# Avoid overwriting our variables if they already exist
if (-not (Test-Path variable:script:Name)){
	$script:Name = "Thomas Anderson"
}


function GET-Name {
	Param($Context)
	"Hello, $script:Name!"
}


function PUT-Name {
	Param($Context)
	
	if ($Request.ContentType -eq "application/x-www-form-urlencoded"){
		$FormData = [System.Web.HttpUtility]::ParseQueryString($Context.Request.RawContent)
		$script:Name = $FormData['Name']
	} else {
		$script:Name = $Context.Request.RawContent
	}
	"Name set"
}