# NoSQL Migration Project - Setup Guide

## Prerequisites

### Required Software
1. **Docker Desktop** - for running containers
2. **Python 3.8+** - for data migration script
3. **Git** (optional) - for version control

---

## Installation Steps

### Step 1: Install Docker Desktop

**Option A: Using Chocolatey (Recommended)**
```powershell
# Run PowerShell as Administrator
choco install docker-desktop -y
```

**Option B: Manual Download**
1. Visit: https://www.docker.com/products/docker-desktop
2. Download "Docker Desktop for Windows"
3. Run the installer
4. Follow the setup wizard
5. Restart your computer when prompted

**Verify Installation:**
```powershell
docker --version
docker run hello-world
```

---

### Step 2: Install Python

**Option A: Using Chocolatey**
```powershell
choco install python -y
```

**Option B: Windows Store**
```powershell
# In PowerShell as Administrator
Get-AppxPackage | Select-Object Name | Where-Object {$_.Name -match "Python"}
```

**Option C: Manual Download**
1. Visit: https://www.python.org/downloads/
2. Download Python 3.11 or later
3. Run installer (check "Add to PATH")

**Verify Installation:**
```powershell
python --version
pip --version
```

---

### Step 3: Install Python Dependencies

```powershell
# Navigate to project directory
cd "C:\Users\gharsalli hind\Desktop\study\IGL4\s2\nosql\Nosql-migration-main\Nosql-migration-main"

# Install Cassandra Python driver
pip install cassandra-driver
```

---

## Running the Project

### Step 1: Start Docker Services

```powershell
cd "C:\Users\gharsalli hind\Desktop\study\IGL4\s2\nosql\Nosql-migration-main\Nosql-migration-main"

# Start all containers
docker-compose up -d

# Check status
docker-compose ps
```

**Expected Output:**
```
NAME                COMMAND                  SERVICE     STATUS
cassandra           /bin/sh -c /init.sh      cassandra   Up (healthy)
opscenter           /bin/sh -c /init.sh      opscenter   Up
mongo                docker-entrypoint.sh    mongo       Up
mongo-express       node ./app.js            mongo-express   Up
sqldb               postgres                 sqldb       Up
```

### Step 2: Wait for Cassandra to be Healthy

```powershell
# Check Cassandra health
docker exec cassandra cqlsh -e "describe keyspaces"

# Wait until you see output with keyspaces
```

### Step 3: Initialize Cassandra Schema

```powershell
# Create keyspace and tables
docker exec cassandra cqlsh -e "$(Get-Content cassandra-schema.cql -Raw)"

# Verify schema
docker exec cassandra cqlsh -e "use ecommerce; describe tables;"
```

### Step 4: Run Data Migration

```powershell
# Run the Python migration script
python import_data_to_cassandra.py
```

**Expected Output:**
```
Data import completed successfully.
```

---

## Access the Services

Once running, access these UIs:

| Service | URL | Credentials |
|---------|-----|-------------|
| **OpsCenter** (Cassandra UI) | http://localhost:8888 | None |
| **Mongo Express** (MongoDB UI) | http://localhost:28081 | admin / changeme |
| **PostgreSQL** | localhost:5432 | myuser / mypassword |
| **MongoDB** | localhost:27017 | mongoadmin / mongoadmin |
| **Cassandra** | localhost:9042 | None |

---

## Useful Commands

### Docker Commands
```powershell
# View logs
docker-compose logs -f cassandra
docker-compose logs -f mongo

# Stop services
docker-compose down

# Remove all volumes (WARNING: deletes data)
docker-compose down -v

# Rebuild services
docker-compose up --build
```

### Cassandra Commands
```powershell
# Access Cassandra shell
docker exec -it cassandra cqlsh

# Inside cqlsh:
use ecommerce;
select * from orders_by_id;
select * from sales_by_user;
select * from sales_by_product;
```

### MongoDB Commands
```powershell
# Access MongoDB shell
docker exec -it mongo mongosh -u mongoadmin -p mongoadmin

# Inside mongosh:
use admin
db.runCommand( { listDatabases: 1 } )
```

### PostgreSQL Commands
```powershell
# Access PostgreSQL shell
docker exec -it sqldb psql -U myuser -d projet

# Inside psql:
\dt
select * from users;
```

---

## Troubleshooting

### Docker services won't start
```powershell
# Check if Docker daemon is running
docker ps

# Restart Docker Desktop
# Settings > Resources > restart
```

### Cassandra is not healthy
```powershell
# Check Cassandra logs
docker-compose logs cassandra

# Give it more time (can take 60+ seconds)
# Wait 2-3 minutes before attempting migration
```

### Python script fails with "Connection refused"
```powershell
# Ensure cassandra service is healthy
docker-compose ps

# Try accessing Cassandra manually first
docker exec cassandra cqlsh -e "describe keyspaces"
```

### Port already in use
```powershell
# Find what's using the port (e.g., 9042 for Cassandra)
Get-NetTCPConnection -LocalPort 9042 -ErrorAction SilentlyContinue
```

---

## Project Structure

```
Nosql-migration-main/
├── cassandra-schema.cql          # Cassandra schema definition
├── docker-compose.yml            # Docker service configuration
├── import_data_to_cassandra.py  # Data migration script
├── exported-data.json            # Sample data to import
├── schema.sql                    # PostgreSQL schema
├── sqldata-export.sql            # PostgreSQL sample data
└── Project_Report_clean.md       # Full project documentation
```

---

## Next Steps

1. ✅ Install Docker Desktop
2. ✅ Install Python 3.8+
3. ✅ Run: `docker-compose up -d`
4. ✅ Initialize schema: `docker exec cassandra cqlsh -e "$(Get-Content cassandra-schema.cql -Raw)"`
5. ✅ Run migration: `python import_data_to_cassandra.py`
6. ✅ Access UIs at localhost:8888, localhost:28081, etc.
7. ✅ View project documentation: Project_Report_clean.md

---

## Support

Refer to the project report for:
- Detailed architecture explanations
- Data model comparisons
- Performance analysis
- Migration strategies
