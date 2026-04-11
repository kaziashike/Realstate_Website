# catalog_assets_phase2.ps1
$urlsFile = 'D:\Website Work\Realstate_Website\all_individual_urls.txt'
$mappingFile = 'D:\Website Work\Realstate_Website\asset_mapping.json'

$urls = Get-Content $urlsFile
$mapping = @{}

# Load existing mapping if it exists to avoid losing data (though we'd just recreate it anyway)
if (Test-Path $mappingFile) {
    # Convert from JSON back to a Hashtable
    $existing = Get-Content $mappingFile | ConvertFrom-Json
    foreach ($prop in $existing.psobject.properties) {
        $mapping[$prop.Name] = $prop.Value
    }
}

$imgExts = '(\.svg|\.webp|\.jpg|\.jpeg|\.png|\.gif|\.ico)'
$jsExts = '(\.js)'
$cssExts = '(\.css)'
$fontExts = '(\.woff|\.woff2|\.ttf|\.otf|\.eot)'

$count = 0
foreach ($url in $urls) {
    if ($mapping.ContainsKey($url)) { continue }

    $category = $null
    if ($url -match $imgExts) { $category = 'img' }
    elseif ($url -match $jsExts) { $category = 'js' }
    elseif ($url -match $cssExts) { $category = 'css' }
    elseif ($url -match $fontExts) { $category = 'fonts' }

    if ($category) {
        # Sanitize filename
        $cleanUrl = $url -replace '\?.*$', ''
        $filename = Split-Path $cleanUrl -Leaf
        $filename = [System.Net.WebUtility]::UrlDecode($filename)
        # Remove illegal chars
        $filename = $filename -replace '[<>:"/\\|?*]', '_'
        if (-not $filename) { $filename = "asset_" + $count }
        
        $localPath = "assets/$category/$filename"
        $mapping[$url] = $localPath
        $count++
    }
}

$mapping | ConvertTo-Json -Depth 10 | Out-File $mappingFile
Write-Host "Updated catalog with $count additional assets. Total: $($mapping.Count)"
