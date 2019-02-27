A barebones PowerShell HTTP server. With favicon, too!

# Getting started
  1. Grant permissions on the HTTP prefix you want (that way the script does not need to run as admin)
`netsh http add urlacl url=http://+:1234/ user=Everyone`

  2.  ```powershell
      Import-Module PServeREST
      Invoke-PServeREST
      ```

# How does it work?
Accessing `http://localhost:1234/<resource>` runs `Resources\<resource>.ps1` script. This resource script should contain functions named `<HTTP_VERB>-<resource>` that handles a verb for this resource (e.g GET-Time, POST-Name, PUT-Something and etc.). Whatever the function returns is returned to the client.

The resource script is dot-sourced on every request so you can edit, save & test it immediately.
