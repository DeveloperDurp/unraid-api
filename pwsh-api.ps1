param(
    $password,
    $uri  
)
# Create a listener on port 8000
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://+:8000/') 
$listener.Start()
'Listening ...'

# Run until you send a GET request to /end
while ($true) {
    $context = $listener.GetContext() 

    # Capture the details about the request
    $request = $context.Request

    # Setup a place to deliver a response
    $response = $context.Response

    # Break from loop if GET request sent to /end
    if ($request.Url -match '/end$') { 
        break 
    } 
    else {

    # Split request URL to get command and options
    $requestvars = ([String]$request.Url).split("/");        

    # If a request is sent to http:// :8000/unraid
    if ($requestvars[3] -eq "unraid") {

        Write-Output "Getting unraid PSU data"
        Invoke-WebRequest https://$uri/login -SessionVariable unraid -Method Post -Body @{username='root';password="$Password"} | Out-Null;

        #Get PSU Data from unraid
        $result = Invoke-RestMethod https://$uri/plugins/corsairpsu/status.php -WebSession $unraid;

        # Convert the returned data to JSON and set the HTTP content type to JSON
        $message = $result | convertto-json; 
        $response.ContentType = 'application/json';

    } 
    elseif ($requestvars[3] -eq "Health"){

        Write-Output "HealthCheck"
        $Message = "OK"      

    }
    else {

        # If no matching subdirectory/route is found generate a 404 message
        $message = "This is not the page you're looking for.";
        $response.ContentType = 'text/html' ;

    }

    # Convert the data to UTF8 bytes
    [byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($message)

    # Set length of response
    $response.ContentLength64 = $buffer.length

    # Write response out and close
    $output = $response.OutputStream
    $output.Write($buffer, 0, $buffer.length)
    $output.Close()
    }    
}

#Terminate the listener
$listener.Stop()
