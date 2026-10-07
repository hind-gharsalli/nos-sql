\copy (
  SELECT
    o.order_id,
    json_build_object(
      'user_id', u.user_id,
      'name', u.name,
      'city', u.city
    ) AS user,
    o.order_date,
    json_agg(
      json_build_object(
        'product', p.name,
        'price', p.price,
        'quantity', oi.quantity
      )
    ) AS items
  FROM orders o
  JOIN users u ON o.user_id = u.user_id
  JOIN order_items oi ON o.order_id = oi.order_id
  JOIN products p ON oi.product_id = p.product_id
  GROUP BY o.order_id, u.user_id, u.name, u.city, o.order_date
) TO '/home/orders.json';
