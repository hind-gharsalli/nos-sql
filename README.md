\# SQL to NoSQL Migration Project



An educational data migration project demonstrating how relational e-commerce data can be transformed from a \*\*PostgreSQL\*\* model into NoSQL-oriented structures using \*\*Apache Cassandra\*\* and \*\*MongoDB\*\*.



The project focuses on data modeling, denormalization, ETL concepts, analytics-oriented schemas, and the differences between relational and NoSQL databases.



\## Project Overview



The original data is modeled in PostgreSQL using a normalized relational schema composed of:



\- Users

\- Products

\- Orders

\- Order items



The data is then transformed into a denormalized JSON representation suitable for NoSQL databases.



The project uses:



\- \*\*PostgreSQL\*\* as the relational source database

\- \*\*JSON\*\* as the intermediate data format

\- \*\*Apache Cassandra\*\* for query-oriented and pre-aggregated analytics tables

\- \*\*MongoDB\*\* as a document-oriented NoSQL environment

\- \*\*Python\*\* for importing and transforming data

\- \*\*Docker Compose\*\* for running all database services



\## Architecture



```text

PostgreSQL

(Relational Model)

&#x20;     |

&#x20;     | SQL joins + JSON transformation

&#x20;     v

exported-data.json

(Denormalized Data)

&#x20;     |

&#x20;     +----------------------+

&#x20;     |                      |

&#x20;     v                      v

&#x20;Apache Cassandra          MongoDB

&#x20;Analytics Model        Document Model

```



The relational model requires joins between several tables, while the NoSQL models reorganize the data according to the queries that need to be performed.



\## PostgreSQL Model



The source relational database contains four main tables:



```text

users

&#x20;└── user\_id

&#x20;└── name

&#x20;└── email

&#x20;└── city



products

&#x20;└── product\_id

&#x20;└── name

&#x20;└── category

&#x20;└── price



orders

&#x20;└── order\_id

&#x20;└── user\_id

&#x20;└── order\_date



order\_items

&#x20;└── order\_item\_id

&#x20;└── order\_id

&#x20;└── product\_id

&#x20;└── quantity

```



Relations between these tables are managed through primary and foreign keys.



The schema is defined in:



```text

schema.sql

```



The SQL export query in `sqldata-export.sql` joins the relational tables and creates a document-oriented representation of each order.



\## JSON Transformation



After transformation, an order has the following structure:



```json

{

&#x20; "order\_id": 1,

&#x20; "user": {

&#x20;   "user\_id": 1,

&#x20;   "name": "Alice",

&#x20;   "city": "Paris"

&#x20; },

&#x20; "date": "2024-01-10",

&#x20; "items": \[

&#x20;   {

&#x20;     "product": "Laptop",

&#x20;     "price": 1200.00,

&#x20;     "quantity": 1

&#x20;   },

&#x20;   {

&#x20;     "product": "Headphones",

&#x20;     "price": 150.00,

&#x20;     "quantity": 2

&#x20;   }

&#x20; ]

}

```



This representation removes the need to reconstruct an order through multiple joins and is better suited to document and NoSQL data models.



The sample transformed dataset is available in:



```text

exported-data.json

```



\## Cassandra Data Model



The Cassandra database uses the keyspace:



```text

ecommerce

```



Instead of reproducing the relational structure, Cassandra tables are designed according to specific query patterns.



\### `orders\_by\_id`



Stores complete order information.



```text

order\_id

user\_id

user\_name

user\_city

date

items

```



It allows an order and its related information to be retrieved directly without joins.



\### `sales\_by\_user`



Stores aggregated information for each user.



```text

user\_id

user\_name

total\_orders

total\_revenue

products

```



It is designed for queries such as:



> How many orders has a user placed and how much revenue did they generate?



\### `sales\_by\_product`



Stores aggregated sales information by product.



```text

product

total\_quantity

total\_revenue

users

```



It supports queries such as:



> How many units of a product were sold and which users purchased it?



The complete Cassandra schema is defined in:



