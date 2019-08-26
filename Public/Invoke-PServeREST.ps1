function Invoke-PServeREST {
	Param(
		[string]$ListenURI = 'http://+:1234/',

		[ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
		[string]$ResourcesFolder = "$PSScriptRoot\..\DemoResources"
	)

	Write-Log "ListenURI = $ListenURI"

	$listener = New-Object System.Net.HttpListener
	$listener.Prefixes.Add($ListenURI)
	$listener.Start()
	
	try {
		while ($listener.IsListening){
			$Context = $listener.GetContext() # Blocking while waiting for request
			try {
				Write-Host ''
				Write-Host "> $($Context.Request.RemoteEndPoint.ToString()) -> $($Context.Request.HttpMethod) $($Context.Request.RawUrl)"

				$Resource = $(Get-ResourceFromURL $Context.Request.RawUrl) # Extract the resource user wants to access from the url

				# Generate resource handler file name and make sure it exists
				$ResourceHandlerFile = [System.IO.Path]::Combine( $ResourcesFolder, "$Resource.ps1" )
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
		Write-Log "Bye"
	}

}