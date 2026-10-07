#!/usr/bin/env pwsh

# NoSQL Migration Project - Automated Startup Script
# This script starts all services and runs the data migration

param(
    [switch]$SkipDocker = $false,
    [switch]$SkipMigration = $false,
    [int]$WaitSeconds = 60
)

$scriptRoot = if ($PSScriptRoot) {
    $PSScriptRoot
} elseif ($PSCommandPath) {
    Split-Path -Parent $PSCommandPath
} elseif ($MyInvocation.MyCommand.Path) {
    Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    Get-Location
}

$projectRoot = $scriptRoot
$ErrorActionPreference = "Stop"

# Color output
function Log-Success { Write-Host "[OK] $args" -ForegroundColor Green }
function Log-Fail { Write-Host "[X] $args" -ForegroundColor Red }
function Log-Info { Write-Host "[INFO] $args" -ForegroundColor Cyan }

Log-Info "=================================================="
Log-Info "   NoSQL Migration Project - Startup Script"
Log-Info "=================================================="

# Check Docker installation
Log-Info "Checking Docker installation..."
try {
    $dockerVersion = docker --version
    Log-Success "Docker found: $dockerVersion"
} catch {
    Log-Fail "Docker is not installed or not in PATH"
    Log-Info "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    exit 1
}

# Check Python installation
Log-Info "Checking Python installation..."
try {
    $pythonVersion = python --version
    Log-Success "Python found: $pythonVersion"
} catch {
    Log-Fail "Python is not installed or not in PATH"
    Log-Info "Please install Python from: https://www.python.org/downloads/"
    exit 1
}

# Check for cassandra-driver
Log-Info "Checking Cassandra Python driver..."
$cassandraDriver = python -c "import cassandra" 2>&1
if ($LASTEXITCODE -eq 0) {
    Log-Success "Cassandra driver is installed"
} else {
    Log-Info "Installing Cassandra driver..."
    pip install cassandra-driver | Out-Null
    Log-Success "Cassandra driver installed"
}

# Start Docker services
if (-not $SkipDocker) {
    Log-Info "Starting Docker services from: $projectRoot"
    Set-Location $projectRoot
    
    Log-Info "Running: docker-compose up -d"
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Log-Success "Docker services started"
    } else {
        Log-Fail "Failed to start Docker services"
        exit 1
    }
    
    # Check service status
    Log-Info "Checking service status..."
    docker-compose ps
    
    # Wait for Cassandra to be healthy
    Log-Info "Waiting for Cassandra to become healthy (up to $WaitSeconds seconds)..."
    $startTime = Get-Date
    $healthy = $false
    
    while ((Get-Date) -lt $startTime.AddSeconds($WaitSeconds)) {
        try {
            docker exec cassandra cqlsh -e "describe keyspaces" | Out-Null
            $healthy = $true
            break
        } catch {
            Start-Sleep -Seconds 5
            Write-Host "." -NoNewline
        }
    }
    
    if ($healthy) {
        Log-Success "Cassandra is healthy"
    } else {
        Log-Fail "Cassandra did not become healthy in time"
        Log-Info "Check logs with: docker-compose logs cassandra"
        exit 1
    }
    
    # Initialize schema
    Log-Info "Initializing Cassandra schema..."
    $schema = Get-Content "$projectRoot\cassandra-schema.cql" -Raw
    docker exec cassandra cqlsh -e "$schema" 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Log-Success "Cassandra schema initialized"
    } else {
        Log-Fail "Failed to initialize Cassandra schema"
        exit 1
    }
    
    Log-Info "Services are ready!"
    Log-Info "OpsCenter (Cassandra UI):   http://localhost:8888"
    Log-Info "Mongo Express (MongoDB UI): http://localhost:28081 (admin/changeme)"
} else {
    Log-Info "Skipping Docker services (--SkipDocker)"
}

# Run data migration
if (-not $SkipMigration) {
    Log-Info "Running data migration..."
    Set-Location $projectRoot
    
    Log-Info "Executing: python import_data_to_cassandra.py"
    python import_data_to_cassandra.py
    
    if ($LASTEXITCODE -eq 0) {
        Log-Success "Data migration completed successfully"
    } else {
        Log-Fail "Data migration failed"
        exit 1
    }
} else {
    Log-Info "Skipping data migration (--SkipMigration)"
}

Log-Info "=================================================="
Log-Success "Project is ready to use!"
Log-Info "=================================================="

Log-Info "Available Services:"
Log-Info "  - Cassandra:      localhost:9042"
Log-Info "  - OpsCenter UI:   http://localhost:8888"
Log-Info "  - MongoDB:        localhost:27017"
Log-Info "  - Mongo Express:  http://localhost:28081"
Log-Info "  - PostgreSQL:     localhost:5432"

Log-Info ""
Log-Info "Useful commands:"
Log-Info "  - View logs:     docker-compose logs -f"
Log-Info "  - Stop services: docker-compose down"
Log-Info "  - Cassandra CLI: docker exec -it cassandra cqlsh"
Log-Info "  - MongoDB CLI:   docker exec -it mongo mongosh"
