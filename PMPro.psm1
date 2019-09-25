#using the httputility from system.web to do the API calls
[System.Reflection.Assembly]::LoadWithPartialName("System.Web") | out-null

#Remove old module from current session
$ExecutionContext.SessionState.Module.OnRemove = { Remove-Module myPMPro }


#Generates a random password from the characters in the variable $charactersets
function pmproNewPassword
{
    param
    (
        [Int32]$Length = 15,
        [Int32]$MustIncludeSets = 3
    )

    $CharacterSets = @("ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwzyz","0123456789","!$-#")

    $Random = New-Object Random

    $Password = ""
    $IncludedSets = ""
    $IsNotComplex = $true
    while ($IsNotComplex -or $Password.Length -lt $Length)
    {
        $Set = $Random.Next(0, 4)
        if (!($IsNotComplex -and $IncludedSets -match "$Set" -And $Password.Length -lt ($Length - $IncludedSets.Length)))
        {
            if ($IncludedSets -notmatch "$Set")
            {
                $IncludedSets = "$IncludedSets$Set"
            }
            if ($IncludedSets.Length -ge $MustIncludeSets)
            {
                $IsNotcomplex = $false
            }

            $Password = "$Password$($CharacterSets[$Set].SubString($Random.Next(0, $CharacterSets[$Set].Length), 1))"
        }
    }
    return $Password
}
#Decrypts the authorization token from PMP API user account (if you use an encrypted hash of the authorization token in myPMPro.ps1)
function pmpproEncAuthToken()
{
    return (ConvertFrom-SecureString -SecureString (Read-Host -AsSecureString -Prompt "PlainText AUTH Token"))
}

#Function for generating friendly error messages ()
function _restThrowError()
{
    param
    (
        [parameter(Mandatory=$true)][String]$text
    )

    <#

        try
        {
            $resp = ConvertFrom-Json -InputObject $text
        }
        catch
        {
            throw $text
        }
    
        $formatError = New-Object System.FormatException -ArgumentList ($resp.errorCode + " : " + $resp.errorSummary)
        $formatError.HelpLink = $text
        $formatError.Source = $Error[0].Exception

    #>

    throw $text
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER inst
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>

#Function to check if instance exists in myPMPro.ps1 settings file
function _testInstance()
{
    param
    (
        [parameter(Mandatory=$true)][alias("instance")][String]$inst
    )
    if ($PMPInstances[$inst])
    {
        return $true
    } else {
        $estring = "The Org:" + $inst + " is not defined in the myPMPro.ps1 file"
        throw $estring
    }
}

#Function to call the PMP RESTAPI
function _pmproRestCall()
{
    param
    (
        [parameter(Mandatory=$true)][alias("instance")][ValidateScript({_testInstance -instance $_})][String]$inst,
        [String]$method,
        [String]$resource,
        [Object]$body = @{}
    )
        
    if ($PMPInstances[$inst].encToken)
    {
        $token = "?AUTHTOKEN=" + ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((ConvertTo-SecureString -string ($PMPInstances[$inst].encToken).ToString()))))
    } else {
        $token = "?AUTHTOKEN=" + (($PMPInstances[$inst].AuthToken).ToString())
    }

    $headers = New-Object System.Collections.Hashtable
    $_c = $headers.add('Accept-Charset','ISO-8859-1,utf-8')
    $_c = $headers.add('Accept-Language','en-US')
    $_c = $headers.add('Accept-Encoding','gzip,deflate')

    [string]$encoding = "application/json"

    [string]$URI = ($PMPInstances[$inst].baseUrl).ToString() + $resource + $token
    $request = [System.Net.HttpWebRequest]::CreateHttp($URI)
    $request.Method = $method
    if ($PMProVerbose) { Write-Host '[' $request.Method (($request.RequestUri.ToString()).Replace($token,'?AUTHTOKEN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX')) ']' -ForegroundColor Cyan}

    $request.Accept = $encoding
    $request.UserAgent = "pmproSpecific PowerShell script(V2)"
    $request.ConnectionGroupName = '_pmpro_'
    $request.KeepAlive = $false
    
    foreach($key in $headers.keys)
    {
        $request.Headers.Add($key, $headers[$key])
    }

    if ( ($method -eq "POST") -or ($method -eq "PUT") )
    {
        $postData = ConvertTo-Json $body

        if ($PMProVerbose) { Write-Host $postData -ForegroundColor Cyan }

        $bytes = [System.Text.Encoding]::UTF8.GetBytes($postData)
        $request.ContentType = "text/json"
        $request.ContentLength = $bytes.Length
                 
        [System.IO.Stream]$outputStream = [System.IO.Stream]$request.GetRequestStream()
        $outputStream.Write($bytes,0,$bytes.Length)
        $outputStream.Close()
    }

    try
    {
        [System.Net.HttpWebResponse]$response = $request.GetResponse()
        
        $sr = New-Object System.IO.StreamReader($response.GetResponseStream())
        $txt = $sr.ReadToEnd()
        $sr.Close()
        
        try
        {
            $psobj = ConvertFrom-Json -InputObject $txt
        }
        catch
        {
            throw "Json Exception : " + $txt
        }
    }
    catch [Net.WebException]
    { 
        [System.Net.HttpWebResponse]$response = $_.Exception.Response
        $sr = New-Object System.IO.StreamReader($response.GetResponseStream())
        $txt = $sr.ReadToEnd()
        $sr.Close()
        _restThrowError -text $txt
    }
    catch
    {
        throw $_
    }
    finally
    {
        try
        {
            $response.Close()
            $response.Dispose()
            $_catch = $request.ServicePoint.CloseConnectionGroup('_pmpro_')
            Remove-Variable -Name request
            Remove-Variable -Name response
            Remove-Variable -Name sr
            if ($outputStream) { Remove-Variable -Name outputStream }
        }
        catch{}
    }

    if ($psobj.operation.result.status -eq 'Success')
    {
        return $psobj
    } else {
        Throw ($psobj.operation.result.status + ": " + $psobj.operation.result.message)
    }    
}

