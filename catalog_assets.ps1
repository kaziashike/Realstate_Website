# catalog_assets.ps1
$urlsFile = 'D:\Website Work\Realstate_Website\external_urls.txt'
$mappingFile = 'D:\Website Work\Realstate_Website\asset_mapping.json'

$urls = Get-Content $urlsFile
$mapping = @{}

$imgExts = '(\.svg|\.webp|\.jpg|\.jpeg|\.png|\.gif|\.ico)'
$jsExts = '(\.js)'
$cssExts = '(\.css)'
$fontExts = '(\.woff|\.woff2|\.ttf|\.otf|\.eot)'

$count = 0
foreach ($url in $urls) {
    # Skip trackers and social media
    if ($url -match '(google\.com|facebook\.com|triptease\.io|hijiffy\.com|naver\.net|cookieyes\.com|googletagmanager\.com|google-analytics\.com|doubleclick\.net|linkedin\.com)') {
        continue
    }

    $category = $null
    if ($url -match $imgExts) { $category = 'img' }
    elseif ($url -match $jsExts) { $category = 'js' }
    elseif ($url -match $cssExts) { $category = 'css' }
    elseif ($url -match $fontExts) { $category = 'fonts' }

    if ($category) {
        # Sanitize filename
        # Remove URL params
        $cleanUrl = $url -replace '\?.*$', ''
        $filename = Split-Path $cleanUrl -Leaf
        # Use WebUtility which is available in PS7/Core
        $filename = [System.Net.WebUtility]::UrlDecode($filename)
        # Remove illegal chars
        $filename = $filename -replace '[<>:"/\\|?*]', '_'
        # Add a hash if filename is too common or empty
        if (-not $filename -or $filename -eq "") { $filename = "asset_" + $count }
        
        $localPath = "assets/$category/$filename"
        
        # Avoid duplicate keys
        if (-not $mapping.ContainsKey($url)) {
            $mapping[$url] = $localPath
            $count++
        }
    }
}

$mapping | ConvertTo-Json -Depth 10 | Out-File $mappingFile
Write-Host "Cataloged $count assets to asset_mapping.json"
