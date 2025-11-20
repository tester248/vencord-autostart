@echo off
REM SetupStartup-Bypass.bat - Bypass execution policy for setup
REM This bypasses PowerShell execution policy restrictions

echo Vencord Auto-Start Setup (Execution Policy Bypass)
echo ===================================================
echo.

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%SetupStartup.ps1"

REM Check if PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo Error: SetupStartup.ps1 not found at "%PS_SCRIPT%"
    echo Please ensure all files are in the same directory.
    pause
    exit /b 1
)

echo Running setup with execution policy bypass...
echo.

REM Run PowerShell script with bypass execution policy
powershell.exe -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

REM Check if the command was successful
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Setup completed successfully!
) else (
    echo.
    echo Setup encountered an error. Please check the output above.
)

echo.
echo Press any key to exit...
pause >nul