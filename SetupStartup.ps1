param([switch]$Remove)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BatchFile = Join-Path $ScriptDir "VencordAutoStart.bat"
$StartupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$ShortcutPath = Join-Path $StartupFolder "VencordAutoStart.lnk"

Write-Host "Vencord Auto-Start Setup" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

if ($Remove) {
    Write-Host "Removing from Windows startup..." -ForegroundColor Yellow
    
    if (Test-Path $ShortcutPath) {
        Remove-Item $ShortcutPath -Force
        Write-Host "Successfully removed Vencord Auto-Start from Windows startup" -ForegroundColor Green
    } else {
        Write-Host "Vencord Auto-Start was not found in startup folder" -ForegroundColor Yellow
    }
} else {
    Write-Host "Adding to Windows startup..." -ForegroundColor Yellow
    
    if (-not (Test-Path $BatchFile)) {
        Write-Host "VencordAutoStart.bat not found at: $BatchFile" -ForegroundColor Red
        exit 1
    }
    
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $BatchFile
    $Shortcut.WorkingDirectory = $ScriptDir
    $Shortcut.Description = "Vencord Auto-Start - Patches Vencord and launches Discord"
    $Shortcut.WindowStyle = 7
    $Shortcut.Save()
    
    Write-Host "Successfully added Vencord Auto-Start to Windows startup" -ForegroundColor Green
    Write-Host "Shortcut created at: $ShortcutPath" -ForegroundColor Gray
    Write-Host "The script will now run automatically when Windows starts" -ForegroundColor Gray
    
    Write-Host ""
    Write-Host "What happens next:" -ForegroundColor Cyan
    Write-Host "- Every time Windows starts, Vencord will be automatically patched" -ForegroundColor Gray
    Write-Host "- Discord will launch automatically after patching" -ForegroundColor Gray
    Write-Host "- Check 'vencord-startup.log' in this folder for any issues" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")