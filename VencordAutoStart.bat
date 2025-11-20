@echo off
REM VencordAutoStart.bat - Batch wrapper for PowerShell script
REM This runs the PowerShell script with appropriate execution policy

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%VencordAutoStart.ps1"

REM Check if PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo Error: PowerShell script not found at "%PS_SCRIPT%"
    pause
    exit /b 1
)

REM Run PowerShell script with bypass execution policy and quiet mode for startup
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%PS_SCRIPT%" -Quiet

REM Exit without showing console window
exit /b 0