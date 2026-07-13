/*
=========================================================
PROJECT: Logistics Network Performance Analytics
DATABASE: PostgreSQL
PHASE: Business KPIs

OBJECTIVE:
Understand the overall logistics operations through
high-level KPIs before diving into business analysis.

Author : Meet Shah
=========================================================
*/

-- Customers

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    customer_type VARCHAR(50),
    credit_terms_days INTEGER,
    primary_freight_type VARCHAR(100),
    account_status VARCHAR(50),
    contract_start_date DATE,
    annual_revenue_potential BIGINT
);

-- Drivers

CREATE TABLE drivers (
    driver_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    hire_date DATE,
    termination_date DATE,
    license_number VARCHAR(50),
    license_state VARCHAR(10),
    date_of_birth DATE,
    home_terminal VARCHAR(100),
    employment_status VARCHAR(30),
    cdl_class VARCHAR(10),
    years_experience INTEGER
);

-- Trucks

CREATE TABLE trucks (
    truck_id VARCHAR(20) PRIMARY KEY,
    unit_number VARCHAR(30) NOT NULL,
    make VARCHAR(50),
    model_year INTEGER,
    vin VARCHAR(50) UNIQUE,
    acquisition_date DATE,
    acquisition_mileage INTEGER,
    fuel_type VARCHAR(30),
    tank_capacity_gallons NUMERIC(6,2),
    status VARCHAR(30),
    home_terminal VARCHAR(100)
);

-- Trailers

CREATE TABLE trailers (
    trailer_id VARCHAR(20) PRIMARY KEY,
    trailer_number VARCHAR(30) NOT NULL,
    trailer_type VARCHAR(50),
    length_feet INTEGER,
    model_year INTEGER,
    vin VARCHAR(50) UNIQUE,
    acquisition_date DATE,
    status VARCHAR(30),
    current_location VARCHAR(100)
);

-- Routes

CREATE TABLE routes (
    route_id VARCHAR(20) PRIMARY KEY,
    origin_city VARCHAR(100),
    origin_state VARCHAR(10),
    destination_city VARCHAR(100),
    destination_state VARCHAR(10),
    typical_distance_miles INTEGER,
    base_rate_per_mile NUMERIC(10,2),
    fuel_surcharge_rate NUMERIC(6,4),
    typical_transit_days INTEGER
);

-- Facilities

CREATE TABLE facilities (
    facility_id VARCHAR(20) PRIMARY KEY,
    facility_name VARCHAR(255),
    facility_type VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(20),
    latitude NUMERIC(10,6),
    longitude NUMERIC(10,6),
    dock_doors INTEGER,
    operating_hours VARCHAR(100)
);

-- Loads

CREATE TABLE loads (
    load_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    route_id VARCHAR(20),
    load_date DATE,
    load_type VARCHAR(50),
    weight_lbs INTEGER,
    pieces INTEGER,
    revenue NUMERIC(12,2),
    fuel_surcharge NUMERIC(10,2),
    accessorial_charges NUMERIC(10,2),
    load_status VARCHAR(30),
    booking_type VARCHAR(50),

    CONSTRAINT fk_load_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_load_route
        FOREIGN KEY (route_id)
        REFERENCES routes(route_id)
);

-- Trips

CREATE TABLE trips (
    trip_id VARCHAR(20) PRIMARY KEY,
    load_id VARCHAR(20),
    driver_id VARCHAR(20),
    truck_id VARCHAR(20),
    trailer_id VARCHAR(20),
    dispatch_date DATE,
    actual_distance_miles INTEGER,
    actual_duration_hours NUMERIC(6,2),
    fuel_gallons_used NUMERIC(8,2),
    average_mpg NUMERIC(5,2),
    idle_time_hours NUMERIC(5,2),
    trip_status VARCHAR(30),

    CONSTRAINT fk_trip_load
        FOREIGN KEY (load_id)
        REFERENCES loads(load_id),

    CONSTRAINT fk_trip_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id),

    CONSTRAINT fk_trip_truck
        FOREIGN KEY (truck_id)
        REFERENCES trucks(truck_id),

    CONSTRAINT fk_trip_trailer
        FOREIGN KEY (trailer_id)
        REFERENCES trailers(trailer_id)
);

-- Fuel Purchases