```text

cassandra-schema.cql

```



\## Data Migration



The migration to Cassandra is implemented in:



```text

import\_data\_to\_cassandra.py

```



The script performs the following steps:



1\. Connects to the Cassandra cluster.

2\. Opens the `ecommerce` keyspace.

3\. Clears existing data from the target tables.

4\. Reads `exported-data.json`.

5\. Inserts individual orders into `orders\_by\_id`.

6\. Calculates total orders and revenue for each user.

7\. Calculates quantities and revenue for each product.

8\. Stores the aggregated results in `sales\_by\_user` and `sales\_by\_product`.



This demonstrates an important NoSQL principle: \*\*data is modeled according to access patterns rather than normalized entities\*\*.



\## MongoDB



MongoDB is also included in the Docker environment to demonstrate a document-oriented NoSQL database.



The JSON representation used by this project naturally maps to MongoDB documents because related user and product information can be embedded inside an order document.



Mongo Express is included as a graphical interface for exploring MongoDB.



\## Technologies



| Technology | Purpose |

|---|---|

| PostgreSQL 16 | Relational source database |

| Apache Cassandra | Column-oriented NoSQL database |

| MongoDB | Document-oriented NoSQL database |

| Python | Data migration and transformation |

| Cassandra Python Driver | Cassandra connectivity |

| JSON | Intermediate denormalized data format |

| Docker | Containerized database environment |

| Docker Compose | Multi-container orchestration |

| Mongo Express | MongoDB web interface |

| DataStax OpsCenter | Cassandra monitoring interface |

| PowerShell | Project automation |



\## Project Structure



```text

nos-sql/

│

├── README.md

│

└── Nosql-migration-main/

&#x20;   └── Nosql-migration-main/

&#x20;       │

&#x20;       ├── schema.sql

&#x20;       ├── sqldata-export.sql

&#x20;       ├── exported-data.json

&#x20;       │

&#x20;       ├── cassandra-schema.cql

&#x20;       ├── import\_data\_to\_cassandra.py

&#x20;       │

&#x20;       ├── docker-compose.yml

&#x20;       │

&#x20;       ├── start-project.ps1

&#x20;       ├── start-project.bat

&#x20;       ├── diagnose.ps1

&#x20;       │

&#x20;       ├── SETUP\_GUIDE.md

&#x20;       ├── SETUP\_SUMMARY.md

&#x20;       ├── QUICK\_REFERENCE.md

&#x20;       │

&#x20;       ├── rapport\_nosql.pdf

&#x20;       │

&#x20;       └── screenshots/

```



\## Prerequisites



To run the project, the following software is required:



\- Docker Desktop

\- Python 3.8+

\- pip



Install the Python dependencies with:



```bash

pip install cassandra-driver gevent

```



`gevent` is used by the migration script for compatibility with recent Python versions.



\## Running the Project



After cloning the repository:



```bash

git clone https://github.com/hind-gharsalli/nos-sql.git

```



Move to the project directory:



```powershell

cd nos-sql\\Nosql-migration-main\\Nosql-migration-main

```



Make sure Docker Desktop is running.



\### Automated startup



On Windows, the easiest way to start the environment is:



```powershell

.\\start-project.ps1

```



The script:



\- checks Docker

\- checks Python

\- starts the Docker containers

\- waits for Cassandra

\- initializes the Cassandra schema

\- runs the Cassandra data migration

\- displays the available services



Alternatively:



```powershell

.\\start-project.bat

```



\## Running Manually



Start the containers:



```powershell

docker-compose up -d

```



Check their status:



```powershell

docker-compose ps

```



Wait until Cassandra is ready:



```powershell

docker exec cassandra cqlsh -e "describe keyspaces"

```



Initialize the Cassandra schema from PowerShell:



```powershell

$schema = Get-Content ".\\cassandra-schema.cql" -Raw

docker exec cassandra cqlsh -e "$schema"

```



Run the migration:



```powershell

python import\_data\_to\_cassandra.py

```



A successful migration ends with:



