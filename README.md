# Vencord Auto-Start Setup

This package automates the Vencord patching process and launches Discord on Windows startup.

## 📁 Files Included

- `VencordAutoStart.ps1` - Main PowerShell script that patches Vencord and launches Discord
- `VencordAutoStart.bat` - Batch file wrapper for startup compatibility
- `SetupStartup.ps1` - Configuration script to add/remove from Windows startup
- `SetupStartup.bat` - Easy setup script (works on all Windows systems)
- `RemoveFromStartup.bat` - Easy removal script (works on all Windows systems)
- `VencordInstallerCli.exe` - The Vencord installer (should already be present)

## 🚀 Quick Setup

### Automatic Setup (Recommended)
1. Double-click `SetupStartup.bat`
2. That's it! The script will now run on every Windows startup

### Manual Setup (Alternative)
1. Copy `VencordAutoStart.bat` to your Windows Startup folder:
   - Press `Win + R`, type `shell:startup`, press Enter
   - Copy the `.bat` file to this folder
2. The script will run on next startup

## 🔧 Usage

### Test the Script
To test the automation without waiting for startup:
```cmd
VencordAutoStart.bat
```

### Run with Options
You can run the PowerShell script directly with options:
```cmd
# Patch Vencord but don't launch Discord
powershell -ExecutionPolicy Bypass -File "VencordAutoStart.ps1" -NoLaunch

# Run quietly (minimal output)  
powershell -ExecutionPolicy Bypass -File "VencordAutoStart.ps1" -Quiet

# Combine options
powershell -ExecutionPolicy Bypass -File "VencordAutoStart.ps1" -NoLaunch -Quiet
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

## 🔍 Troubleshooting

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
- Verify the shortcut exists in the Startup folder (`Win + R` → `shell:startup`)
- Check if Windows Defender or antivirus is blocking the script
- Try running PowerShell as Administrator and re-run `SetupStartup.ps1`

**PowerShell execution policy errors:**
- All batch files use `-ExecutionPolicy Bypass` to work on any Windows system
- No manual PowerShell policy changes are needed
- If you encounter any issues, try running as Administrator

## 🔧 How It Works

1. **On Startup**: Windows runs `VencordAutoStart.bat`
2. **Patching**: The batch file calls the PowerShell script which runs `VencordInstallerCli.exe -repair -branch auto`
3. **Launch**: After successful patching, the script automatically finds and launches Discord
4. **Logging**: All activities are logged to `vencord-startup.log` for debugging

## 🔒 Security Notes

- The batch file runs with `-ExecutionPolicy Bypass` only for this specific script
- The script runs minimized and hidden to avoid interrupting your startup
- All file operations are performed in the script's directory
- No system modifications are made beyond adding a startup shortcut

## 📝 Customization

You can modify `VencordAutoStart.ps1` to:
- Add delays before launching Discord
- Launch additional applications
- Send notifications when patching completes
- Customize Discord launch arguments

## 🆘 Support

If you encounter issues:
1. Check the log file: `vencord-startup.log`
2. Test the script manually: `.\VencordAutoStart.bat`
3. Ensure all files are in the same directory
4. Verify you have the latest Vencord installer

## 🔄 Git Repository

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
- **v1.0** - Initial release with automated Vencord patching and Discord launch
- Fixed CLI syntax to use `-repair -branch auto` for unattended operation
- Added comprehensive logging and error handling
- Implemented automatic Discord detection and launch

---

**Last Updated**: November 2025  
**Version**: 1.0  
**Compatibility**: Windows 10/11, PowerShell 5.1+  
**Repository**: Available on GitHub for version control and updates