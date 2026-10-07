@echo off
REM NoSQL Migration Project - Quick Start (Windows Batch)
REM This script provides an easy way to start the project on Windows

cd /d "%~dp0"

REM Check if PowerShell is available
powershell -Command "Write-Host 'PowerShell available'" >nul 2>&1
if %errorlevel% equ 0 (
    echo Running project startup...
    powershell -ExecutionPolicy Bypass -File "start-project.ps1"
) else (
    echo This script requires PowerShell.
    echo Please run: powershell -ExecutionPolicy Bypass -File "start-project.ps1"
    pause
)