#Function to build the body text for adding or updating resources in PMP
function _pmproBuildResourceBody()
{
    param
    (
        [parameter(Mandatory=$true)][alias("resourceName")][String]$rName,
        [parameter(Mandatory=$true)][alias("resourceDesc")][String]$rDesc,
        [parameter(Mandatory=$true)][alias("resourceURL")][String]$rURL,
        [parameter(Mandatory=$true)][alias("department")][String]$department

    )
                    RESOURCENAME = "test1"
                    RESOURCEDESCRIPTION = "THIS IS A DES of a resource"
                    RESOURCETYPE = "Windows"
                    RESOURCEURL = "https://www.wackwack"
                    DEPARTMENT = ""
                    DNSNAME = "test1.d.v.tld"
                    LOCATION = ""
                    ACCOUNTNAME = "matt2"                   
                    PASSWORD = "Password1@12345#78"
                    NOTES = "notes about the account"
                    OWNERNAME = "megan@varian.com"
                    RESOURCECUSTOMFIELD = (New-Object System.Collections.ArrayList)
                    ACCOUNTCUSTOMFIELD = (New-Object System.Collections.ArrayList)

}

function pmproGetResources()
{
    <# 
     .Synopsis
      Used to Retrieve ALL resources assigned to a user in PMP

     .Description
      Returns an Object representing the collection of Resources

     .Parameter inst
      the identifier of the Instance defined in your myPMPro.ps1 file

    .Example
      # Get all the resources that are available to the user defined by the token in the prod instance
      pmproGetResources -inst prod
    #>

    param
    (
        [parameter(Mandatory=$true)][alias("instance")][String]$inst
    )
    
    [string]$method = "GET"
    [string]$resource = "/restapi/json/v1/resources"
    try
    {
        $request = _pmproRestCall -inst $inst -method $method -resource $resource
    }
    catch
    {
        if ($PMProVerbose -eq $true)
        {
            Write-Host -ForegroundColor red -BackgroundColor white $_.TargetObject
        }
        throw $_
    }

    $reshash = New-Object System.Collections.Hashtable
    
    foreach ($res in $request.operation.Details)
    {
    
        $_c = $reshash.Add($res.'RESOURCE NAME',$res)
    }
    return $reshash
}

