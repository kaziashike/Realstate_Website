# find_remaining_assets.ps1
$pagesDir = 'D:\Website Work\Realstate_Website\pages'
$htmlFiles = Get-ChildItem -Path $pagesDir -Filter *.html -Recurse

$assets = [System.Collections.Generic.HashSet[string]]::new()
$pattern = '(src|href|srcset)="(?<url>https://[^"]+)"'

foreach ($file in $htmlFiles) {
    [string]$content = [System.IO.File]::ReadAllText($file.FullName)
    $matches = [regex]::Matches($content, $pattern)
    foreach ($match in $matches) {
        $url = $match.Groups['url'].Value
        # Exclude trackers/social
        if ($url -notmatch '(google|facebook|triptease|hijiffy|naver|cookieyes|linkedin)') {
             $assets.Add($url) > $null
        }
    }
}

$assets | Out-File 'remaining_external.txt'
Write-Host "Found $($assets.Count) remaining external asset URLs."
