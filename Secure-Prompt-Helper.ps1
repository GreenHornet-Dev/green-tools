# ============================================================
#  Secure Prompt Helper — CDS / GreenHornet IT Tools
#  Prompts for sensitive data at runtime. Never stored.
#  Paste tokens, passwords, keys — they live in session only.
# ============================================================

# ── Secure input function ────────────────────────────────────
function Get-SecureInput {
    param(
        [string]$Prompt,
        [switch]$IsPassword   # masks input with asterisks
    )
    if ($IsPassword) {
        $secure = Read-Host -Prompt $Prompt -AsSecureString
        return [Runtime.InteropServices.Marshal]::PtrToStringAuto(
               [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
    }
    return Read-Host -Prompt $Prompt
}

# ── Admin elevation check ────────────────────────────────────
function Assert-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
               ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "`n  ⚠  This script requires Administrator privileges." -ForegroundColor Yellow
        Write-Host "     Right-click PowerShell → Run as Administrator`n" -ForegroundColor Yellow
        exit 1
    }
}

# ── Clear sensitive variables from session ───────────────────
function Clear-SensitiveVars {
    param([string[]]$Names)
    foreach ($name in $Names) {
        Remove-Variable -Name $name -Scope Global -ErrorAction SilentlyContinue
        Remove-Variable -Name $name -Scope Script -ErrorAction SilentlyContinue
        Remove-Variable -Name $name -Scope Local  -ErrorAction SilentlyContinue
    }
    [System.GC]::Collect()
}

# ────────────────────────────────────────────────────────────
#  USAGE EXAMPLES — copy the block you need into your script
# ────────────────────────────────────────────────────────────

<#
# ── Example 1: API token (e.g. Lansweeper PAT) ──────────────
. .\Secure-Prompt-Helper.ps1

$PAT    = Get-SecureInput "🔐 Paste Lansweeper PAT Token"
$SiteId = Get-SecureInput "🔐 Lansweeper Site ID"

# ... use $PAT and $SiteId in your API calls ...

Clear-SensitiveVars 'PAT','SiteId'


# ── Example 2: Admin credentials ────────────────────────────
. .\Secure-Prompt-Helper.ps1
Assert-Admin    # stops here if not elevated

$AdminUser = Get-SecureInput "🔐 Admin Username (domain\user)"
$AdminPass = Get-SecureInput "🔐 Admin Password" -IsPassword

$cred = New-Object System.Management.Automation.PSCredential($AdminUser,
        (ConvertTo-SecureString $AdminPass -AsPlainText -Force))

# ... use $cred ...

Clear-SensitiveVars 'AdminUser','AdminPass'


# ── Example 3: Multiple keys / tokens ───────────────────────
. .\Secure-Prompt-Helper.ps1

Write-Host "`n  Paste each value when prompted. Nothing is saved to disk.`n" -ForegroundColor Cyan

$TenantId  = Get-SecureInput "🔐 Azure Tenant ID"
$ClientId  = Get-SecureInput "🔐 App Client ID"
$Secret    = Get-SecureInput "🔐 Client Secret" -IsPassword

# ... your code ...

Clear-SensitiveVars 'TenantId','ClientId','Secret'


# ── Example 4: Winget deploy with admin check ────────────────
. .\Secure-Prompt-Helper.ps1
Assert-Admin

$packageId = Read-Host "Winget Package ID to install"
winget install --id $packageId --silent --accept-source-agreements --accept-package-agreements
#>

# ────────────────────────────────────────────────────────────
#  STANDALONE DEMO — runs if you execute this file directly
# ────────────────────────────────────────────────────────────
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host "`n  ══ Secure Prompt Helper — Demo ══`n" -ForegroundColor Cyan

    $token = Get-SecureInput "🔐 Paste a test token (won't be stored)"
    Write-Host "`n  ✔  Received token — length: $($token.Length) chars" -ForegroundColor Green
    Write-Host "     (Token is in session memory only — not written anywhere)`n" -ForegroundColor Gray

    Clear-SensitiveVars 'token'
    Write-Host "  ✔  Token cleared from session.`n" -ForegroundColor Green
}
