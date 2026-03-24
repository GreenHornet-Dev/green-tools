# Green Tools

A collection of PowerShell-based system administration and maintenance tools for Windows.

## Quick Install (One-Liner)

Run this in PowerShell as Administrator:

```powershell
iex (iwr -uri "https://raw.githubusercontent.com/GreenHornet-Dev/green-tools/main/Install-GreenTools-BOOTSTRAP.ps1" -UseBasicParsing).Content
```

## Tools Included

| Script | Description |
|--------|-------------|
| `Launch-Green-Tools.ps1` | Main launcher menu |
| `System-Update-Debloat.ps1` | Windows/Dell updates + bloatware removal |
| `App-Scanner-Interactive.ps1` | Interactive installed app scanner |
| `Install-Office365-Modules.ps1` | Microsoft 365 PowerShell module installer |
| `Office365-Examples.ps1` | Office 365 usage examples |
| `System-Maintenance-Dashboard.html` | Visual system status dashboard |

## Requirements

- Windows 10 / 11
- PowerShell 5.1 or higher
- Administrator privileges

## Installation

### Option 1: Bootstrap Installer (Recommended)

```powershell
iex (iwr -uri "https://raw.githubusercontent.com/GreenHornet-Dev/green-tools/main/Install-GreenTools-BOOTSTRAP.ps1" -UseBasicParsing).Content
```

This will:
- Download all scripts to `C:\Green Tools`
- Create desktop shortcuts
- Set up the launcher

### Option 2: Manual Download

1. Download the repository as a ZIP
2. Extract to `C:\Green Tools`
3. Run `Launch-Green-Tools.ps1` as Administrator

## Usage

After installation, launch from:
- Desktop shortcut: **Green Tools**
- PowerShell: `C:\Green Tools\Launch-Green-Tools.ps1`
- Batch: `C:\Green Tools\Launch-Green-Tools.bat`

## License

MIT License - see LICENSE file for details.

## Author

GreenHornet-Dev
