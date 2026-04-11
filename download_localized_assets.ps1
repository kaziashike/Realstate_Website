# download_localized_assets.ps1
$mappingFile = 'D:\Website Work\Realstate_Website\asset_mapping.json'
$mapping = Get-Content $mappingFile | ConvertFrom-Json
$rootDir = 'D:\Website Work\Realstate_Website'

$ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36'

Write-Host "Starting download of $($mapping.psobject.properties.Count) assets..."

$successCount = 0
$failCount = 0

foreach ($prop in $mapping.psobject.properties) {
    $url = $prop.Name
    $localRelPath = $prop.Value
    $localFullFile = Join-Path $rootDir $localRelPath
    $parentDir = Split-Path $localFullFile -Parent

    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
    }

    if (Test-Path $localFullFile) {
        Write-Host "Skipping (already exists): $localRelPath"
        continue
    }

    try {
        Write-Host "Downloading $url -> $localRelPath"
        Invoke-WebRequest -Uri $url -OutFile $localFullFile -UserAgent $ua -ErrorAction Stop
        $successCount++
    } catch {
        Write-Error "Failed to download $url : $($_.Exception.Message)"
        $failCount++
    }
}

Write-Host "Download Complete. Success: $successCount, Fail: $failCount"
