# NoSQL Migration Project - Quick Reference

## 🎯 Project Overview

This is a **SQL to NoSQL Migration Project** that demonstrates:
- ✅ Migrating structured data from **PostgreSQL** (relational database) to **NoSQL** systems
- ✅ Implementation in **Cassandra** (column-family NoSQL database)
- ✅ Implementation in **MongoDB** (document-oriented NoSQL database)
- ✅ Data transformation and analysis
- ✅ Comparison of different data models

---

## 📊 Database Architecture

```
┌─────────────────┐         ┌──────────────────┐
│   PostgreSQL    │         │   Exported as    │
│  (Relational)   │────────▶│      JSON        │
└─────────────────┘         └──────────────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    ▼                                 ▼
         ┌──────────────────┐          ┌──────────────────┐
         │   Cassandra      │          │    MongoDB       │
         │  (Analytics-DB)  │          │  (Document-DB)   │
         └──────────────────┘          └──────────────────┘
```

---

## 🗂️ Project Files

| File | Purpose |
|------|---------|
| `schema.sql` | PostgreSQL schema definition (source) |
| `sqldata-export.sql` | Sample data exported from PostgreSQL |
| `cassandra-schema.cql` | Cassandra keyspace and table definitions |
| `exported-data.json` | Denormalized data ready for NoSQL import |
| `import_data_to_cassandra.py` | Python script for data migration |
| `docker-compose.yml` | Docker services configuration |
| `Project_Report_clean.md` | Detailed analysis and findings |

---

## 🚀 Quick Start

