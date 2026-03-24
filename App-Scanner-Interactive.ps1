<#
.SYNOPSIS
    Green Tools - Interactive App Scanner
.DESCRIPTION
    Scans installed applications and provides options to view, export, or search them.
.NOTES
    Version: 1.0
    Author:  GreenHornet-Dev
    GitHub:  https://github.com/GreenHornet-Dev/green-tools
#>

#Requires -RunAsAdministrator

function Get-InstalledApps {
    $apps = @()

    # 64-bit apps
    $apps += Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate,
            @{N='Architecture';E={'64-bit'}}

    # 32-bit apps on 64-bit system
    $apps += Get-ItemProperty 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate,
            @{N='Architecture';E={'32-bit'}}

    # Current user apps
    $apps += Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate,
            @{N='Architecture';E={'User'}}

    return $apps | Sort-Object DisplayName
}

function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ============================================" -ForegroundColor Green
    Write-Host "     APP SCANNER - Interactive Mode          " -ForegroundColor Green
    Write-Host "  ============================================`n" -ForegroundColor Green
}

Show-Header
Write-Host "  Scanning installed applications..." -ForegroundColor Cyan
$allApps = Get-InstalledApps
Write-Host "  Found $($allApps.Count) installed applications.`n" -ForegroundColor Green

do {
    Write-Host "  OPTIONS:" -ForegroundColor Cyan
    Write-Host "  [1] View all apps (table)"
    Write-Host "  [2] Search by name"
    Write-Host "  [3] Filter by publisher"
    Write-Host "  [4] Export to CSV (Desktop)"
    Write-Host "  [5] Show app count summary"
    Write-Host "  [Q] Quit`n"

    $choice = Read-Host "  Enter choice"

    switch ($choice.ToUpper()) {
        '1' {
            $allApps | Format-Table DisplayName, DisplayVersion, Publisher, Architecture -AutoSize | Out-Host
            Read-Host "  Press Enter to continue"
        }
        '2' {
            $search = Read-Host "  Enter search term"
            $results = $allApps | Where-Object { $_.DisplayName -like "*$search*" }
            if ($results) {
                Write-Host "`n  Found $($results.Count) result(s):`n" -ForegroundColor Green
                $results | Format-Table DisplayName, DisplayVersion, Publisher -AutoSize | Out-Host
            } else {
                Write-Host "  No apps found matching: $search" -ForegroundColor Yellow
            }
            Read-Host "  Press Enter to continue"
        }
        '3' {
            $pub = Read-Host "  Enter publisher name"
            $results = $allApps | Where-Object { $_.Publisher -like "*$pub*" }
            if ($results) {
                Write-Host "`n  Found $($results.Count) app(s) from publisher matching '$pub':`n" -ForegroundColor Green
                $results | Format-Table DisplayName, DisplayVersion, Publisher -AutoSize | Out-Host
            } else {
                Write-Host "  No apps found from publisher: $pub" -ForegroundColor Yellow
            }
            Read-Host "  Press Enter to continue"
        }
        '4' {
            $csvPath = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), "Installed-Apps-$(Get-Date -Format 'yyyy-MM-dd').csv")
            $allApps | Export-Csv -Path $csvPath -NoTypeInformation
            Write-Host "  Exported to: $csvPath" -ForegroundColor Green
            Read-Host "  Press Enter to continue"
        }
        '5' {
            Write-Host "`n  Summary:" -ForegroundColor Cyan
            Write-Host "  Total apps: $($allApps.Count)"
            Write-Host "  64-bit:     $(($allApps | Where-Object Architecture -eq '64-bit').Count)"
            Write-Host "  32-bit:     $(($allApps | Where-Object Architecture -eq '32-bit').Count)"
            Write-Host "  User:       $(($allApps | Where-Object Architecture -eq 'User').Count)"
            Write-Host ""
            Read-Host "  Press Enter to continue"
        }
        'Q' { Write-Host "`n  Goodbye!`n" -ForegroundColor Green }
        default { Write-Host "  Invalid choice." -ForegroundColor Red }
    }

    Show-Header
    Write-Host "  Apps loaded: $($allApps.Count)`n" -ForegroundColor Gray

} while ($choice.ToUpper() -ne 'Q')
