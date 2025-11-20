@echo off
REM RemoveFromStartup-Bypass.bat - Remove Vencord Auto-Start from startup
REM This bypasses PowerShell execution policy restrictions

echo Vencord Auto-Start Removal
echo ==========================
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

echo Removing Vencord Auto-Start from Windows startup...
echo.

REM Run PowerShell script with bypass execution policy and -Remove parameter
pwsh -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -Remove 2>nul
if %ERRORLEVEL% NEQ 0 (
    REM Fallback to Windows PowerShell if pwsh is not available
    powershell.exe -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -Remove
)

REM Check if the command was successful
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Removal completed successfully!
) else (
    echo.
    echo Removal encountered an error. Please check the output above.
)

echo.
echo Press any key to exit...
pause >nul