function pmproGetAccountsbyResource()
{
    <# 
         .Synopsis
          Used to Retrieve ALL Accounts availble to the requestor for a given resource in PMP

         .Description
          Returns an Object representing the collection of Accounts

         .Parameter inst
          the identifier of the Instance defined in your myPMPro.ps1 file

          .Parameter ResourceID
          the identifier of the Resource for which you want to return Accounts for

         .Example
          # Get all the Accounts that are available to the user defined by the token in the prod instance for the Resource Identified as 123
          pmproGetResources -inst prod -ResourceID 123
    #>
    param
    (
        [parameter(Mandatory=$true)][alias("instance")][String]$inst,
        [parameter(Mandatory=$true)][alias("ResourceID")][String]$rid
    )
    
    [string]$method = "GET"
    [string]$resource = "/restapi/json/v1/resources/" + $rid + "/accounts"

    try
    {
        $request = _pmproRestCall -inst $inst -method $method -resource $resource
    }
    catch
    {
        if ($PMProVerbose -eq $true)
        {
            Write-Host -ForegroundColor red -BackgroundColor white $_.TargetObject
        }
        throw $_
    }
    $acthash = New-Object System.Collections.Hashtable
    
    foreach ($act in $request.operation.Details.'ACCOUNT LIST')
    {
        
        $_c = $acthash.Add($act.'ACCOUNT NAME',$act)
    }
    return $acthash
    
}

function pmproGetPasswordforResouceAccount()
{
    <# 
         .Synopsis
          Used to retrieve a credential available to the requestor for a given resource in PMP

         .Description
          Returns an Object representing the collection of Accounts

         .Parameter inst
          the identifier of the Instance defined in your myPMPro.ps1 file

          .Parameter ResourceID
          the identifier of the Resource for which you want to return Accounts for

         .Example
          # Get all the Accounts that are available to the user defined by the token in the prod instance for the Resource Identified as 123
          pmproGetResources -inst prod -ResourceID 123
    #>
    param
    (
        [parameter(Mandatory=$true)][alias("instance")][String]$inst,
        [parameter(Mandatory=$true)][alias("ResourceID")][String]$rid,
        [parameter(Mandatory=$true)][alias("AccountID")][String]$aid
    )
    
    [string]$method = "GET"
    [string]$resource = "/restapi/json/v1/resources/" + $rid + "/accounts/" + $aid + "/password"
    try
    {
        $request = _pmproRestCall -inst $inst -method $method -resource $resource
    }
    catch
    {
        if ($PMProVerbose -eq $true)
        {
            Write-Host -ForegroundColor red -BackgroundColor white $_.TargetObject
        }
        throw $_
    }
    return $request.operation.Details.PASSWORD
}

function pmproGetResourcesPasswordOnName(){
    <# 
     .Synopsis
      Combines the functions to retrieve the password for a resource account 

     .Description
      Returns a plain text string with the password

     .Parameter inst
      the identifier of the Instance defined in your myPMPro.ps1 file

     .Parameter resName
      the name of the resource in PMP, for instance SERVER01

     .Parameter accName
      the name of the account in PMP, for instance DOMAINNAME\svc-account

    .Example
      # Retrieves the (plain text) password for Resource SERVER01 and accountname DOMAINNAME\svc-account
      pmproGetResourcesPasswordOnName -inst prod -resName "SERVER01" -accName "DOMAINNAME\svc-account"
    #>

    param
    (
        [parameter(Mandatory=$true)][alias("instance")][String]$inst,
        [parameter(Mandatory=$true)][alias("resourceName")][String]$resName,
		[parameter(Mandatory=$true)][alias("AccountName")][String]$accName
    )
    
    try
    {
        $resourceID = (pmproGetResources -inst $inst) | ForEach-Object{ $_[$resName] } | Select-Object "RESOURCE ID"
        
    }
    catch
    {
        if ($PMProVerbose -eq $true)
        {
            Write-Host -ForegroundColor red -BackgroundColor white $_.TargetObject
        }
        throw $_
    }
    try
    {
        
		$AccountID = (pmproGetAccountsbyResource -inst $inst -rid $resourceID."RESOURCE ID") | ForEach-Object{ $_[$accName] } | Select-Object "ACCOUNT ID"
        
    }
    catch
    {
        if ($PMProVerbose -eq $true)
        {
            Write-Host -ForegroundColor red -BackgroundColor white $_.TargetObject
        }
        throw $_
    }
    try
    {
     	
		$accountPWD = (pmproGetPasswordforResouceAccount -inst $inst -rid $resourceID."RESOURCE ID" -aid $AccountID."ACCOUNT ID")
        
    }
    catch
    {
        if ($PMProVerbose -eq $true)
        {
            Write-Host -ForegroundColor red -BackgroundColor white $_.TargetObject
        }
        throw $_
    }

	return $AccountPWD
}

Export-ModuleMember -Function pmpro*
