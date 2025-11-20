# VencordAutoStart.ps1 - Automate Vencord patching and Discord launch
# Version: 1.0
# Last Updated: November 2025
# This script repairs Vencord and launches Discord automatically

param(
    [switch]$NoLaunch,  # Skip launching Discord
    [switch]$Quiet      # Minimize output
)

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VencordInstaller = Join-Path $ScriptDir "VencordInstallerCli.exe"

# Log file for debugging
$LogFile = Join-Path $ScriptDir "vencord-startup.log"

function Write-Log {
    param($Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp - $Message"
    
    if (-not $Quiet) {
        Write-Host $LogEntry -ForegroundColor Green
    }
    
    # Append to log file
    Add-Content -Path $LogFile -Value $LogEntry -ErrorAction SilentlyContinue
}

function Find-DiscordExecutable {
    # Common Discord installation paths
    $DiscordPaths = @(
        "$env:LOCALAPPDATA\Discord\Update.exe",
        "$env:APPDATA\Discord\Update.exe",
        "${env:ProgramFiles}\Discord\Discord.exe",
        "${env:ProgramFiles(x86)}\Discord\Discord.exe"
    )
    
    foreach ($Path in $DiscordPaths) {
        if (Test-Path $Path) {
            Write-Log "Found Discord at: $Path"
            return $Path
        }
    }
    
    # If not found in common locations, try to find it via registry or Start Menu
    try {
        $DiscordShortcut = Get-ChildItem "$env:APPDATA\Microsoft\Windows\Start Menu\Programs" -Recurse -Filter "*Discord*.lnk" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($DiscordShortcut) {
            $Shell = New-Object -ComObject WScript.Shell
            $Shortcut = $Shell.CreateShortcut($DiscordShortcut.FullName)
            $TargetPath = $Shortcut.TargetPath
            if (Test-Path $TargetPath) {
                Write-Log "Found Discord via Start Menu shortcut: $TargetPath"
                return $TargetPath
            }
        }
    }
    catch {
        Write-Log "Could not find Discord via Start Menu search"
    }
    
    return $null
}

try {
    Write-Log "Starting Vencord Auto-Start script"
    
    # Check if VencordInstallerCli.exe exists
    if (-not (Test-Path $VencordInstaller)) {
        throw "VencordInstallerCli.exe not found at: $VencordInstaller"
    }
    
    Write-Log "Running Vencord repair..."
    
    # Run Vencord installer with repair option
    try {
        $ProcessResult = & $VencordInstaller "-repair" "-branch" "auto" 2>&1
        $ExitCode = $LASTEXITCODE
        
        Write-Log "Vencord installer output: $($ProcessResult -join "`n")"
        
        if ($ExitCode -eq 0) {
            Write-Log "Vencord repair completed successfully"
        } else {
            Write-Log "Vencord repair failed with exit code: $ExitCode"
        }
    } catch {
        Write-Log "Error running Vencord installer: $($_.Exception.Message)"
        $ExitCode = 1
    }
    
    # Launch Discord if not skipped
    if (-not $NoLaunch) {
        Write-Log "Looking for Discord executable..."
        $DiscordPath = Find-DiscordExecutable
        
        if ($DiscordPath) {
            Write-Log "Launching Discord..."
            
            # Special handling for Discord Update.exe
            if ($DiscordPath -like "*Update.exe") {
                Start-Process -FilePath $DiscordPath -ArgumentList "--processStart", "Discord.exe" -WindowStyle Hidden
            } else {
                Start-Process -FilePath $DiscordPath -WindowStyle Hidden
            }
            
            Write-Log "Discord launched successfully"
        } else {
            Write-Log "Discord executable not found. Please launch Discord manually."
        }
    } else {
        Write-Log "Skipping Discord launch (NoLaunch parameter specified)"
    }
    
    Write-Log "Vencord Auto-Start completed successfully"
    
} catch {
    $ErrorMessage = "Error in Vencord Auto-Start: $($_.Exception.Message)"
    Write-Log $ErrorMessage
    
    if (-not $Quiet) {
        Write-Host $ErrorMessage -ForegroundColor Red
    }
    
    exit 1
}