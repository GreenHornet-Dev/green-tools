<#
.SYNOPSIS
    Green Tools - System Update & Debloat
.DESCRIPTION
    Checks for Windows updates, Dell Command Update, and removes common bloatware.
    Run as Administrator.
.NOTES
    Version: 1.0
    Author:  GreenHornet-Dev
    GitHub:  https://github.com/GreenHornet-Dev/green-tools
#>

#Requires -RunAsAdministrator

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ============================================" -ForegroundColor Green
    Write-Host "     SYSTEM UPDATE & DEBLOAT TOOL            " -ForegroundColor Green
    Write-Host "  ============================================`n" -ForegroundColor Green
}

function Invoke-WindowsUpdate {
    Write-Host "  [Windows Update]" -ForegroundColor Cyan
    Write-Host "  Checking for PSWindowsUpdate module..." -ForegroundColor Gray

    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "  Installing PSWindowsUpdate module..." -ForegroundColor Yellow
        try {
            Install-Module PSWindowsUpdate -Force -Scope CurrentUser -ErrorAction Stop
            Write-Host "  Module installed successfully." -ForegroundColor Green
        } catch {
            Write-Host "  Could not install PSWindowsUpdate. Opening Windows Update..." -ForegroundColor Yellow
            Start-Process "ms-settings:windowsupdate"
            return
        }
    }

    Import-Module PSWindowsUpdate
    Write-Host "  Scanning for updates..." -ForegroundColor Gray
    $updates = Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot

    if ($updates.Count -eq 0) {
        Write-Host "  No updates available. System is up to date!" -ForegroundColor Green
    } else {
        Write-Host "  Found $($updates.Count) update(s). Installing..." -ForegroundColor Yellow
        Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -Confirm:$false
        Write-Host "  Updates installed. A reboot may be required." -ForegroundColor Green
    }
    Write-Host ""
}

function Invoke-DellUpdate {
    Write-Host "  [Dell Command Update]" -ForegroundColor Cyan
    $dcu = @(
        "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe",
        "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($dcu) {
        Write-Host "  Running Dell Command Update..." -ForegroundColor Gray
        Start-Process $dcu -ArgumentList "/applyUpdates -autoSuspendBitLocker=enable -reboot=disable" -Wait
        Write-Host "  Dell updates applied." -ForegroundColor Green
    } else {
        Write-Host "  Dell Command Update not found. Skipping." -ForegroundColor Yellow
    }
    Write-Host ""
}

function Remove-Bloatware {
    Write-Host "  [Bloatware Removal]" -ForegroundColor Cyan

    $bloatApps = @(
        "Microsoft.BingNews",
        "Microsoft.BingWeather",
        "Microsoft.GamingApp",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.MixedReality.Portal",
        "Microsoft.People",
        "Microsoft.SkypeApp",
        "Microsoft.Todos",
        "Microsoft.WindowsCommunicationsApps",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.YourPhone",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo"
    )

    $removed = 0
    foreach ($app in $bloatApps) {
        $pkg = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
        if ($pkg) {
            Write-Host "  Removing: $app" -ForegroundColor Gray
            Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction SilentlyContinue
            $removed++
        }
    }

    if ($removed -eq 0) {
        Write-Host "  No bloatware found to remove." -ForegroundColor Green
    } else {
        Write-Host "  Removed $removed bloatware app(s)." -ForegroundColor Green
    }
    Write-Host ""
}

# Main
Write-Header

Write-Host "  Choose what to run:`n" -ForegroundColor Cyan
Write-Host "  [1] Windows Update only"
Write-Host "  [2] Dell Update only"
Write-Host "  [3] Remove Bloatware only"
Write-Host "  [4] Run ALL (recommended)"
Write-Host "  [Q] Cancel`n"

$choice = Read-Host "  Enter choice"

switch ($choice.ToUpper()) {
    '1' { Invoke-WindowsUpdate }
    '2' { Invoke-DellUpdate }
    '3' { Remove-Bloatware }
    '4' { Invoke-WindowsUpdate; Invoke-DellUpdate; Remove-Bloatware }
    'Q' { Write-Host "  Cancelled." -ForegroundColor Yellow; exit }
    default { Write-Host "  Invalid choice." -ForegroundColor Red; exit }
}

Write-Host "  Done! Press any key to exit..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
