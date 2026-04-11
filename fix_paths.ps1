# fix_paths.ps1
# This script corrects the broken jQuery paths and ensures visibility of content.

$pagesDir = 'D:\Website Work\Realstate_Website\pages'
$htmlFiles = Get-ChildItem -Path $pagesDir -Filter *.html -Recurse

Write-Host "Found $($htmlFiles.Count) files. Starting correction..."

$count = 0
foreach ($file in $htmlFiles) {
    [string]$content = [System.IO.File]::ReadAllText($file.FullName)
    $originalContent = $content

    # 1. Fix jQuery path (handle various versions/cache-busters and relative depths)
    # The original path was something like ../d3e54v103j8qbb.cloudfront.net/js/jquery-3.5.1.min.dc5e7f18c80a45.js?site=6624ff6a5db57a668993dd4c
    # We want it to be ../assets/js/jquery.min.js
    $content = $content -replace 'src="(\.\./)+d3e54v103j8qbb\.cloudfront\.net/js/jquery-[^"]+"', 'src="../assets/js/jquery.min.js"'
    $content = $content -replace 'src="(\.\./)+assets/js/jquery-[^"]+"', 'src="../assets/js/jquery.min.js"'

    # 2. Fix Lenis path
    $content = $content -replace 'src="(\.\./)+assets/js/lenis\.min\.js"', 'src="../assets/js/lenis.min.js"'

    # 3. Fix any remaining domain-named folders
    $content = $content -replace 'src="(\.\./)+cdn\.prod\.website-files\.com/[^"]+/js/', 'src="../assets/js/'
    $content = $content -replace 'href="(\.\./)+cdn\.prod\.website-files\.com/[^"]+/css/', 'href="../assets/css/'

    # 4. Correct for depth (The previous restructure moved everything to /pages/)
    $relativePath = $file.FullName.Replace($pagesDir, "").TrimStart("\")
    $depth = ($relativePath.ToCharArray() | Where-Object { $_ -eq '\' }).Count
    $prefix = "../" * ($depth + 1)
    
    # Standardize all /assets/ references to the correct depth (Grouped expression to avoid parser error)
    $srcPattern = 'src="(\.\./)+assets/'
    $srcReplacement = "src=`"$($prefix)assets/"
    $content = $content -replace $srcPattern, $srcReplacement
    
    $hrefPattern = 'href="(\.\./)+assets/'
    $hrefReplacement = "href=`"$($prefix)assets/"
    $content = $content -replace $hrefPattern, $hrefReplacement

    # 5. Fix the loader visibility force-show
    # Webflow sites often use .load { display: block !important } to show a splash screen.
    $content = $content -replace '\.load\s*\{\s*display:\s*block\s*!important;\s*\}', '.load { display: none; }'
    $content = $content -replace '\[text-split\]\s*\{\s*opacity:\s*0;\s*\}', '[text-split] { opacity: 1; }'

    if ($content -ne $originalContent) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        $count++
    }
}

Write-Host "Successfully corrected $count files."
