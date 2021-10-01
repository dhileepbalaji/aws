function Invoke-Elasticsearch {
    [CmdletBinding()]
    Param(
        [Uri]$Uri,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = 'Get',
        $Body = $null,
        $Username = $null,
        $Password = $null
    )

    $headers = @{}
        $temp = "{0}:{1}" -f $Username, $Password
        $userinfo = "Basic {0}" -f [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($temp))
        $headers.Add("Authorization", $userinfo)
        $headers.Add("Content-Type", "application/json")
        #write-host $headers

    $response = try { 
        Invoke-WebRequest -Method $Method -Uri $Uri -Body $Body -Headers $headers
    } catch {
        if ($_.Exception.Response -eq $null) {
            Write-Error $_.Exception
        }

        $webResponse = New-Object Microsoft.PowerShell.Commands.WebResponseObject($_.Exception.Response, $_.Exception.Response.GetResponseStream())
        $content = [System.Text.Encoding]::UTF8.GetString($webResponse.Content)

        $webResponse | Select StatusCode, StatusDescription, Headers, @{Name="Content"; Expr={$content}}
    } 

    Write-Verbose ("{0} {1}" -f $response.StatusCode, $response.StatusDescription)

    $response | Select StatusCode, StatusDescription, Headers, Content | Write-Output
}