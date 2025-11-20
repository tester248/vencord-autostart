# VencordAutoStart.ps1 - Automate Vencord patching before Discord startup
# Version: 2.0
# Last Updated: November 2025
# This script repairs/patches Vencord before Discord launches
# Use with Discord's built-in startup settings for best experience

param(
    [switch]$Quiet,         # Minimize output
    [string[]]$Branches = @(),  # Specific branches to patch (e.g., "stable", "canary")
    [switch]$ListOnly       # Only list Discord installations, don't patch
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

function Find-DiscordInstallations {
    # Find all Discord installations - return simple array
    $Results = @()
    
    # Check for different Discord branches in LocalAppData
    $DiscordBranches = @(
        @{ Name = "Stable"; Path = "$env:LOCALAPPDATA\Discord"; Branch = "stable" },
        @{ Name = "PTB"; Path = "$env:LOCALAPPDATA\DiscordPTB"; Branch = "ptb" },
        @{ Name = "Canary"; Path = "$env:LOCALAPPDATA\DiscordCanary"; Branch = "canary" }
    )
    
    foreach ($Branch in $DiscordBranches) {
        if (Test-Path $Branch.Path) {
            # Look for executable
            $UpdateExe = Join-Path $Branch.Path "Update.exe"
            $DiscordExe = Join-Path $Branch.Path "Discord.exe"
            
            if (Test-Path $UpdateExe) {
                $Results += [PSCustomObject]@{
                    Name = $Branch.Name
                    Path = $Branch.Path
                    Executable = $UpdateExe
                    Branch = $Branch.Branch
                    LaunchArgs = @("--processStart", "Discord.exe")
                }
                Write-Log "Found Discord $($Branch.Name) at: $UpdateExe"
            }
            elseif (Test-Path $DiscordExe) {
                $Results += [PSCustomObject]@{
                    Name = $Branch.Name
                    Path = $Branch.Path
                    Executable = $DiscordExe
                    Branch = $Branch.Branch
                    LaunchArgs = @()
                }
                Write-Log "Found Discord $($Branch.Name) at: $DiscordExe"
            }
        }
    }
    
    return $Results
}

try {
    Write-Log "Starting Vencord Auto-Start script"
    
    # Check if VencordInstallerCli.exe exists
    if (-not (Test-Path $VencordInstaller)) {
        throw "VencordInstallerCli.exe not found at: $VencordInstaller"
    }
    
    # Find Discord installations
    Write-Log "Scanning for Discord installations..."
    
    $DiscordInstallations = @()
    
    # Check for Discord Stable
    $StablePath = "$env:LOCALAPPDATA\Discord"
    if (Test-Path $StablePath) {
        $DiscordInstallations += [PSCustomObject]@{
            Name = "Stable"
            Path = $StablePath
            Branch = "stable"
        }
        Write-Log "Found Discord Stable at: $StablePath"
    }
    
    # Check for Discord PTB
    $PTBPath = "$env:LOCALAPPDATA\DiscordPTB"
    if (Test-Path $PTBPath) {
        $DiscordInstallations += [PSCustomObject]@{
            Name = "PTB"
            Path = $PTBPath
            Branch = "ptb"
        }
        Write-Log "Found Discord PTB at: $PTBPath"
    }
    
    # Check for Discord Canary
    $CanaryPath = "$env:LOCALAPPDATA\DiscordCanary"
    if (Test-Path $CanaryPath) {
        $DiscordInstallations += [PSCustomObject]@{
            Name = "Canary"
            Path = $CanaryPath
            Branch = "canary"
        }
        Write-Log "Found Discord Canary at: $CanaryPath"
    }
    
    $InstallationCount = $DiscordInstallations.Count
    if ($InstallationCount -eq 0) {
        Write-Log "No Discord installations found. Please install Discord first."
        if (-not $Quiet) {
            Write-Host "No Discord installations found. Please install Discord first." -ForegroundColor Yellow
        }
        exit 1
    }
    
    Write-Log "Found $InstallationCount Discord installation(s)"
    
    # List installations and exit if ListOnly is specified
    if ($ListOnly) {
        Write-Log "Discord installations found:"
        foreach ($Discord in $DiscordInstallations) {
            Write-Log "- $($Discord.Name) ($($Discord.Branch)) at $($Discord.Path)"
            if (-not $Quiet) {
                Write-Host "- $($Discord.Name) ($($Discord.Branch)) at $($Discord.Path)" -ForegroundColor Cyan
            }
        }
        return
    }
    
    # Filter installations by specified branches if provided
    if ($Branches.Count -gt 0) {
        $DiscordInstallations = $DiscordInstallations | Where-Object { $_.Branch -in $Branches }
        Write-Log "Filtering to specified branches: $($Branches -join ', '). Found $($DiscordInstallations.Count) matching installations."
    }
    
    # Patch each Discord installation
    $PatchedCount = 0
    foreach ($Discord in $DiscordInstallations) {
        Write-Log "Patching Discord $($Discord.Name) (Branch: $($Discord.Branch))..."
        
        try {
            $ProcessResult = & $VencordInstaller "-repair" "-branch" $Discord.Branch 2>&1
            $ExitCode = $LASTEXITCODE
            
            Write-Log "Vencord installer output for $($Discord.Name): $($ProcessResult -join "`n")"
            
            if ($ExitCode -eq 0) {
                Write-Log "Successfully patched Discord $($Discord.Name)"
                $PatchedCount++
            } else {
                Write-Log "Failed to patch Discord $($Discord.Name) - Exit code: $ExitCode"
            }
        } catch {
            Write-Log "Error patching Discord $($Discord.Name): $($_.Exception.Message)"
        }
    }
    
    Write-Log "Patched $PatchedCount out of $InstallationCount Discord installations"
    
    Write-Log "Vencord patching completed. Discord will use its configured startup settings."
    
    Write-Log "Vencord Auto-Start completed successfully"
    
} catch {
    $ErrorMessage = "Error in Vencord Auto-Start: $($_.Exception.Message)"
    Write-Log $ErrorMessage
    
    if (-not $Quiet) {
        Write-Host $ErrorMessage -ForegroundColor Red
    }
    
    exit 1
}