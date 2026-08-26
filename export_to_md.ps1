param (
    [string]$RootDir = ".",
    [string]$OutputFile = "project_export.md"
)

$ExcludeDirs = @('.git', 'node_modules', 'vendor', 'build', '.dart_tool', 'linux', 'macos', 'windows', 'web', 'ios', 'android', 'storage', 'bootstrap\cache', '.idea', '.vscode')
$ExcludeExts = @('.png', '.jpg', '.jpeg', '.gif', '.ico', '.svg', '.lock', '.exe', '.dll', '.so', '.dylib', '.zip', '.tar', '.gz', '.db', '.sqlite', '.sqlite3', '.apk', '.aab', '.ttf', '.woff', '.woff2')

"Exporting project from $RootDir to $OutputFile..."

"# Project Export`n" | Out-File -FilePath $OutputFile -Encoding utf8

Get-ChildItem -Path $RootDir -Recurse -File | ForEach-Object {
    $file = $_
    $skip = $false

    # Check excluded directories
    foreach ($dir in $ExcludeDirs) {
        if ($file.FullName -match "\\$dir\\") {
            $skip = $true
            break
        }
    }

    if (-not $skip) {
        # Check excluded extensions
        foreach ($ext in $ExcludeExts) {
            if ($file.Extension -eq $ext) {
                $skip = $true
                break
            }
        }
    }

    if (-not $skip) {
        $relPath = $file.FullName.Substring((Resolve-Path $RootDir).Path.Length + 1)
        
        $lang = "text"
        if ($file.Extension) {
            $lang = $file.Extension.Substring(1)
            if ($lang -eq 'js') { $lang = 'javascript' }
            elseif ($lang -eq 'py') { $lang = 'python' }
        }

        try {
            $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
            
            "## File: ``$relPath```n" | Out-File -FilePath $OutputFile -Append -Encoding utf8
            "``````$lang" | Out-File -FilePath $OutputFile -Append -Encoding utf8
            $content | Out-File -FilePath $OutputFile -Append -Encoding utf8
            "```````n" | Out-File -FilePath $OutputFile -Append -Encoding utf8
        } catch {
            "## File: ``$relPath```n" | Out-File -FilePath $OutputFile -Append -Encoding utf8
            "> Could not read file: $($_.Exception.Message)`n`n" | Out-File -FilePath $OutputFile -Append -Encoding utf8
        }
    }
}

"Done! Created $OutputFile"
