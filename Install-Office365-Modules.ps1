<#
.SYNOPSIS
    Green Tools - Install Office 365 / Microsoft 365 PowerShell Modules
.DESCRIPTION
    Installs and configures Microsoft Graph, Exchange Online, Teams, and SharePoint modules.
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
    Write-Host "     OFFICE 365 MODULE INSTALLER             " -ForegroundColor Green
    Write-Host "  ============================================`n" -ForegroundColor Green
}

function Install-ModuleSafe {
    param(
        [string]$ModuleName,
        [string]$Description
    )

    Write-Host "  Installing: $ModuleName" -NoNewline
    try {
        if (Get-Module -ListAvailable -Name $ModuleName) {
            Write-Host " [Already installed - updating...]" -ForegroundColor DarkGray
            Update-Module -Name $ModuleName -Force -ErrorAction SilentlyContinue
        } else {
            Install-Module -Name $ModuleName -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
        }
        Write-Host " [OK]" -ForegroundColor Green
        return $true
    } catch {
        Write-Host " [FAILED: $($_.Exception.Message)]" -ForegroundColor Red
        return $false
    }
}

Write-Header

Write-Host "  This will install Microsoft 365 PowerShell modules." -ForegroundColor Cyan
Write-Host "  Modules: Microsoft.Graph, ExchangeOnlineManagement," 
Write-Host "           MicrosoftTeams, PnP.PowerShell`n"

$confirm = Read-Host "  Proceed? (Y/N)"
if ($confirm.ToUpper() -ne 'Y') {
    Write-Host "  Cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "  Setting up NuGet and PSGallery..." -ForegroundColor Cyan
try {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue | Out-Null
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    Write-Host "  PSGallery configured as trusted." -ForegroundColor Green
} catch {
    Write-Host "  Warning: Could not configure PSGallery. Continuing..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  Installing modules..." -ForegroundColor Cyan
Write-Host ""

$modules = @(
    @{ Name = "Microsoft.Graph"; Desc = "Microsoft Graph API" },
    @{ Name = "ExchangeOnlineManagement"; Desc = "Exchange Online" },
    @{ Name = "MicrosoftTeams"; Desc = "Microsoft Teams" },
    @{ Name = "PnP.PowerShell"; Desc = "SharePoint PnP" }
)

$success = 0
$failed = 0

foreach ($mod in $modules) {
    $result = Install-ModuleSafe -ModuleName $mod.Name -Description $mod.Desc
    if ($result) { $success++ } else { $failed++ }
}

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Green
Write-Host "  Results: $success installed, $failed failed" -ForegroundColor $(if ($failed -eq 0) { 'Green' } else { 'Yellow' })
Write-Host "  ============================================`n" -ForegroundColor Green

if ($success -gt 0) {
    Write-Host "  Quick Connect Examples:" -ForegroundColor Cyan
    Write-Host "  Connect-MgGraph -Scopes 'User.Read.All'"
    Write-Host "  Connect-ExchangeOnline -UserPrincipalName admin@domain.com"
    Write-Host "  Connect-MicrosoftTeams"
    Write-Host ""
}

Write-Host "  Done! Press any key to exit..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
