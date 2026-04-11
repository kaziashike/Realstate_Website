# find_external_assets.ps1
$pagesDir = 'D:\Website Work\Realstate_Website\pages'
$htmlFiles = Get-ChildItem -Path $pagesDir -Filter *.html -Recurse

$urls = [System.Collections.Generic.HashSet[string]]::new()
$pattern = '(src|href)="(?<url>https://[^"]+)"'

Write-Host "Scanning $($htmlFiles.Count) files for external assets..."

foreach ($file in $htmlFiles) {
    [string]$content = [System.IO.File]::ReadAllText($file.FullName)
    $matches = [regex]::Matches($content, $pattern)
    foreach ($match in $matches) {
        $url = $match.Groups['url'].Value
        # Skip common non-asset URLs
        if ($url -notmatch '\.(com|net|org|io)/($|\?|#)') {
            $urls.Add($url) > $null
        }
    }
}

$urls | Out-File 'external_urls.txt'
Write-Host "Found $($urls.Count) unique external URLs. Saved to external_urls.txt"
