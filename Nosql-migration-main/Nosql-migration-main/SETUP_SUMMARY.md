# 📊 NoSQL Migration Project - Setup Summary

**Date:** May 1, 2026  
**Project Location:** `C:\Users\gharsalli hind\Desktop\study\IGL4\s2\nosql\Nosql-migration-main\Nosql-migration-main`

---

## ✅ Current Status

| Component | Status | Details |
|-----------|--------|---------|
| **Python** | ✅ READY | Python 3.12.1 installed |
| **Cassandra Driver** | ✅ READY | cassandra-driver installed |
| **Docker** | ❌ NEEDED | Not installed - required for databases |
| **Docker Compose** | ❌ NEEDED | Not installed - required for orchestration |
| **PostgreSQL Service** | ⚠️ RUNNING | Already using port 5432 |
| **MongoDB Service** | ⚠️ RUNNING | Already using port 27017 |

---

## 🎯 What This Project Does

This is an **educational SQL-to-NoSQL migration project** that demonstrates:

1. **SQL Source Database** (PostgreSQL)
   - Normalized relational schema
   - Sample e-commerce data (users, products, orders)

2. **Data Transformation** (Python Script)
   - Denormalizes data from SQL format
   - Converts to JSON intermediate format
   - Optimizes for analytics queries

3. **NoSQL Implementations**
   - **Cassandra**: Column-family database with pre-aggregated analytics tables
   - **MongoDB**: Document-oriented database with flexible schema

4. **Analysis & Comparison**
   - Query performance differences
   - Storage considerations
   - Use case recommendations

---

## 📋 Project Files

```
Your project folder contains:
✅ cassandra-schema.cql           - Cassandra table definitions
✅ docker-compose.yml             - Service configuration
✅ import_data_to_cassandra.py   - Data migration script (uses Cassandra driver)
✅ exported-data.json             - Sample denormalized data
✅ schema.sql                     - PostgreSQL schema
✅ sqldata-export.sql             - PostgreSQL sample data
📄 Project_Report_clean.md        - Detailed analysis & findings

📄 SETUP_GUIDE.md                 - Comprehensive setup instructions
📄 QUICK_REFERENCE.md             - Quick commands & terminology
📄 diagnose.ps1                   - System diagnostic script
📄 start-project.ps1              - Automated startup script
📄 start-project.bat              - Windows launcher
```

---

## 🚀 Next Steps to Run the Project

### Step 1: Install Docker Desktop (Required)

**Download:**
- https://www.docker.com/products/docker-desktop

**After Installation:**
1. Run Docker Desktop
2. Wait for it to initialize (~2-3 minutes)
3. Verify: `docker --version` in PowerShell

---

### Step 2: Stop Existing Services (if needed)

Since PostgreSQL and MongoDB ports are in use:

```powershell
# Find what's using the ports
Get-NetTCPConnection -LocalPort 5432 -ErrorAction SilentlyContinue | Select-Object OwningProcess
Get-NetTCPConnection -LocalPort 27017 -ErrorAction SilentlyContinue | Select-Object OwningProcess

# Stop them if necessary (check what they are first!)
```

**OR** - Modify `docker-compose.yml` to use different ports:
```yaml
ports:
  - "15432:5432"    # Map to 15432 instead
  - "28017:27017"   # Map to 28017 instead
```

---

### Step 3: Run the Project

Once Docker Desktop is running:

```powershell
# Navigate to project
cd "C:\Users\gharsalli hind\Desktop\study\IGL4\s2\nosql\Nosql-migration-main\Nosql-migration-main"

# Start all services (automated)
.\start-project.ps1

# This will:
# 1. Start Docker containers
# 2. Wait for Cassandra to be healthy
# 3. Initialize Cassandra schema
# 4. Run the data migration script
# 5. Display access URLs
```

---

## 🌐 What You Can Access After Running

| Service | URL | Credentials |
|---------|-----|-------------|
| **Cassandra** | localhost:9042 | - |
| **OpsCenter UI** | http://localhost:8888 | None required |
| **MongoDB** | localhost:27017 | mongoadmin / mongoadmin |
| **Mongo Express UI** | http://localhost:28081 | admin / changeme |
| **PostgreSQL** | localhost:5432 | myuser / mypassword |

---

## 💻 Useful Commands (After Running)

### Check Services
```powershell
docker-compose ps
```

### View Logs
```powershell
docker-compose logs -f cassandra
docker-compose logs -f mongo
docker-compose logs -f sqldb
```

