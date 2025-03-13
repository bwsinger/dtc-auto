$currDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

$cards = "cards"
$cardsResize = "cards-resized-jpg"
$cardsRename = "cards-original"

$inputPath = "$currDir\$cards"
$outputPathResize = "$currDir\$cardsResize"
$pathCardsRename = "$currDir\$cardsRename"

$autofillexe = "$currDir\autofill-windows.exe"
$colorProfile = "$currDir\sRGB_v4_ICC_preference.icc"
$convertPDFexe = "$currDir\Convert to PDF_X-1a (SWOP).exe"

# Required file checks
if(!(Test-Path $autofillexe -PathType Leaf)) {
    Write-Host "File \"autofill-windows.exe\" is required"
}
if(!(Test-Path $currDir\*.xml -PathType Leaf)) {
    Write-Host "File \"*.xml\" (mpcfill.com order export) is required"
}
if(!(Test-Path $colorProfile -PathType Leaf)) {
    Write-Host "File \"sRGB_v4_ICC_preference.icc\" is required"
}
if(!(Test-Path $convertPDFexe -PathType Leaf)) {
    Write-Host "File \"Convert to PDF_X-1a (SWOP).exe\" is required"
}

if ((test-path -PathType container $pathCardsRename) -and ((Test-Path $pathCardsRename\*))) {
    $downloadAnswer = Read-Host "Reset $cardsRename/ and continue downloading images? [y/N]"

    if ($downloadAnswer -in @('y', 'Y', 'yes', 'Yes', 'YES')) {
        Remove-Item -LiteralPath $inputPath -Force -Recurse
        Rename-Item -Path $pathCardsRename -NewName $inputPath
    }
} else {
    $downloadAnswer = Read-Host 'Download card images? [y/N]'
}

if ($downloadAnswer -in @('y', 'Y', 'yes', 'Yes', 'YES')) {
    Write-Host "Downloading card images. Ctrl + c when \"Images Downloaded\" is 100% and restart this script."
    Write-Host "Repeat this process for each XML order file you have."
    $autofillexe -b chrome --site MakePlayingCards --no-auto-save --no-image-post-processing
} 

if ((Test-Path -PathType container $inputPath) -and (!(Test-Path $inputPath\*)) -and (Test-Path -PathType container $pathCardsRename) -and (Test-Path $pathCardsRename\*)) {
    Write-Host "WARNING: $cards/ and $cardsRename/ is empty. Something went wrong during proxy image download via $autofillexe"
    Write-Host "Exiting..."
    Exit
}

if(!(test-path -PathType container $outputPathResize))
{
    New-Item -ItemType Directory -Path $outputPathResize
} 

$convertInput = ""

if ((Test-Path -PathType container $pathCardsRename) -and (Test-Path $pathCardsRename\*)) {
    $convertInput = $pathCardsRename
} else {
    $convertInput = $inputPath
}

Write-Host "Downscaling the images to 300 DPI, converting to jpg, and adding color space..."
magick mogrify -format jpg -profile $colorProfile -intent perceptual -sampling-factor 4:2:0 -strip -quality 95 -resize 819x1114 -path $outputPathResize $convertInput\*

if (!(Test-Path $outputPathResize\*)) {
    Write-Host "WARNING: $pathResize/ is empty. Something went wrong during proxy image file conversion."
    Write-Host "Exiting..."
    Exit
}

# check if $cardsRename exists and is populated before renaming directories
if ((test-path -PathType container $pathCardsRename) && ((Test-Path $pathCardsRename\*))) {
    Copy-item -Force -Recurse -Verbose $pathCardsRename -Destination $inputPath
}

# Rename the "cards" directory
# Create a new "cards" directory and copy the colorized jpgs to there
if(!(test-path -PathType container $pathCardsRename))
{
    Rename-Item -Path $inputPath -NewName $cardsRename
} 

New-Item -ItemType Directory -Path $inputPath

# Copy-item -Force -Recurse -Verbose $sourceDirectory -Destination $destinationDirectory

# Copy all the XML file with "-fixed" appended 
# Replace all instances of ".jpeg" and ".png" with ".jpg" in the "fixed" XMLs

# Run .\autofill-windows.exe --exportpdf
# Write-Host "Now creating the PDFs. Answer the questions like so: \"no\" and \"612\""

# Convert the card pdf to print ready format
# Loop through each pdf file in ./export
# Use .FullName on each pdf input because the droplet needs a full path
# Start-Process $convertPDFexe -ArgumentList "C:\Path\To\PDF\optimizeme.pdf" -Wait -NoNewWindow -PassThru