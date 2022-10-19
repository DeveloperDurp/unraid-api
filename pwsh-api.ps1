param(
    $password,
    $uri  
)

Function Send-Message {
    param(
        $message,
        $context,
        $responseformat
    )

    # Convert the data to UTF8 bytes
    [byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($message)

    # Set response
    $response = $context.Response
    $response.ContentLength64 = $buffer.length

    # Write response out and close
    $output = $response.OutputStream
    $output.Write($buffer, 0, $buffer.length)
    $output.Close()

}

Function Get-Message {
    param($request)

    if($request -eq "unraid"){

        #Login to unraid
        Invoke-WebRequest https://$uri/login -SessionVariable unraid -Method Post -Body @{username='root';password="$Password"} | Out-Null;

        #Get PSU Data from unraid
        $result = Invoke-RestMethod https://$uri/plugins/corsairpsu/status.php -WebSession $unraid;

        # Convert the returned data to JSON and set the HTTP content type to JSON
        Write-Output @{
            message = $($result | ConvertTo-Json)
            responseformat = 'application/json'
        }

        Remove-Variable unraid

        return
    }
    if($request -eq "health"){

        Write-Output @{
            message = "OK"
            responseformat = 'text/html'
        }

        return
    }

    # If no matching subdirectory/route is found generate a 404 message
    Write-Output @{
        message = "This is not the page you're looking for."
        responseformat = 'text/html'
    }

}


# Create a listener on port 8000
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://+:8000/') 
$listener.Start()
Write-Output 'Listening ...'

# Run until you send a GET request to /end
while ($true) {
    $context = $listener.GetContext() 

    # Capture the details about the request
    $request = $context.Request

    # Break from loop if GET request sent to /end
    if ($request.Url -match '/end$') { 
        break 
    } 
    else {

        # Split request URL to get command and options
        $requestvars = ([String]$request.Url).split("/",4)[3]
        Write-Output "$(get-date) | $requestvars"


        $result = Get-Message -request $requestvars

        Send-Message -context $context -responseformat $result.responseformat -message $result.message

    }    
}

#Terminate the listener
$listener.Stop()
