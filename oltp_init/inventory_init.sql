CREATE SCHEMA IF NOT EXISTS prod;  -- create schema to build tables upon

-- Table both for machinery and components
CREATE TABLE prod.factory_inventory (
    item_id SERIAL PRIMARY KEY,
    item_type VARCHAR(20) NOT NULL CHECK (item_type IN ('machine', 'component')),  -- apply check for two types of values
    last_upd TIMESTAMPTZ NOT NULL DEFAULT NOW(),  -- when was status updated
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,  -- deletion status
    -- machinery fields
    machine_id INTEGER,
    machine_type VARCHAR(50),  -- lathe, milling, drilling, grinding, laser_cutting, press_brake
    model VARCHAR(100),
    manufacturer VARCHAR(100),
    install_date DATE,
    location VARCHAR(100),
    status VARCHAR(20),  -- active, maintenance, decommissioned
    component_id INTEGER,
    component_name VARCHAR(100),
    component_type VARCHAR(50),  -- cutting_tool, coolant, lubricant, bearing, filter, spare_part
    machine_type_for_component VARCHAR(50),  -- for what type of machinery is used
    quantity_on_hand INTEGER,
    reorder_level INTEGER,
    unit_cost NUMERIC(12,2),
    supplier_id INTEGER,

    -- uniqueness of business keys
    CONSTRAINT uq_machine_id UNIQUE (item_type, machine_id),
    CONSTRAINT uq_component_id UNIQUE (item_type, component_id),
    -- check filling of the required fields
    CONSTRAINT chk_machine_fields CHECK (
        (item_type = 'machine' AND machine_id IS NOT NULL AND machine_type IS NOT NULL AND status IS NOT NULL)
        OR (item_type = 'component' AND component_id IS NOT NULL AND component_name IS NOT NULL AND quantity_on_hand IS NOT NULL)
    )
);

/*Create two views to extract data further:
    - v_machine_inventory - for machinery
    - v_compontents_inventory - for components
*/
CREATE OR REPLACE VIEW prod.v_machine_inventory AS
SELECT
    machine_id,
    machine_type,
    model,
    manufacturer,
    install_date,
    location,
    status,
    last_upd
FROM
    prod.factory_inventory
WHERE
    item_type = 'machine' AND is_deleted = FALSE;  -- filter by type and add flexibility to pushdown deleted elements

CREATE OR REPLACE VIEW prod.v_components_inventory AS
SELECT
    component_id,
    component_name,
    component_type,
    machine_type_for_component AS machine_type,
    quantity_on_hand,
    reorder_level,
    unit_cost,
    supplier_id,
    last_upd
FROM 
    prod.factory_inventory
WHERE
    item_type = 'component' AND is_deleted = FALSE;

-- Create trigger for last updated status
CREATE OR REPLACE FUNCTION update_last_updated_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_upd = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_factory_inventory_last_updated
BEFORE UPDATE ON prod.factory_inventory
FOR EACH ROW
EXECUTE FUNCTION update_last_updated_column()