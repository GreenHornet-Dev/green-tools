<#
.SYNOPSIS
    Green Tools - Main Launcher
.DESCRIPTION
    Interactive menu launcher for all Green Tools utilities.
    Run as Administrator for full functionality.
.NOTES
    Version: 1.0
    Author:  GreenHornet-Dev
    GitHub:  https://github.com/GreenHornet-Dev/green-tools
#>

#Requires -RunAsAdministrator

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Show-Banner {
    Clear-Host
    Write-Host "`n" -NoNewline
    Write-Host "  ============================================" -ForegroundColor Green
    Write-Host "       GREEN TOOLS - System Utility Suite     " -ForegroundColor Green
    Write-Host "  ============================================" -ForegroundColor Green
    Write-Host "  Version 1.0  |  github.com/GreenHornet-Dev  " -ForegroundColor DarkGray
    Write-Host "  ============================================`n" -ForegroundColor Green
}

function Show-Menu {
    Write-Host "  Select a tool:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1]  System Update & Debloat" -ForegroundColor White
    Write-Host "  [2]  App Scanner (Interactive)" -ForegroundColor White
    Write-Host "  [3]  Install Office 365 Modules" -ForegroundColor White
    Write-Host "  [4]  Office 365 Examples" -ForegroundColor White
    Write-Host "  [5]  System Maintenance Dashboard" -ForegroundColor White
    Write-Host "  [6]  System Maintenance Dashboard (Enhanced)" -ForegroundColor White
    Write-Host ""
    Write-Host "  [Q]  Quit" -ForegroundColor Red
    Write-Host ""
}

do {
    Show-Banner
    Show-Menu

    $choice = Read-Host "  Enter choice"

    switch ($choice.ToUpper()) {
        '1' {
            $script = Join-Path $ScriptRoot 'System-Update-Debloat.ps1'
            if (Test-Path $script) { & $script } else { Write-Host "  Script not found: $script" -ForegroundColor Red; Pause }
        }
        '2' {
            $script = Join-Path $ScriptRoot 'App-Scanner-Interactive.ps1'
            if (Test-Path $script) { & $script } else { Write-Host "  Script not found: $script" -ForegroundColor Red; Pause }
        }
        '3' {
            $script = Join-Path $ScriptRoot 'Install-Office365-Modules.ps1'
            if (Test-Path $script) { & $script } else { Write-Host "  Script not found: $script" -ForegroundColor Red; Pause }
        }
        '4' {
            $script = Join-Path $ScriptRoot 'Office365-Examples.ps1'
            if (Test-Path $script) { & $script } else { Write-Host "  Script not found: $script" -ForegroundColor Red; Pause }
        }
        '5' {
            $html = Join-Path $ScriptRoot 'System-Maintenance-Dashboard.html'
            if (Test-Path $html) { Start-Process $html } else { Write-Host "  File not found: $html" -ForegroundColor Red; Pause }
        }
        '6' {
            $html = Join-Path $ScriptRoot 'System-Maintenance-Dashboard-ENHANCED.html'
            if (Test-Path $html) { Start-Process $html } else { Write-Host "  File not found: $html" -ForegroundColor Red; Pause }
        }
        'Q' { Write-Host "`n  Goodbye!`n" -ForegroundColor Green; break }
        default { Write-Host "`n  Invalid choice. Press any key..." -ForegroundColor Yellow; $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') }
    }
} while ($choice.ToUpper() -ne 'Q')
