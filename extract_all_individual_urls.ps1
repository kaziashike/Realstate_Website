# extract_all_individual_urls.ps1
$pagesDir = 'D:\Website Work\Realstate_Website\pages'
$htmlFiles = Get-ChildItem -Path $pagesDir -Filter *.html -Recurse

$urls = [System.Collections.Generic.HashSet[string]]::new()

# Pattern to find any https:// URL inside quotes (handling commas for srcset)
# We match everything inside quotes and then split by whitespace/commas in a second pass
$attributePattern = '(src|href|srcset|data-[^=]+)="([^"]+)"'

Write-Host "Extracting all individual URLs from $($htmlFiles.Count) files..."

foreach ($file in $htmlFiles) {
    [string]$content = [System.IO.File]::ReadAllText($file.FullName)
    $matches = [regex]::Matches($content, $attributePattern)
    foreach ($match in $matches) {
        $attrContent = $match.Groups[2].Value
        # Split by comma or whitespace to pull out individual URLs
        $parts = $attrContent -split '[\s,]+'
        foreach ($part in $parts) {
            if ($part -match '^https://') {
                # Clean up any trailing descriptors like '500w' or '2x'
                $cleanUrl = $part -replace '(\s+\d+[wx])$', ''
                if ($cleanUrl -notmatch '(google|facebook|triptease|hijiffy|naver|cookieyes|linkedin|whatsapp|synxis|instagram|tiktok|maps\.app)') {
                    $urls.Add($cleanUrl) > $null
                }
            }
        }
    }
}

$urls | Out-File 'all_individual_urls.txt'
Write-Host "Found $($urls.Count) unique individual external URLs."
