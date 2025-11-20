# SetupStartup.ps1 - Configure Vencord Auto-Start for Windows startup
# This script adds the Vencord automation to Windows startup

param(
    [switch]$Remove  # Remove from startup instead of adding
)

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BatchFile = Join-Path $ScriptDir "VencordAutoStart.bat"
$StartupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$ShortcutPath = Join-Path $StartupFolder "VencordAutoStart.lnk"

function Add-ToStartup {
    try {
        # Check if batch file exists
        if (-not (Test-Path $BatchFile)) {
            throw "VencordAutoStart.bat not found at: $BatchFile"
        }
        
        # Create shortcut in startup folder
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $BatchFile
        $Shortcut.WorkingDirectory = $ScriptDir
        $Shortcut.Description = "Vencord Auto-Start - Patches Vencord and launches Discord"
        $Shortcut.WindowStyle = 7  # Minimized window
        $Shortcut.Save()
        
        Write-Host "✓ Successfully added Vencord Auto-Start to Windows startup" -ForegroundColor Green
        Write-Host "  Shortcut created at: $ShortcutPath" -ForegroundColor Gray
        Write-Host "  The script will now run automatically when Windows starts" -ForegroundColor Gray
        
        return $true
    }
    catch {
        Write-Host "✗ Failed to add to startup: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Remove-FromStartup {
    try {
        if (Test-Path $ShortcutPath) {
            Remove-Item $ShortcutPath -Force
            Write-Host "✓ Successfully removed Vencord Auto-Start from Windows startup" -ForegroundColor Green
        } else {
            Write-Host "! Vencord Auto-Start was not found in startup folder" -ForegroundColor Yellow
        }
        
        return $true
    }
    catch {
        Write-Host "✗ Failed to remove from startup: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main execution
Write-Host "Vencord Auto-Start Setup" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

if ($Remove) {
    Write-Host "Removing from Windows startup..." -ForegroundColor Yellow
    $Success = Remove-FromStartup
} else {
    Write-Host "Adding to Windows startup..." -ForegroundColor Yellow
    $Success = Add-ToStartup
}

if ($Success) {
    Write-Host "`nSetup completed successfully!" -ForegroundColor Green
    
    if (-not $Remove) {
        Write-Host "`nWhat happens next:" -ForegroundColor Cyan
        Write-Host "- Every time Windows starts, Vencord will be automatically patched" -ForegroundColor Gray
        Write-Host "- Discord will launch automatically after patching" -ForegroundColor Gray
        Write-Host "- Check 'vencord-startup.log' in this folder for any issues" -ForegroundColor Gray
        Write-Host "`nTo test the script now, run: .\VencordAutoStart.bat" -ForegroundColor Yellow
        Write-Host "To remove from startup later, run: .\SetupStartup.ps1 -Remove" -ForegroundColor Yellow
    }
} else {
    Write-Host "`nSetup failed. Please check the error messages above." -ForegroundColor Red
    exit 1
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")