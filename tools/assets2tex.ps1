param (
    [boolean]$reconvert = $false
)

$assetPath = "$PSScriptRoot/../assets/"
$convCmd = "C:/Program Files/ImageMagick-7.0.10-Q16-HDRI/magick.exe"
$srcFiles = Get-ChildItem -Recurse -File -Exclude *.unused.* -Path $assetPath
foreach ($srcItem in $srcFiles) {
    $tgtPath = $srcItem.DirectoryName.Replace('\assets', '\textures')
    $texPath = $srcItem.FullName.Replace('\assets\', '\textures\').Replace('.png', '.tga')    
    $texItem = Get-Item -Path $texPath -ErrorAction SilentlyContinue
    if (($null -ne $texItem) -and ($srcItem.LastWriteTime -le $texItem.LastWriteTime) -and -not $reconvert) {
        continue
    }
    if (-not (Test-Path $tgtPath -PathType Container)) {
        New-Item -Path $tgtPath -ItemType Directory
    }
    $inFmt = (& $convCmd identify -format '%[channels]' $srcItem.FullName) | Out-String

    $outType = 'TrueColorAlpha'
    if ($inFmt.trim() -eq 'srgb') {
        $outType = 'TrueColor'
    }

    & $convCmd convert -flip -compress RLE $srcItem.FullName -define colorspace:auto-grayscale=off -type $outType $texPath
}
