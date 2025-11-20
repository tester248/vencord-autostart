@echo off
REM SetupStartup.bat - Setup Vencord Auto-Start for Windows startup
REM Uses execution policy bypass to work on all systems

echo Vencord Auto-Start Setup
echo ========================
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

echo Adding to Windows startup...
echo.

REM Run PowerShell script with bypass execution policy
pwsh -ExecutionPolicy Bypass -File "%PS_SCRIPT%" 2>nul
if %ERRORLEVEL% NEQ 0 (
    REM Fallback to Windows PowerShell if pwsh is not available
    powershell.exe -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
)

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