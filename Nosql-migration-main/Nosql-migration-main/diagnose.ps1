#!/usr/bin/env pwsh

# NoSQL Migration Project - Diagnostic Script
# Checks system requirements and Docker status

$ErrorActionPreference = "Continue"

function Write-Section { Write-Host "`n========== $args ==========" -ForegroundColor Yellow }
function Write-Check { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-Warn { Write-Host "[!] $args" -ForegroundColor Magenta }
function Write-Fail { Write-Host "[X] $args" -ForegroundColor Red }

Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  NoSQL Migration - Diagnostics" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. System Info
Write-Section "System Information"
$osInfo = Get-CimInstance Win32_OperatingSystem
Write-Host "OS: $($osInfo.Caption)"
Write-Host "Version: $($osInfo.Version)"
Write-Host "Architecture: $((Get-CimInstance Win32_OperatingSystem).OSArchitecture)"

# 2. Docker Check
Write-Section "Docker Status"
try {
    $dockerVersion = docker --version
    Write-Check "Docker: $dockerVersion"
    
    $dockerInfo = docker info 2>&1 | Select-Object -First 1
    $containerCount = docker ps -q | Measure-Object | Select-Object -ExpandProperty Count
    Write-Check "Containers running: $containerCount"
} catch {
    Write-Fail "Docker is not installed or not running"
    Write-Warn "Install Docker Desktop: https://www.docker.com/products/docker-desktop"
}

# 3. Docker Compose Check
Write-Section "Docker Compose Status"
try {
    $composeVersion = docker-compose --version
    Write-Check "Docker Compose: $composeVersion"
} catch {
    Write-Fail "Docker Compose is not available"
}

# 4. Python Check
Write-Section "Python Environment"
try {
    $pythonVersion = python --version 2>&1
    Write-Check "Python: $pythonVersion"
    
    # Check for cassandra-driver
    $driverCheck = python -c "import cassandra; print(cassandra.__version__)" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Check "Cassandra Driver: $driverCheck"
    } else {
        Write-Warn "Cassandra Driver not installed. Run: pip install cassandra-driver"
    }
} catch {
    Write-Fail "Python is not installed or not in PATH"
    Write-Warn "Install Python: https://www.python.org/downloads/"
}

# 5. Project Structure
Write-Section "Project Files"
$projectRoot = Split-Path -Parent $MyInvocation.MyCommandPath
$files = @(
    "cassandra-schema.cql",
    "docker-compose.yml",
    "import_data_to_cassandra.py",
    "exported-data.json",
    "schema.sql"
)

foreach ($file in $files) {
    $path = Join-Path $projectRoot $file
    if (Test-Path $path) {
        Write-Check "Found: $file"
    } else {
        Write-Fail "Missing: $file"
    }
}

# 6. Port Availability
Write-Section "Port Availability"
$ports = @{
    "Cassandra" = 9042
    "OpsCenter" = 8888
    "MongoDB" = 27017
    "Mongo Express" = 28081
    "PostgreSQL" = 5432
}

foreach ($service in $ports.GetEnumerator()) {
    $connection = Get-NetTCPConnection -LocalPort $service.Value -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Warn "$($service.Name) port $($service.Value) is in use (service may already be running)"
    } else {
        Write-Check "$($service.Name) port $($service.Value) is available"
    }
}

# 7. Docker Services Status
Write-Section "Docker Services (if running)"
try {
    Set-Location $projectRoot -ErrorAction SilentlyContinue
    $services = docker-compose ps 2>&1
    Write-Host $services
} catch {
    Write-Host "No services running or docker-compose.yml not found"
}

# 8. Quick Commands
Write-Section "Quick Start Commands"
Write-Host @"
[START SERVICES]
docker-compose up -d

[CHECK STATUS]
docker-compose ps

[VIEW LOGS]
docker-compose logs -f cassandra

[RUN MIGRATION]
python import_data_to_cassandra.py

[RUN FULL SETUP]
.\start-project.ps1
"@

# 9. Recommendations
Write-Section "Recommendations"
if (-not ($pythonVersion)) {
    Write-Warn "[INSTALL] Python 3.8 or higher"
}

try {
    docker ps > $null 2>&1
} catch {
    Write-Warn "[INSTALL] Docker Desktop"
}

try {
    $driverCheck = python -c "import cassandra" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "[INSTALL] pip install cassandra-driver"
    }
} catch {
}

Write-Host "`n" -NoNewline

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Run: .\start-project.ps1 to begin" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
