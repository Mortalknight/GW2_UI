param (
    [switch]$reconvert,
    [switch]$quiet
)

# requires https://imagemagick.org/script/download.php#windows, which I'm not bundling
# in the tools directory because licensing & size limitations

#$assetPath = "$PSScriptRoot/../assets/"
$assetPath = "$PSScriptRoot/../textures/"
$convCmd = "C:/opt/ImageMagick-7.1.2-3-portable-Q16-HDRI-x64/magick.exe"
$blpCmd = "$PSScriptRoot/BLPConverter.exe"
$srcFiles = Get-ChildItem -Recurse -File -Exclude *.unused.* -Include *.tga -Path $assetPath
if (-not $quiet) {
    Write-Output "Items identified for processing: $($srcFiles.Count)"
}
foreach ($srcItem in $srcFiles) {
#    $tgtPath = $srcItem.DirectoryName.Replace('\assets', '\textures')
#    $outFmt = "PNG"
#    if ($srcItem.FullName.Contains('rep\') -or $srcItem.FullName.Contains('talents\art') -or $srcItem.FullName.Contains('character\professions_overview') -or $srcItem.FullName.Contains('questview\backgrounds\')) {
#        $outFmt = "JPG"
#    }
#    if ($outFmt -eq "BLP") {
#        $texPath = $srcItem.FullName.Replace('\assets\', '\textures\').Replace('.png', '.blp')
#    }
#    elseif ($outFmt -eq "JPG") {
#        $texPath = $srcItem.FullName.Replace('\assets\', '\textures\').Replace('.png', '.jpg')
#    }
#    elseif ($outFmt -eq "TGA") {
#        $texPath = $srcItem.FullName.Replace('\assets\', '\textures\').Replace('.png', '.tga')
#    }
#    else {
#        $texPath = $srcItem.FullName.Replace('\assets\', '\textures\')
#    }
    #$tgtPath = $srcItem
    $texPath = $srcItem.FullName.ToLower().Replace('.tga', '.png')
    $outFmt = "PNG"
    $texItem = Get-Item -Path $texPath -ErrorAction SilentlyContinue
    $srcName = $srcItem.FullName.Replace($PSScriptRoot.Replace('tools', ''), '')
    if (($null -ne $texItem) -and ($srcItem.LastWriteTime -le $texItem.LastWriteTime) -and -not $reconvert) {
        if (-not $quiet) {
            Write-Output "skipping: $srcName"
        }
        continue
    }
    #if (-not (Test-Path $tgtPath -PathType Container)) {
    #    New-Item -Path $tgtPath -ItemType Directory
    #}
    $inFmt = (& $convCmd identify -format '%[channels]' $srcItem.FullName) | Out-String
    $inFmt = $inFmt.Trim()

    if ($inFmt -eq 'srgb') {
        $outType = "TrueColor"
        $outPng = "png24"
    }
    else {
        $outType = "TrueColorAlpha"
        $outPng = "png32"
    }

    if (-not $quiet) {
        Write-Output "converting [$inFmt]: $srcName"
    }
    if ($outFmt -eq "BLP") {
        & $blpCmd /FBLP_PAL_A0 $srcItem.FullName $texPath
    }
    elseif ($outFmt -eq "JPG") {
        & $convCmd $srcItem.FullName -strip -type "TrueColor" $texPath
    }
    elseif ($outFmt -eq "TGA") {
        & $convCmd $srcItem.FullName -strip -orient bottom-left -define colorspace:auto-grayscale=off -compress RLE -flip -type $outType $texPath
    }
    else {
        & $convCmd $srcItem.FullName -strip -define png:compression-level=9 -define png:format=$outPng $texPath
    }
}
