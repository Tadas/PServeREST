Param(
	[string]$ListenUrl = 'http://+:1234/'
)

Add-Type -AssemblyName System.Web # For [System.Web.HttpUtility]::ParseQueryString (possibly used in resource handlers)

$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

foreach($Import in @($Public + $Private)){
	Write-Verbose "Loading $($Import.FullName)"
	try {
		. $Import.FullName
	} catch {
		Write-Error -Message "Failed to import function $($Import.FullName): $_"
	}
}



$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($ListenUrl)
$listener.Start()
 
Write-Host "Listening at $ListenUrl..."

try {
    while ($listener.IsListening){
        $Context = $listener.GetContext() # Blocking while waiting for request
        try {
            Write-Host ''
            Write-Host "> $($Context.Request.RemoteEndPoint.ToString()) -> $($Context.Request.HttpMethod) $($Context.Request.RawUrl)"

            $Resource = $(Get-ResourceFromURL $Context.Request.RawUrl) # Extract the resource user wants to access from the url

            # Generate resource handler file name and make sure it exists
            $ResourceHandlerFile = Join-Path $PSScriptRoot "Resources\$Resource.ps1"
            Write-Verbose "MainLoop| ResourceHandlerFile: $ResourceHandlerFile"
            if ( -not (Test-Path -LiteralPath $ResourceHandlerFile -Type Leaf) ){
                Write-Verbose "MainLoop| Resource handler script not found"
                Send-Response $Context.Response -StatusCode 404 "Resource handler script not found"
                Continue
            }

            # Run the <Resource>.ps1 to get the handler functions into our scope
            . $ResourceHandlerFile

            # Generate resource handler function name and make sure we have it our scope 
            $ResourceHandlerProc = "$($Context.Request.HttpMethod)-$Resource"
            Write-Verbose "MainLoop| ResourceHandlerProc: $ResourceHandlerProc"
            if ( -not (Get-Command -Name $ResourceHandlerProc -ErrorAction SilentlyContinue) ){
                Write-Verbose "MainLoop| Resource handler procedure not found"
                Send-Response $Context.Response -StatusCode 405 "Resource handler procedure not found"    
            }

            # Receive content if POST or PUT
            if(($Context.Request.HttpMethod -eq 'POST') -or ($Context.Request.HttpMethod -eq 'PUT')){
                Write-Verbose "MainLoop| Receiving POST content"
                $Context.Request | Add-Member -MemberType NoteProperty -Name RawContent -Value $(Receive-Request $Context.Request)
            }

            # Run the handler function
            Write-Verbose "MainLoop| >Calling handler"
            $ResponseBody = & $ResourceHandlerProc $Context
            Write-Verbose "MainLoop| <Back from handler"
            Write-Host "  $($ResponseBody.Length) byte response"

            Send-Response $Context.Response -StatusCode 200 $ResponseBody


        } catch {
            Write-Verbose "MainLoop| Exception: $($_.ToString())"
            Send-Response $Context.Response -StatusCode 500 $_.ToString()
        }

        Write-Host "< $($Context.Response.StatusCode)"
    }
} finally {
    $listener.Stop()
}