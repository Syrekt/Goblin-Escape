@echo off
setlocal

set BUILD_DIR=GoblinEscape_Win
set CHANNEL=psychoseel/goblin-escape:win
set BETA_CHANNEL=psychoseel/goblin-escape:windows-beta

:: Safe timestamp (YYYYMMDD-HHMMSS)
for /f "tokens=1-3 delims=/.- " %%a in ("%DATE%") do set D=%%c%%b%%a
for /f "tokens=1-3 delims=:." %%a in ("%TIME%") do set T=%%a%%b%%c
set DEFAULT_VERSION=%D%-%T%

set /p USERVERSION=Enter build version [%DEFAULT_VERSION%]: 

if "%USERVERSION%"=="" (
	set FINAL_VERSION=%DEFAULT_VERSION%
	set FINAL_CHANNEL=%BETA_CHANNEL%
) else (
	set FINAL_VERSION=%USERVERSION%
	set FINAL_CHANNEL=%CHANNEL%
)

if "%FINAL_CHANNEL%"=="%CHANNEL%" (
	echo You are about to push a RELEASE build.
	pause
)

echo.
echo Pushing:
echo   Build:   %BUILD_DIR%
echo   Channel: %FINAL_CHANNEL%
echo   Version: %FINAL_VERSION%
echo.

butler push "%BUILD_DIR%" "%FINAL_CHANNEL%" --userversion "%FINAL_VERSION%"
if errorlevel 1 (
	echo Butler push failed!
	exit /b 1
)

butler status "%FINAL_CHANNEL%"

echo.
echo Push completed successfully!
pause
