CREATE SCHEMA IF NOT EXISTS prod;  -- create schema to build tables upon

CREATE TABLE prod.sales_orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    product_name VARCHAR(50) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    order_date DATE NOT NULL,
    delivery_date DATE,
    status VARCHAR(50) NOT NULL CHECK (status IN ('completed', 'pending', 'cancelled')),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes to make queries faster
CREATE INDEX idx_sales_orders_order_date ON prod.sales_orders(order_date);
CREATE INDEX idx_sales_orders_customer_id ON prod.sales_orders(customer_id);
CREATE INDEX idx_sales_orders_product_id ON prod.sales_orders(product_id);
CREATE INDEX idx_sales_orders_updated_at ON prod.sales_orders(updated_at);

-- Trigger to automatically update updated_at using UPDATE
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sales_orders_updated_at
BEFORE UPDATE ON prod.sales_orders
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