```text

Data import completed successfully.

```



\## Available Services



| Service | Address |

|---|---|

| Cassandra | `localhost:9042` |

| OpsCenter | `http://localhost:8888` |

| MongoDB | `localhost:27017` |

| Mongo Express | `http://localhost:28081` |

| PostgreSQL | `localhost:5432` |



\### Development credentials



PostgreSQL:



```text

Database: projet

Username: myuser

Password: mypassword

```



MongoDB:



```text

Username: mongoadmin

Password: mongoadmin

```



Mongo Express:



```text

Username: admin

Password: changeme

```



These credentials are intended for the local educational Docker environment only.



\## Querying Cassandra



Open the Cassandra shell:



```powershell

docker exec -it cassandra cqlsh

```



Select the keyspace:



```sql

USE ecommerce;

```



View migrated orders:



```sql

SELECT \* FROM orders\_by\_id;

```



View analytics by user:



```sql

SELECT \* FROM sales\_by\_user;

```



View analytics by product:



```sql

SELECT \* FROM sales\_by\_product;

```



\## Docker Commands



Check running services:



```powershell

docker-compose ps

```



View logs:



```powershell

docker-compose logs -f

```



View Cassandra logs:



```powershell

docker-compose logs -f cassandra

```



Stop the project:



```powershell

docker-compose down

```



Remove the containers and stored volumes:



```powershell

docker-compose down -v

```



> `docker-compose down -v` removes the persisted database data stored in Docker volumes.



\## Main Concepts Demonstrated



\### Relational normalization



PostgreSQL separates entities into related tables and uses foreign keys to maintain relationships.



\### Denormalization



NoSQL systems often duplicate or embed information to optimize reads and avoid expensive joins.



\### Query-oriented modeling



The Cassandra schema is designed around the queries that the application needs to perform rather than around relational entities.



\### Pre-aggregation



Values such as:



```text

total\_orders

total\_revenue

total\_quantity

```



are calculated during the migration and stored directly in Cassandra.



This makes analytical queries simpler and faster.



\### ETL



The project illustrates an ETL-style workflow:



```text

Extract

PostgreSQL relational data



&#x20;       ↓



Transform

Join and denormalize the data into JSON



&#x20;       ↓



Load

Import and aggregate the data in Cassandra

```



\## Example: Relational vs NoSQL Query



In a relational model, calculating revenue by user requires joining several tables:



```sql

SELECT

&#x20;   u.user\_id,

&#x20;   u.name,

&#x20;   COUNT(DISTINCT o.order\_id) AS total\_orders,

&#x20;   SUM(oi.quantity \* p.price) AS total\_revenue

FROM users u

JOIN orders o

&#x20;   ON u.user\_id = o.user\_id

JOIN order\_items oi

&#x20;   ON o.order\_id = oi.order\_id

JOIN products p

&#x20;   ON oi.product\_id = p.product\_id

GROUP BY u.user\_id, u.name;

```



In Cassandra, this information is already stored in a query-specific table:



```sql

SELECT user\_id, user\_name, total\_orders, total\_revenue

FROM sales\_by\_user

WHERE user\_id = 1;

```



This illustrates the difference between \*\*computing relationships at query time\*\* and \*\*preparing data according to expected access patterns\*\*.



\## Diagnostics



A PowerShell diagnostic script is included:



```powershell

.\\diagnose.ps1

```



It can be used to check the local environment and required project components.



Additional documentation is available in:



\- `SETUP\_GUIDE.md`

\- `SETUP\_SUMMARY.md`

\- `QUICK\_REFERENCE.md`

\- `rapport\_nosql.pdf`



\## Purpose



This project was developed as an educational NoSQL project to explore:



\- SQL-to-NoSQL migration

\- relational and non-relational data modeling

\- Cassandra query-oriented schemas

\- MongoDB document modeling

\- denormalization

\- data aggregation

\- ETL workflows

\- containerized database environments with Docker



\## Author



\*\*Hind Gharsalli\*\*



Software Engineering student.

