<#
.SYNOPSIS
    Green Tools Bootstrap Installer
.DESCRIPTION
    One-liner installer for Green Tools. Downloads all scripts from GitHub
    and sets up the tools on the local machine.

    Run with:
    iex (iwr -uri "https://raw.githubusercontent.com/GreenHornet-Dev/green-tools/main/Install-GreenTools-BOOTSTRAP.ps1" -UseBasicParsing).Content

.NOTES
    Version: 1.0
    Author:  GreenHornet-Dev
    GitHub:  https://github.com/GreenHornet-Dev/green-tools
#>

# Auto-elevate to Administrator if not already
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Restarting as Administrator..." -ForegroundColor Yellow
    Start-Process PowerShell -ArgumentList "-ExecutionPolicy Bypass -Command iex (iwr -uri 'https://raw.githubusercontent.com/GreenHornet-Dev/green-tools/main/Install-GreenTools-BOOTSTRAP.ps1' -UseBasicParsing).Content" -Verb RunAs
    exit
}

$ErrorActionPreference = 'Stop'
$LogFile = "$env:USERPROFILE\Desktop\GreenTools-Install-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$InstallDir = "C:\Green Tools"
$BaseUrl = "https://raw.githubusercontent.com/GreenHornet-Dev/green-tools/main"

function Write-Log {
    param([string]$Message, [string]$Color = 'White')
    $timestamp = Get-Date -Format 'HH:mm:ss'
    $line = "[$timestamp] $Message"
    Write-Host "  $line" -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}

Clear-Host
Write-Host ""
Write-Host "  ============================================" -ForegroundColor Green
Write-Host "     GREEN TOOLS - BOOTSTRAP INSTALLER       " -ForegroundColor Green
Write-Host "  ============================================" -ForegroundColor Green
Write-Host "  github.com/GreenHornet-Dev/green-tools      " -ForegroundColor DarkGray
Write-Host "  ============================================`n" -ForegroundColor Green

Write-Log "Starting Green Tools installation..."
Write-Log "Install directory: $InstallDir"
Write-Log "Log file: $LogFile"
Write-Host ""

# Create install directory
try {
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        Write-Log "Created directory: $InstallDir" Green
    } else {
        Write-Log "Directory exists: $InstallDir" DarkGray
    }
} catch {
    Write-Log "ERROR creating directory: $_" Red
    exit 1
}

# Files to download
$scripts = @(
    "Launch-Green-Tools.ps1",
    "System-Update-Debloat.ps1",
    "App-Scanner-Interactive.ps1",
    "Install-Office365-Modules.ps1",
    "Office365-Examples.ps1",
    "System-Maintenance-Dashboard.html",
    "Launch-Green-Tools.bat"
)

Write-Host "  Downloading files...`n" -ForegroundColor Cyan

$errorCount = 0
$downloadCount = 0

foreach ($file in $scripts) {
    $url = "$BaseUrl/$file"
    $dest = "$InstallDir\$file"
    Write-Host "  Downloading: $file" -NoNewline

    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -ErrorAction Stop
        Write-Host " [OK]" -ForegroundColor Green
        Write-Log "Downloaded: $file" DarkGray
        $downloadCount++
    } catch {
        Write-Host " [FAILED]" -ForegroundColor Red
        Write-Log "Failed to download: $file - $_" Red
        $errorCount++
    }
}

Write-Host ""
Write-Log "Downloads: $downloadCount succeeded, $errorCount failed"

# Create Desktop shortcut (.bat launcher)
Write-Host "  Creating desktop shortcuts..." -ForegroundColor Cyan
try {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $batPath = "$InstallDir\Launch-Green-Tools.bat"

    # .bat shortcut on desktop
    $shortcutBat = "$desktop\Green Tools.bat"
    $batContent = "@echo off`r`npowershell -ExecutionPolicy Bypass -File `"$InstallDir\Launch-Green-Tools.ps1`""
    Set-Content -Path $shortcutBat -Value $batContent -Encoding ASCII
    Write-Log "Created desktop shortcut: Green Tools.bat" Green

    # .lnk shortcut
    $WScript = New-Object -ComObject WScript.Shell
    $shortcut = $WScript.CreateShortcut("$desktop\Green Tools.lnk")
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$InstallDir\Launch-Green-Tools.ps1`""
    $shortcut.WorkingDirectory = $InstallDir
    $shortcut.Description = "Green Tools - System Utilities"
    $shortcut.Save()
    Write-Log "Created desktop shortcut: Green Tools.lnk" Green
} catch {
    Write-Log "Warning: Could not create shortcuts - $_" Yellow
}

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Green
Write-Host "  INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "  ============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Installed to: $InstallDir" -ForegroundColor Cyan
Write-Host "  Files: $downloadCount downloaded" -ForegroundColor Cyan
Write-Host "  Log:   $LogFile" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  HOW TO LAUNCH:" -ForegroundColor Yellow
Write-Host "  - Double-click 'Green Tools' on your Desktop"
Write-Host "  - Or run: $InstallDir\Launch-Green-Tools.ps1"
Write-Host ""

if ($errorCount -gt 0) {
    Write-Host "  WARNING: $errorCount file(s) failed to download." -ForegroundColor Yellow
    Write-Host "  Check log for details: $LogFile" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "  Press any key to exit..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
