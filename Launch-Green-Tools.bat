@echo off
title Green Tools Launcher
color 0A
cd /d "%~dp0"

:menu
cls
echo.
echo  ============================================
echo     GREEN TOOLS - System Utility Suite
echo  ============================================
echo  github.com/GreenHornet-Dev/green-tools
echo  ============================================
echo.
echo  [1]  System Update ^& Debloat
echo  [2]  App Scanner (Interactive)
echo  [3]  Install Office 365 Modules
echo  [4]  Office 365 Examples
echo  [5]  System Maintenance Dashboard
echo.
echo  [Q]  Quit
echo.
set /p choice=  Enter choice: 

if /i "%choice%"=="1" goto update
if /i "%choice%"=="2" goto scanner
if /i "%choice%"=="3" goto office
if /i "%choice%"=="4" goto examples
if /i "%choice%"=="5" goto dashboard
if /i "%choice%"=="Q" goto quit
goto menu

:update
powershell -ExecutionPolicy Bypass -File "%~dp0System-Update-Debloat.ps1"
goto menu

:scanner
powershell -ExecutionPolicy Bypass -File "%~dp0App-Scanner-Interactive.ps1"
goto menu

:office
powershell -ExecutionPolicy Bypass -File "%~dp0Install-Office365-Modules.ps1"
goto menu

:examples
powershell -ExecutionPolicy Bypass -File "%~dp0Office365-Examples.ps1"
goto menu

:dashboard
start "" "%~dp0System-Maintenance-Dashboard.html"
goto menu

:quit
echo.
echo  Goodbye!
echo.
timeout /t 2 >nul
exit /b 0
