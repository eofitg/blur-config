@echo off
setlocal enabledelayedexpansion

:: === Set code page to UTF-8 to prevent encoding issues ===
chcp 65001

:: === Check if a file was dragged onto the script ===
if "%~1"=="" (
    echo Please drag a video file onto this script.
    pause
    exit /b
)

:: === Handle the input file path ===
set INPUT_VIDEO=%~1
for %%f in ("%INPUT_VIDEO%") do (
    set FILENAME=%%~nf
    set EXT=%%~xf
    set FOLDER=%%~dpf
)

set FINAL_OUTPUT=!FOLDER!!FILENAME!_Final!EXT!
set BLUR_EXE=blur.exe
set BLURRED_VIDEO=!FOLDER!!FILENAME! - blur ~ 120fps (1440, 2.4)!EXT!

echo === [1/2] Starting blur rendering in a new command window ===
start cmd /k "%BLUR_EXE% %INPUT_VIDEO%"

echo Please wait for the blur rendering to complete, then press any key to continue...
pause

if not exist "!BLURRED_VIDEO!" (
    echo [Error] Blurred output not found: !BLURRED_VIDEO!
    pause
    exit /b
)

echo === [2/2] Merging blurred video with original audio tracks ===
ffmpeg -i "!BLURRED_VIDEO!" -i "%INPUT_VIDEO%" -map 0:v -map 1:a -c:v copy -c:a copy -fflags +genpts reset-timestamps 1 "!FINAL_OUTPUT!"
if errorlevel 1 (
    echo [Error] Failed to merge audio and video.
    pause
    exit /b
)

echo Done! Final output:
echo !FINAL_OUTPUT!
pause
