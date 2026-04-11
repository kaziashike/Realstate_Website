# replace_localized_paths.ps1
$mappingFile = 'D:\Website Work\Realstate_Website\asset_mapping.json'
$mapping = Get-Content $mappingFile | ConvertFrom-Json
$pagesDir = 'D:\Website Work\Realstate_Website\pages'
$htmlFiles = Get-ChildItem -Path $pagesDir -Filter *.html -Recurse

Write-Host "Starting path replacement in $($htmlFiles.Count) files..."

$processedCount = 0

foreach ($file in $htmlFiles) {
    [string]$content = [System.IO.File]::ReadAllText($file.FullName)
    $originalContent = $content

    # Determine depth for correct relative paths
    # pages/index.html -> 1 level deep (needs ../)
    # pages/bali/index.html -> 2 levels deep (needs ../../)
    $relativePath = $file.FullName.Replace($pagesDir, "").TrimStart("\")
    $depth = 0
    if ($relativePath -match '\\') {
        $depth = ($relativePath.ToCharArray() | Where-Object { $_ -eq '\' }).Count
    }
    $prefix = "../" * ($depth + 1)

    foreach ($prop in $mapping.psobject.properties) {
        $externalUrl = $prop.Name
        $localRelPath = $prop.Value # e.g. assets/img/name.webp
        
        $newLocalUrl = $prefix + $localRelPath
        
        # Replace occurrences in src, href, and srcset
        # Use [regex]::Escape to handle special chars in URLs (like ?, +, (, ))
        $pattern = [regex]::Escape($externalUrl)
        $content = $content -replace $pattern, $newLocalUrl
    }

    if ($content -ne $originalContent) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        $processedCount++
    }
}

Write-Host "Replacement Complete. Files updated: $processedCount"