### Access Cassandra Database
```powershell
docker exec -it cassandra cqlsh

# Inside cqlsh:
use ecommerce;
select * from orders_by_id;
select * from sales_by_user;
select * from sales_by_product;
```

### Access MongoDB
```powershell
docker exec -it mongo mongosh -u mongoadmin -p mongoadmin

# Inside mongosh:
db.orders.find()
db.users.find()
```

### Stop Services
```powershell
docker-compose down
```

### Remove Everything (including data)
```powershell
docker-compose down -v
```

---

## 📚 Key Concepts You'll Learn

1. **Normalization vs Denormalization**
   - SQL normalizes data (separate tables, joins)
   - NoSQL denormalizes data (embedded, aggregates)

2. **Query Optimization**
   - SQL: Expensive joins
   - Cassandra: Pre-aggregated tables, no joins
   - MongoDB: Documents contain all data

3. **Data Modeling**
   - Relational: Entity-relationship model
   - Column-family: Optimized for analytics
   - Document: Flexible, self-contained

4. **ETL Process**
   - Extract from PostgreSQL
   - Transform to JSON format
   - Load into Cassandra

---

## 🔍 Project Structure (Architecture)

```
PostgreSQL (Normalized)
    ├── Users table
    ├── Products table
    ├── Orders table
    └── OrderItems table
           ↓ [Python ETL Script]
           ↓ (Extract → Denormalize → Transform)
           ↓
Exported JSON Format
    ├── Order records
    ├── Embedded user data
    ├── Embedded item data
    └── Pre-calculated aggregates
           ↓ [Python Import Script]
           ↓
Cassandra (Analytics Tables)
    ├── orders_by_id (Query by order)
    ├── sales_by_user (Query by user)
    └── sales_by_product (Query by product)

MongoDB (Document Store)
    ├── orders collection
    ├── users collection
    └── products collection
```

---

## 🎓 Educational Value

**Scenarios Covered:**
- ✓ Migrating legacy SQL systems to modern NoSQL
- ✓ Schema design for different database types
- ✓ Data transformation and ETL processes
- ✓ Query optimization strategies
- ✓ Distributed database concepts
- ✓ Analytics table design
- ✓ Multi-database deployment with Docker

---

## 📊 Data Flow Example

### Original SQL Query (Multiple Joins)
```sql
SELECT u.user_id, u.name, COUNT(*) as total_orders, SUM(oi.quantity * oi.price) as revenue
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY u.user_id, u.name;
```

### Cassandra Equivalent (Pre-aggregated)
```cassandra
SELECT user_id, user_name, total_orders, total_revenue FROM sales_by_user WHERE user_id = ?;
```

**Benefit:** No joins, single table lookup, ultra-fast response time!

---

## ⚡ Quick Diagnostic

To verify system readiness anytime:
```powershell
.\diagnose.ps1
```

This checks:
- ✅ Python installation
- ✅ Docker installation
- ✅ Cassandra driver
- ✅ Available ports
- ✅ Project files

---

## 📝 Files You Should Read

1. **QUICK_REFERENCE.md** - Command reference & terminology
2. **SETUP_GUIDE.md** - Detailed step-by-step instructions
3. **Project_Report_clean.md** - Full project analysis & findings

---

## 🎯 Success Criteria

After running the project successfully, you should be able to:

- [ ] See Docker containers running: `docker-compose ps`
- [ ] Access Cassandra: `docker exec cassandra cqlsh -e "describe keyspaces"`
- [ ] Access MongoDB at http://localhost:28081
- [ ] Access OpsCenter at http://localhost:8888
- [ ] Query data: `docker exec cassandra cqlsh -e "use ecommerce; select * from orders_by_id limit 10;"`
- [ ] Understand the three table structures in Cassandra
- [ ] Explain why denormalization is beneficial for analytics

---

## 💡 Summary

**You have:**
- ✅ Python 3.12.1 
- ✅ Cassandra driver installed
- ✅ All project files
- ✅ Automated startup scripts

**You need to:**
1. Install Docker Desktop (free)
2. Run `.\start-project.ps1`
3. Wait ~60 seconds for services to start
4. Access web UIs and explore the data

**Time to completion:** ~5-10 minutes (mostly waiting for Docker)

---

## 📞 Next Action

1. Download Docker Desktop: https://www.docker.com/products/docker-desktop
2. Install and restart computer
3. Run: `.\start-project.ps1` from the project folder
4. Follow the on-screen prompts

Good luck! 🚀