### Prerequisites
- ✅ Docker Desktop (https://www.docker.com/products/docker-desktop)
- ✅ Python 3.8+ (https://www.python.org/downloads/)

### Step 1: Install Dependencies
```powershell
pip install cassandra-driver
```

### Step 2: Start All Services (Automated)
```powershell
# Navigate to project directory
cd "C:\Users\gharsalli hind\Desktop\study\IGL4\s2\nosql\Nosql-migration-main\Nosql-migration-main"

# Run the startup script
.\start-project.ps1

# OR double-click start-project.bat
```

### Step 3: Manual Startup (if needed)
```powershell
# Start Docker containers
docker-compose up -d

# Wait 60+ seconds for Cassandra to be healthy

# Initialize Cassandra schema
docker exec cassandra cqlsh -f cassandra-schema.cql

# Run data migration
python import_data_to_cassandra.py
```

---

## 📈 Data Flow

### PostgreSQL (Source)
```sql
Users: user_id, name, email, city
Products: product_id, name, category, price
Orders: order_id, user_id, date
OrderItems: order_id, product_id, quantity, price
```

### Denormalized JSON (Intermediate)
```json
{
  "order_id": 1,
  "user": {
    "user_id": 1,
    "name": "John",
    "city": "NYC"
  },
  "date": "2024-01-15",
  "items": [
    {"product": "Laptop", "price": 999.99, "quantity": 1},
    {"product": "Mouse", "price": 29.99, "quantity": 2}
  ]
}
```

### Cassandra (Analytics Tables)

**orders_by_id** (Query orders by order_id)
```
order_id → user_id, user_name, user_city, date, items[]
```

**sales_by_user** (Query user spending)
```
user_id → total_orders, total_revenue, products[]
```

**sales_by_product** (Query product performance)
```
product → total_quantity, total_revenue, users[]
```

---

## 🌐 Services & Access

| Service | URL/Port | Credentials | Purpose |
|---------|----------|-------------|---------|
| **Cassandra** | localhost:9042 | - | NoSQL database |
| **OpsCenter** | http://localhost:8888 | - | Cassandra UI |
| **MongoDB** | localhost:27017 | mongoadmin:mongoadmin | Document DB |
| **Mongo Express** | http://localhost:28081 | admin:changeme | MongoDB UI |
| **PostgreSQL** | localhost:5432 | myuser:mypassword | SQL DB |

---

## 💻 Common Commands

### Docker Management
```powershell
# View all services
docker-compose ps

# View specific service logs
docker-compose logs cassandra
docker-compose logs mongo

# Stop all services
docker-compose down

# Stop and remove all data
docker-compose down -v
```

### Cassandra Commands
```powershell
# Access Cassandra shell
docker exec -it cassandra cqlsh

# Inside cqlsh shell:
use ecommerce;
select * from orders_by_id;
select * from sales_by_user;
select * from sales_by_product;
```

### MongoDB Commands
```powershell
# Access MongoDB shell
docker exec -it mongo mongosh -u mongoadmin -p mongoadmin

# Inside mongosh shell:
db.orders.find()
db.users.find()
db.products.find()
```

### PostgreSQL Commands
```powershell
# Access PostgreSQL shell
docker exec -it sqldb psql -U myuser -d projet

# Inside psql shell:
\dt              -- List tables
select * from users;
select * from orders;
```

---

## 🔍 Data Migration Process

The `import_data_to_cassandra.py` script:

1. **Connects to Cassandra**
   ```python
   cluster = Cluster(["127.0.0.1"])
   session = cluster.connect("ecommerce")
   ```

2. **Clears existing data**
   ```python
   session.execute("TRUNCATE orders_by_id")
   session.execute("TRUNCATE sales_by_user")
   session.execute("TRUNCATE sales_by_product")
   ```

3. **Loads JSON data**
   ```python
   with open("exported-data.json") as f:
       orders = json.load(f)
   ```

4. **Denormalizes data into 3 analytics tables**
   - Inserts orders into `orders_by_id`
   - Aggregates user spending into `sales_by_user`
   - Aggregates product sales into `sales_by_product`

---

## 📊 Key Concepts Demonstrated

### 1. **Denormalization**
- SQL uses normalization (1:M relationships, joins)
- Cassandra uses denormalization (aggregate data, no joins)
- MongoDB uses documents (flexible schema, embedded data)

### 2. **Query Patterns**
- SQL: Single query joins multiple tables
- Cassandra: Pre-aggregated tables for specific queries
- MongoDB: Single document contains related data

### 3. **Data Model Design**
```
SQL (Normalized):
  users → orders → order_items → products
  (Multiple joins required)

Cassandra (Denormalized):
  orders_by_id (User info embedded)
  sales_by_user (Products embedded)
  sales_by_product (Users embedded)
  (No joins, read-optimized)

MongoDB (Document):
  {
    _id: order_id,
    user: {id, name, city},
    items: [{product, price, qty}]
  }
  (Flexible, self-contained)
```

---

## 🎓 Learning Outcomes

After running this project, you'll understand:

✅ **Relational vs NoSQL** - Fundamental differences in data modeling  
✅ **Denormalization** - How to restructure normalized data  
✅ **Analytics Tables** - Pre-computed aggregations for fast queries  
✅ **Docker** - Container orchestration for services  
✅ **Python Data Migration** - Scripting for ETL processes  
✅ **Data Analysis** - Comparing query patterns across databases  

---

## 📚 Detailed Documentation

See `Project_Report_clean.md` for:
- In-depth architecture analysis
- Performance comparisons
- Migration strategies
- Use case recommendations
- Data model comparisons

---

## 🆘 Troubleshooting

### Docker services won't start
```powershell
# Verify Docker daemon is running
docker ps

# Restart Docker Desktop
# Settings > Resources > Restart
```

### Cassandra not healthy
```powershell
# Check logs
docker-compose logs cassandra

# Wait longer (can take 60+ seconds on first start)
# Try manually: docker exec cassandra cqlsh -e "describe keyspaces"
```

### "Connection refused" when running Python script
```powershell
# Ensure Cassandra is healthy first
docker-compose ps

# Verify connectivity manually
docker exec cassandra cqlsh -e "describe keyspaces"

# Give it more time and retry
```

### Port already in use
```powershell
# Find what's using the port
Get-NetTCPConnection -LocalPort 9042 -ErrorAction SilentlyContinue

# Kill the process or use different port in docker-compose.yml
```

---

## 📝 Scripts Included

| Script | Purpose |
|--------|---------|
| `start-project.ps1` | PowerShell automation script (all-in-one) |
| `start-project.bat` | Windows batch file (launches PS1) |
| `SETUP_GUIDE.md` | Comprehensive setup documentation |
| `QUICK_REFERENCE.md` | This file |

---

## ✨ Next Steps

1. ✅ Install Docker Desktop
2. ✅ Install Python
3. ✅ Run `.\start-project.ps1`
4. ✅ Access OpsCenter at http://localhost:8888
5. ✅ Access Mongo Express at http://localhost:28081
6. ✅ Query data using provided CLI commands
7. ✅ Read Project_Report_clean.md for analysis

---

## 📞 Support

- For setup issues: See SETUP_GUIDE.md
- For project details: See Project_Report_clean.md
- For Docker help: https://docs.docker.com/
- For Cassandra help: https://cassandra.apache.org/
- For MongoDB help: https://docs.mongodb.com/

---

**Created:** May 2024  
**Project Type:** Educational - SQL to NoSQL Migration  
**Duration:** Complete startup to running: ~5 minutes
