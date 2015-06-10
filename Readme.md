# What? #
A RESTish server with PowerShell! With favicon, too!

# Why?? #
Why not?

# How??? #
  1. Grant permissions on the HTTP prefix you want (that way the script does not need to run as admin)
`netsh http add urlacl url=http://+:1234/ user=Everyone`
  3. Run `PServeREST.ps1`

# WTF???? #
Accessing `http://localhost:1234/<resource>` runs `Resources\<resource>.ps1` script. This resource script should contain a function named `<HTTP_VERB>-<resource>` that handles verbs for this resource (e.g GET-Time, POST-Name, PUT-Something and etc.). Whatever the function returns is returned to the client.

The resource script is ran on every request so you can edit, save & test it immediately.
