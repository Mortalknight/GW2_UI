param (
    [switch]$reconvert,
	[switch]$quiet
)

# requires https://imagemagick.org/script/download.php#windows, which I'm not bundling
# in the tools directory because licensing & size limitations

$assetPath = "$PSScriptRoot/../assets/"
$convCmd = "C:/Program Files/ImageMagick-7.0.10-Q16-HDRI/magick.exe"
$srcFiles = Get-ChildItem -Recurse -File -Exclude *.unused.* -Include *.png -Path $assetPath
if (-not $quiet) {
	Write-Output "Items identified for processing: $($srcFiles.Count)"
}
foreach ($srcItem in $srcFiles) {
    $tgtPath = $srcItem.DirectoryName.Replace('\assets', '\textures')
    $texPath = $srcItem.FullName.Replace('\assets\', '\textures\').Replace('.png', '.tga')    
    $texItem = Get-Item -Path $texPath -ErrorAction SilentlyContinue	
	$srcName = $srcItem.FullName.Replace($PSScriptRoot.Replace('tools', ''), '')
    if (($null -ne $texItem) -and ($srcItem.LastWriteTime -le $texItem.LastWriteTime) -and -not $reconvert) {
		if (-not $quiet) {
			Write-Output "skipping: $srcName"
		}
        continue
    }
    if (-not (Test-Path $tgtPath -PathType Container)) {
        New-Item -Path $tgtPath -ItemType Directory
    }
    $inFmt = (& $convCmd identify -format '%[channels]' $srcItem.FullName) | Out-String
    $inFmt = $inFmt.Trim()

    if ($inFmt -eq 'srgb') {
        $outType = "TrueColor"
    }
    else {
        $outType = "TrueColorAlpha"
    }

	if (-not $quiet) {
		Write-Output "converting [$inFmt]: $srcName"
    }
    & $convCmd convert $srcItem.FullName -strip -orient bottom-left -define colorspace:auto-grayscale=off -compress RLE -flip -type $outType $texPath
}
