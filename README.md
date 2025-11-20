# Vencord Auto-Start Setup

This package automates the Vencord patching process before Discord starts on Windows startup.

## Files Included

- `VencordAutoStart.ps1` - Main PowerShell script that patches Vencord before Discord starts
- `VencordAutoStart.bat` - Batch file wrapper for startup compatibility
- `SetupStartup.ps1` - Configuration script to add/remove from Windows startup
- `SetupStartup.bat` - Easy setup script (works on all Windows systems)
- `RemoveFromStartup.bat` - Easy removal script (works on all Windows systems)
- `VencordInstallerCli.exe` - The Vencord installer (should already be present)

## Quick Setup

### Step 1: Setup Auto-Patching
1. Double-click `SetupStartup.bat`
2. This adds Vencord patching to Windows startup

### Step 2: Configure Discord (Optional)
Configure Discord's startup behavior according to your preference:
- **If you want Discord to start automatically:** Enable "Open Discord on Startup" in Discord Settings → Windows Settings
- **If you prefer manual startup:** Keep Discord's startup disabled and launch it when needed
- **Other settings** like "Start Minimized" and "Close Button Minimizes to Tray" are entirely your choice

### How it works:
- Windows starts → Vencord gets patched → Discord (if configured to auto-start) launches with patches applied

**Important**: The startup script runs before Discord starts, ensuring Vencord is always up-to-date. This prevents Discord from being force-closed during patching.

### Manual Setup (Alternative)
1. Use Task Scheduler directly:
   - Open Task Scheduler (`Win + R` → `taskschd.msc`)
   - Create Basic Task → At log on → Start a program → Browse to `VencordAutoStart.bat`
   - Set delay to 5 seconds in Triggers tab
2. Or copy `VencordAutoStart.bat` to Windows Startup folder (less reliable timing)

## Usage

### Test the Script
To test the automation without waiting for startup:
```cmd
VencordAutoStart.bat
```

### Run with Options
You can run the PowerShell script directly with options:
```cmd
# Run quietly (minimal output)  
powershell -ExecutionPolicy Bypass -File "VencordAutoStart.ps1" -Quiet

# List all Discord installations without patching
powershell -ExecutionPolicy Bypass -File "VencordAutoStart.ps1" -ListOnly

# Patch only specific Discord branches
powershell -ExecutionPolicy Bypass -File "VencordAutoStart.ps1" -Branches stable,canary

# Patch only Canary and run quietly
powershell -ExecutionPolicy Bypass -File "VencordAutoStart.ps1" -Branches canary -Quiet
```

### Manual CLI Usage
You can also run the Vencord installer directly:
```cmd
# Repair Vencord manually
VencordInstallerCli.exe -repair -branch auto

# Install Vencord
VencordInstallerCli.exe -install -branch auto
```

### Remove from Startup
To remove the auto-start from Windows startup:
```cmd
RemoveFromStartup.bat
```

## Troubleshooting

### Check Logs
The script creates a log file `vencord-startup.log` in this folder. Check it if there are issues:
```powershell
Get-Content .\vencord-startup.log -Tail 20
```

### Common Issues

**Discord not launching:**
- The script automatically searches for Discord in common locations
- If Discord isn't found, launch it manually after the script runs
- Check the log file for specific error messages

**Vencord patch fails:**
- Ensure `VencordInstallerCli.exe` is in the same folder as the scripts
- Make sure Discord is not running when the patch occurs
- Check if you have the latest version of VencordInstallerCli.exe

**Script doesn't run on startup:**
- Check if the task exists: Open Task Scheduler (`Win + R` → `taskschd.msc`) and look for "VencordAutoStart"
- Verify task is enabled and set to run at logon
- Check if Windows Defender or antivirus is blocking the script
- Try running as Administrator: right-click `SetupStartup.bat` → "Run as administrator"

