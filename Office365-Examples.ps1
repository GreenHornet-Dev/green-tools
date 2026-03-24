<#
.SYNOPSIS
    Green Tools - Office 365 / Microsoft Graph Examples
.DESCRIPTION
    Example scripts and common commands for Microsoft 365 administration.
    Requires modules from Install-Office365-Modules.ps1
.NOTES
    Version: 1.0
    Author:  GreenHornet-Dev
    GitHub:  https://github.com/GreenHornet-Dev/green-tools
#>

# ============================================================
# MICROSOFT GRAPH - Connect & Common Commands
# ============================================================

# Connect to Microsoft Graph
# Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All", "Mail.Read"

# Get all users
# Get-MgUser -All | Select-Object DisplayName, UserPrincipalName, AccountEnabled

# Get specific user
# Get-MgUser -UserId "user@domain.com"

# Get all groups
# Get-MgGroup -All | Select-Object DisplayName, GroupTypes

# Get group members
# Get-MgGroupMember -GroupId "group-object-id"

# Get licensed users
# Get-MgUser -All -Property DisplayName,UserPrincipalName,AssignedLicenses | Where-Object { $_.AssignedLicenses.Count -gt 0 }

# Disable a user account
# Update-MgUser -UserId "user@domain.com" -AccountEnabled $false

# ============================================================
# EXCHANGE ONLINE - Connect & Common Commands
# ============================================================

# Connect to Exchange Online
# Connect-ExchangeOnline -UserPrincipalName admin@domain.com

# Get all mailboxes
# Get-Mailbox -ResultSize Unlimited | Select-Object DisplayName, PrimarySmtpAddress

# Get mailbox size
# Get-MailboxStatistics -Identity "user@domain.com" | Select-Object DisplayName, TotalItemSize

# Set mailbox quota
# Set-Mailbox -Identity "user@domain.com" -ProhibitSendQuota 50GB -IssueWarningQuota 45GB

# Get distribution groups
# Get-DistributionGroup | Select-Object Name, PrimarySmtpAddress

# Add member to distribution group
# Add-DistributionGroupMember -Identity "group@domain.com" -Member "user@domain.com"

# Get mail flow rules
# Get-TransportRule | Select-Object Name, State

# ============================================================
# MICROSOFT TEAMS - Connect & Common Commands
# ============================================================

# Connect to Teams
# Connect-MicrosoftTeams

# Get all Teams
# Get-Team | Select-Object DisplayName, Visibility, Archived

# Get Team members
# Get-TeamMember -GroupId "team-object-id"

# Create a new Team
# New-Team -DisplayName "New Team" -Visibility Private

# Get Teams channels
# Get-TeamChannel -GroupId "team-object-id"

# ============================================================
# SHAREPOINT / PNP - Connect & Common Commands
# ============================================================

# Connect to SharePoint
# Connect-PnPOnline -Url "https://tenant.sharepoint.com" -Interactive

# Get all sites
# Get-PnPTenantSite | Select-Object Title, Url, StorageUsageCurrent

# Get site lists
# Get-PnPList | Select-Object Title, ItemCount

# Get list items
# Get-PnPListItem -List "Documents" | Select-Object Id, FieldValues

# ============================================================
# BULK OPERATIONS EXAMPLES
# ============================================================

# Export all users to CSV
function Export-AllUsersToCSV {
    param([string]$OutputPath = "$env:USERPROFILE\Desktop\M365-Users.csv")

    Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
    Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

    Write-Host "Fetching all users..." -ForegroundColor Cyan
    $users = Get-MgUser -All -Property DisplayName,UserPrincipalName,AccountEnabled,Department,JobTitle,CreatedDateTime

    $users | Select-Object DisplayName, UserPrincipalName, AccountEnabled, Department, JobTitle, CreatedDateTime |
        Export-Csv -Path $OutputPath -NoTypeInformation

    Write-Host "Exported $($users.Count) users to: $OutputPath" -ForegroundColor Green
}

# Get users who haven't signed in for 90 days
function Get-InactiveUsers {
    param([int]$DaysInactive = 90)

    Connect-MgGraph -Scopes "User.Read.All", "AuditLog.Read.All" -NoWelcome
    $cutoff = (Get-Date).AddDays(-$DaysInactive)

    Get-MgUser -All -Property DisplayName,UserPrincipalName,SignInActivity |
        Where-Object { $_.SignInActivity.LastSignInDateTime -lt $cutoff -or $_.SignInActivity.LastSignInDateTime -eq $null } |
        Select-Object DisplayName, UserPrincipalName,
            @{N='LastSignIn';E={ $_.SignInActivity.LastSignInDateTime }}
}

Write-Host "`n  Office 365 Examples Script Loaded!" -ForegroundColor Green
Write-Host "  Functions available:"
Write-Host "    Export-AllUsersToCSV [-OutputPath 'C:\export.csv']"
Write-Host "    Get-InactiveUsers [-DaysInactive 90]"
Write-Host ""
Write-Host "  See script comments for individual command examples." -ForegroundColor Gray