CREATE TABLE fuel_purchases (
    fuel_purchase_id VARCHAR(20) PRIMARY KEY,
    trip_id VARCHAR(20),
    truck_id VARCHAR(20),
    driver_id VARCHAR(20),
    purchase_date DATE,
    location_city VARCHAR(100),
    location_state VARCHAR(20),
    gallons NUMERIC(8,2),
    price_per_gallon NUMERIC(6,2),
    total_cost NUMERIC(10,2),
    fuel_card_number VARCHAR(50),

    CONSTRAINT fk_fuel_trip
        FOREIGN KEY (trip_id)
        REFERENCES trips(trip_id),

    CONSTRAINT fk_fuel_truck
        FOREIGN KEY (truck_id)
        REFERENCES trucks(truck_id),

    CONSTRAINT fk_fuel_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id)
);

-- Maintenance Records

CREATE TABLE maintenance_records (
    maintenance_id VARCHAR(20) PRIMARY KEY,
    truck_id VARCHAR(20),
    maintenance_date DATE,
    maintenance_type VARCHAR(50),
    odometer_reading INTEGER,
    labor_hours NUMERIC(5,2),
    labor_cost NUMERIC(10,2),
    parts_cost NUMERIC(10,2),
    total_cost NUMERIC(10,2),
    facility_location VARCHAR(150),
    downtime_hours NUMERIC(6,2),
    service_description TEXT,

    CONSTRAINT fk_maintenance_truck
        FOREIGN KEY (truck_id)
        REFERENCES trucks(truck_id)
);

-- Delivery Events

CREATE TABLE delivery_events (
    event_id VARCHAR(20) PRIMARY KEY,
    load_id VARCHAR(20),
    trip_id VARCHAR(20),
    event_type VARCHAR(50),
    facility_id VARCHAR(20),
    scheduled_datetime TIMESTAMP,
    actual_datetime TIMESTAMP,
    detention_minutes INTEGER,
    on_time_flag BOOLEAN,
    location_city VARCHAR(100),
    location_state VARCHAR(20),

    CONSTRAINT fk_delivery_load
        FOREIGN KEY (load_id)
        REFERENCES loads(load_id),

    CONSTRAINT fk_delivery_trip
        FOREIGN KEY (trip_id)
        REFERENCES trips(trip_id),

    CONSTRAINT fk_delivery_facility
        FOREIGN KEY (facility_id)
        REFERENCES facilities(facility_id)
);

-- Safety Incidents

CREATE TABLE safety_incidents (
    incident_id VARCHAR(20) PRIMARY KEY,
    trip_id VARCHAR(20),
    truck_id VARCHAR(20),
    driver_id VARCHAR(20),
    incident_date DATE,
    incident_type VARCHAR(50),
    location_city VARCHAR(100),
    location_state VARCHAR(20),
    at_fault_flag BOOLEAN,
    injury_flag BOOLEAN,
    vehicle_damage_cost NUMERIC(12,2),
    cargo_damage_cost NUMERIC(12,2),
    claim_amount NUMERIC(12,2),
    preventable_flag BOOLEAN,
    description TEXT,

    CONSTRAINT fk_incident_trip
        FOREIGN KEY (trip_id)
        REFERENCES trips(trip_id),

    CONSTRAINT fk_incident_truck
        FOREIGN KEY (truck_id)
        REFERENCES trucks(truck_id),

    CONSTRAINT fk_incident_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id)
);

-- Driver Monthly Metrics

CREATE TABLE driver_monthly_metrics (
    driver_id VARCHAR(20),
    month DATE,
    trips_completed INTEGER,
    total_miles INTEGER,
    total_revenue NUMERIC(12,2),
    average_mpg NUMERIC(5,2),
    total_fuel_gallons NUMERIC(10,2),
    on_time_delivery_rate NUMERIC(5,2),
    average_idle_hours NUMERIC(6,2),

    PRIMARY KEY (driver_id, month),

    CONSTRAINT fk_driver_metrics
        FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id)
);

-- Truck Utilization Metrics

CREATE TABLE truck_utilization_metrics (
    truck_id VARCHAR(20),
    month DATE,
    trips_completed INTEGER,
    total_miles INTEGER,
    total_revenue NUMERIC(12,2),
    average_mpg NUMERIC(5,2),
    maintenance_events INTEGER,
    maintenance_cost NUMERIC(12,2),
    downtime_hours NUMERIC(6,2),
    utilization_rate NUMERIC(5,2),

    PRIMARY KEY (truck_id, month),

    CONSTRAINT fk_truck_metrics
        FOREIGN KEY (truck_id)
        REFERENCES trucks(truck_id)
);


