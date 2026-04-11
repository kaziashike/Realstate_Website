# replace_localized_paths_v2.ps1
$mappingFile = 'D:\Website Work\Realstate_Website\asset_mapping.json'
$mapping = Get-Content $mappingFile | ConvertFrom-Json
$pagesDir = 'D:\Website Work\Realstate_Website\pages'
$htmlFiles = Get-ChildItem -Path $pagesDir -Filter *.html -Recurse

# Create a lookup table for faster access
$lookup = @{}
foreach ($prop in $mapping.psobject.properties) {
    # Store both encoded and decoded versions as keys to be safe
    $lookup[$prop.Name] = $prop.Value
    $decoded = [System.Net.WebUtility]::UrlDecode($prop.Name)
    $lookup[$decoded] = $prop.Value
}

Write-Host "Starting smarter path replacement in $($htmlFiles.Count) files..."

$processedCount = 0

foreach ($file in $htmlFiles) {
    [string]$content = [System.IO.File]::ReadAllText($file.FullName)
    $originalContent = $content

    # Determine depth for correct relative paths
    $relativePath = $file.FullName.Replace($pagesDir, "").TrimStart("\")
    $depth = 0
    if ($relativePath -match '\\') {
        $depth = ($relativePath.ToCharArray() | Where-Object { $_ -eq '\' }).Count
    }
    $prefix = "../" * ($depth + 1)

    # Find all candidates for replacement (any https:// URL)
    # This regex looks for URLs ending at a quote or space (like in srcset)
    $matches = [regex]::Matches($content, 'https://[^\s\"'']+')
    
    # Track unique URLs in this file to avoid redundant replacements
    $urlsInFile = @()
    foreach ($m in $matches) {
         # Strip trailing comma from srcset parts
         $url = $m.Value -replace ',$', ''
         if ($url -notin $urlsInFile) { $urlsInFile += $url }
    }

    foreach ($extUrl in $urlsInFile) {
        if ($lookup.ContainsKey($extUrl)) {
            $localRelPath = $lookup[$extUrl]
            $newLocalUrl = $prefix + $localRelPath
            $pattern = [regex]::Escape($extUrl)
            $content = $content -replace $pattern, $newLocalUrl
        }
    }

    if ($content -ne $originalContent) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        $processedCount++
    }
}

Write-Host "Replacement Complete. Files updated: $processedCount"
