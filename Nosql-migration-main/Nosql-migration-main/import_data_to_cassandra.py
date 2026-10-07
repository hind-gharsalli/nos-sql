import json

# Python 3.12 removed asyncore, so ensure cassandra-driver can use gevent reactor.
from gevent import monkey
monkey.patch_all()

from cassandra.cluster import Cluster

# Connect to Cassandra
cluster = Cluster(["127.0.0.1"])
session = cluster.connect("ecommerce")

# Clear all tables before import
session.execute("TRUNCATE orders_by_id")
session.execute("TRUNCATE sales_by_user")
session.execute("TRUNCATE sales_by_product")

# Load JSON data
with open("exported-data.json") as f:
    orders = json.load(f)

# Prepare statements
insert_order_stmt = session.prepare(
    """
INSERT INTO orders_by_id (order_id, user_id, user_name, user_city, date, items)
VALUES (?, ?, ?, ?, ?, ?)
"""
)

update_user_stmt = session.prepare(
    """
UPDATE sales_by_user
SET total_orders = ?,
    total_revenue = ?,
    products = ?
WHERE user_id = ?
"""
)

update_product_stmt = session.prepare(
    """
UPDATE sales_by_product
SET total_quantity = ?,
    total_revenue = ?,
    users = ?
WHERE product = ?
"""
)

for order in orders:
    user = order["user"]
    items = order["items"]

    # 1. Insert into orders_by_id
    item_list = [tuple([i["product"], i["price"], i["quantity"]]) for i in items]
    session.execute(
        insert_order_stmt,
        (
            order["order_id"],
            user["user_id"],
            user["name"],
            user["city"],
            order["date"],
            item_list,
        ),
    )

    # 2. Update sales_by_user
    row = session.execute(
        "SELECT total_orders, total_revenue, products FROM sales_by_user WHERE user_id=%s",
        (user["user_id"],),
    ).one()

    products_set = {(i["product"], i["price"], i["quantity"]) for i in items}
    total_revenue_order = sum(i["price"] * i["quantity"] for i in items)

    if row:
        total_orders = row.total_orders + 1
        total_revenue = row.total_revenue + total_revenue_order
        products_set = row.products.union(products_set)
    else:
        total_orders = 1
        total_revenue = total_revenue_order

    session.execute(
        update_user_stmt, (total_orders, total_revenue, products_set, user["user_id"])
    )

    # 3. Update sales_by_product
    for i in items:
        row = session.execute(
            "SELECT total_quantity, total_revenue, users FROM sales_by_product WHERE product=%s",
            (i["product"],),
        ).one()

        users_set = {(user["user_id"], user["name"], user["city"])}
        if row:
            total_quantity = row.total_quantity + i["quantity"]
            total_revenue = row.total_revenue + i["price"] * i["quantity"]
            users_set = row.users.union(users_set)
        else:
            total_quantity = i["quantity"]
            total_revenue = i["price"] * i["quantity"]

        session.execute(
            update_product_stmt,
            (total_quantity, total_revenue, users_set, i["product"]),
        )

cluster.shutdown()
print("Data import completed successfully.")
