function GET-Time {
	Param($Context)
	(Get-Date).ToString($Context.Request.QueryString['format'])
}


function POST-Time {
	Param($Context)
	"Sorry, I can't set time to '$($Context.Request.RawContent)'"
}