**Discord starts before Vencord is patched:**
- The Task Scheduler method prevents this with a 5-second delay
- If it still happens, increase the delay in Task Scheduler → VencordAutoStart → Triggers → Edit → Advanced → Delay task for: 10 seconds
- You can verify timing by checking `vencord-startup.log` timestamps

**PowerShell execution policy errors:**
- All batch files use `-ExecutionPolicy Bypass` to work on any Windows system
- No manual PowerShell policy changes are needed
- If you encounter any issues, try running as Administrator

## How It Works

1. **On Startup**: Windows runs `VencordAutoStart.bat` **before** Discord starts
2. **Discovery**: The script automatically detects all Discord installations (Stable, PTB, Canary)
3. **Patching**: Each Discord installation is patched with the appropriate branch-specific command
4. **Complete**: Script finishes, then Discord launches with your configured startup settings
5. **Logging**: All activities are logged to `vencord-startup.log` for debugging

## Perfect Discord Integration

This script is designed to work **with** Discord's built-in settings, not replace them:

**Enable these in Discord Settings → Windows Settings:**
- "Open Discord on Startup" - Let Discord handle its own startup
- "Start Minimized" - Discord starts minimized (if you prefer)
- "Close Button Minimizes to Tray" - Discord behavior when closed

**Benefits:**
- The script ensures Vencord is patched BEFORE Discord starts
- No conflicts with Discord's startup behavior
- Clean, simple, and reliable

## Multi-Discord Support

The script automatically detects and patches **all** Discord installations on your system:

- **Discord Stable** - Main Discord release
- **Discord PTB** - Public Test Build with beta features  
- **Discord Canary** - Nightly builds with latest features

### Supported Locations:
- `%LOCALAPPDATA%\Discord` (Stable)
- `%LOCALAPPDATA%\DiscordPTB` (PTB)
- `%LOCALAPPDATA%\DiscordCanary` (Canary)
- `%APPDATA%\Discord` (Alternative installation)
- `Program Files` locations

### Selective Patching:
```cmd
# Check what Discord versions you have installed
powershell -ExecutionPolicy Bypass -File "VencordAutoStart.ps1" -ListOnly

# Patch only specific versions
powershell -ExecutionPolicy Bypass -File "VencordAutoStart.ps1" -Branches stable
powershell -ExecutionPolicy Bypass -File "VencordAutoStart.ps1" -Branches canary,ptb
```

## Security Notes

- The batch file runs with `-ExecutionPolicy Bypass` only for this specific script
- The script runs minimized and hidden to avoid interrupting your startup
- All file operations are performed in the script's directory
- No system modifications are made beyond adding a startup shortcut

## Customization

You can modify `VencordAutoStart.ps1` to:
- Add delays before launching Discord
- Launch additional applications
- Send notifications when patching completes
- Customize Discord launch arguments

## Support

If you encounter issues:
1. Check the log file: `vencord-startup.log`
2. Test the script manually: `.\VencordAutoStart.bat`
3. Ensure all files are in the same directory
4. Verify you have the latest Vencord installer

## Git Repository

This project is version-controlled with Git. To contribute or track changes:

```bash
# Clone the repository
git clone <repository-url>

# Make changes and commit
git add .
git commit -m "Your commit message"
git push
```

### Version History
- **v2.0** - Simplified patching-only approach, removed Discord launch functionality
  - Focuses solely on Vencord patching before Discord starts
  - Works with Discord's built-in startup settings
  - Cleaner, more reliable architecture
- **v1.0** - Initial release with automated Vencord patching and Discord launch
  - Fixed CLI syntax to use `-repair -branch auto` for unattended operation
  - Added comprehensive logging and error handling
  - Implemented automatic Discord detection and launch

---

**Last Updated**: November 2025  
**Version**: 2.0  
**Compatibility**: Windows 10/11, PowerShell 5.1+  
**Repository**: Available on GitHub for version control and updates