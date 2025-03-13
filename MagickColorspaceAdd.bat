@echo off
setlocal enabledelayedexpansion

:: Detecting the current folder
for %%A in ("%~dp0.") do set "currentFolder=%%~fA"

:: Input and output folders
set "inputFolder=!currentFolder!\cards-resized-jpg"
set "outputFolder=!currentFolder!\cards-colorspace"

:: Creating an output folder for converted images
mkdir "!outputFolder!" 2>nul

:: Processing resized images in the "resized" folder
for %%F in ("%inputFolder%\*.png" "%inputFolder%\*.jpg" "%inputFolder%\*.jpeg") do (
    set "sourceFile=%%F"
    set "outputFile=!outputFolder!\%%~nF.jpg"
    @REM set "outputFile=!outputFolder!\%%~nxF"
    
    magick "!sourceFile!" -format jpg -profile "sRGB_v4_ICC_preference.icc" -intent perceptual "!outputFile!"
    
    echo Processed: "!sourceFile!" to "!outputFile!"
)

echo Batch processing complete.
