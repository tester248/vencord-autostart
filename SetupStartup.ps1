# SetupStartup.ps1 - Configure Vencord Auto-Start for Windows startup via Task Scheduler
# This script adds/removes the Vencord automation using Windows Task Scheduler for reliable execution

param(
    [switch]$Remove  # Remove from startup instead of adding
)

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BatchFile = Join-Path $ScriptDir "VencordAutoStart.bat"
$TaskName = "VencordAutoStart"

function Add-VencordStartupTask {
    try {
        # Check if batch file exists
        if (-not (Test-Path $BatchFile)) {
            throw "VencordAutoStart.bat not found at: $BatchFile"
        }
        
        # Remove existing task if it exists
        $ExistingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($ExistingTask) {
            Write-Host "! Existing task found, updating..." -ForegroundColor Yellow
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
        }
        
        # Create scheduled task components
        $Action = New-ScheduledTaskAction -Execute $BatchFile -WorkingDirectory $ScriptDir
        $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
        $Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
        $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
        
        # Set 5 second delay to ensure it runs before Discord
        $Trigger.Delay = "PT5S"
        
        # Register the scheduled task
        $Task = Register-ScheduledTask -TaskName $TaskName -Description "Patches Vencord before Discord starts to ensure compatibility" -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
        
        if ($Task) {
            Write-Host "✓ Successfully created Vencord Auto-Start scheduled task" -ForegroundColor Green
            Write-Host "  Task Name: $TaskName" -ForegroundColor Gray
            Write-Host "  Execution: 5 seconds after Windows login (before Discord)" -ForegroundColor Gray
            Write-Host "  Method: Windows Task Scheduler (reliable execution order)" -ForegroundColor Gray
            return $true
        } else {
            throw "Failed to create scheduled task"
        }
    }
    catch {
        Write-Host "✗ Failed to create startup task: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Try running as Administrator if you encounter permission issues" -ForegroundColor Yellow
        return $false
    }
}

function Remove-VencordStartupTask {
    try {
        $ExistingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($ExistingTask) {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Write-Host "✓ Successfully removed Vencord Auto-Start from Windows startup" -ForegroundColor Green
        } else {
            Write-Host "! Vencord Auto-Start task was not found in Task Scheduler" -ForegroundColor Yellow
        }
        return $true
    }
    catch {
        Write-Host "✗ Failed to remove startup task: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main execution
Write-Host "Vencord Auto-Start Setup (Task Scheduler)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

if ($Remove) {
    Write-Host "Removing from Windows startup..." -ForegroundColor Yellow
    $Success = Remove-VencordStartupTask
} else {
    Write-Host "Adding to Windows startup..." -ForegroundColor Yellow
    $Success = Add-VencordStartupTask
}

Write-Host ""

if ($Success) {
    Write-Host "Setup completed successfully!" -ForegroundColor Green
    
    if (-not $Remove) {
        Write-Host ""
        Write-Host "What happens next:" -ForegroundColor Cyan
        Write-Host "- Every time you log into Windows, Vencord will be patched 5 seconds after login" -ForegroundColor Gray
        Write-Host "- This ensures Discord (if set to auto-start) launches with up-to-date Vencord" -ForegroundColor Gray
        Write-Host "- No more Discord force-closing during patching!" -ForegroundColor Gray
        Write-Host "- Check 'vencord-startup.log' in this folder for any issues" -ForegroundColor Gray
        Write-Host ""
        Write-Host "To test: .\VencordAutoStart.bat" -ForegroundColor Yellow
        Write-Host "To remove: .\SetupStartup.ps1 -Remove" -ForegroundColor Yellow
    }
} else {
    Write-Host "Setup failed. Please check the error messages above." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")