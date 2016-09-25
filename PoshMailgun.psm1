<#
    .Synopsis
        Sends an email using the mailgun API

    .DESCRIPTION
        Send a HTML formatted email with to/cc/bcc recipients via the 
        Mailgun API
        Signup to https://mailgun.com/app/dashboard and API key is bottom right

    .PARAMETER ApiKey
        Mandatory
        API key for Mailgun
        API doc: https://help.mailgun.com/hc/en-us/articles/203380100-Where-can-I-find-my-API-key-and-SMTP-credentials-

    .PARAMETER Domain
        Mandatory
        The Mailgun domain for your account

    .PARAMETER FromName
        Mandatory
        The from name used to send the email

    .PARAMETER ToEmail
        Mandatory
        Array of email addresses to send your email to
 
    .PARAMETER Subject
        Mandatory
        The subject of the email
 
    .PARAMETER Html
        Mandatory
        The html formatted content of the email

    .PARAMETER ToCc
        Optional
        Array of email addresses to cc your email to

    .PARAMETER ToBcc
        Optional
        Array of email addresses to bcc your email to

    .EXAMPLE
        Send-MailgunMailMessage -ApiKey "f0b35185ec994312bff9c29221f360a7" -Domain "sandbox281c808e9570499bb24d83274b5f9bbd.mailgun.org" `
        -FromName "Powell Shellington" -FromEmail "mailgun@$Domain" -ToEmail "user@example.com" -Subject "Test email" -Html "<h1>Hello world</h1>"
        
    .OUTPUTS
        Message ID and status

    .NOTES
        Written by Martin Howlett @WillCode4Pizza
        Docs: https://documentation.mailgun.com/api-sending.html#sending
#>
Function Send-MailgunMailMessage
{
    Param (

        [Parameter(Mandatory=$true)][string]$ApiKey,
        [Parameter(Mandatory=$true)][string]$Domain,
        [Parameter(Mandatory=$true)][string]$FromName,
        [Parameter(Mandatory=$true)][string]$FromEmail,
        [Parameter(Mandatory=$true)][array]$ToEmail,
        [Parameter(Mandatory=$true)][string]$Subject,
        [Parameter(Mandatory=$true)][string]$Html,
        [Parameter()][array]$ToCc,
        [Parameter()][array]$ToBcc
    )

    #Create base64 string for the API key
    $pair = "api:$ApiKey"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $basicAuthValue = "Basic $base64"
    
    #add it to our header
    $headers = @{Authorization = $basicAuthValue}

    #create the url
    $uri = "https://api.mailgun.net/v3/$domain/messages"

    #create our invoke-restmethod params
    $params = @{
      from="$FromName $FromEmail"
      to="$ToEmail"
      subject="$Subject"
      html="$Html"
    }
    
    if($ToCc)
    {
        $params.add("cc",$ToCc)       
    }

    if($ToBcc)
    {
        $params.add("bcc",$ToBcc)       
    }

    $response = Invoke-RestMethod -uri $uri -Headers $headers -Method Post -Body $params
    Return $response
}