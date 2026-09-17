param(
    [string]$ApkPath = "mobile/build/app/outputs/flutter-apk/app-release.apk"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceApk = [System.IO.Path]::GetFullPath((Join-Path $projectRoot $ApkPath))
$mobileRoot = [System.IO.Path]::GetFullPath((Join-Path $projectRoot "mobile"))

if (-not $sourceApk.StartsWith($mobileRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "APK harus berasal dari folder mobile proyek ini."
}
if (-not (Test-Path -LiteralPath $sourceApk -PathType Leaf)) {
    throw "APK tidak ditemukan: $sourceApk"
}

$pubspecPath = Join-Path $projectRoot "mobile/pubspec.yaml"
$versionLine = Select-String -LiteralPath $pubspecPath -Pattern '^version:\s*(.+)$' | Select-Object -First 1
if (-not $versionLine) {
    throw "Nomor versi tidak ditemukan pada mobile/pubspec.yaml."
}
$version = $versionLine.Matches[0].Groups[1].Value.Trim()
$downloadDirectory = Join-Path $projectRoot "backend/public/downloads"
$fileName = "e-Absensi_Mobile.apk"
$destinationApk = Join-Path $downloadDirectory $fileName
$manifestPath = Join-Path $downloadDirectory "mobile-app.json"

New-Item -ItemType Directory -Force -Path $downloadDirectory | Out-Null
Copy-Item -LiteralPath $sourceApk -Destination $destinationApk -Force

$manifest = [ordered]@{
    version = $version
    file = $fileName
    platform = "Android"
    published_at = (Get-Date).ToString("yyyy-MM-dd")
}
$jsonContent = $manifest | ConvertTo-Json
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($manifestPath, $jsonContent, $utf8NoBom)

Write-Host "APK website diperbarui: $destinationApk"
Write-Host "Versi publik: $version"
