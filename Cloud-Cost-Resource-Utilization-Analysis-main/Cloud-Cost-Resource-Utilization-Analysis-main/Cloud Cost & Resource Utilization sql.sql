DROP DATABASE IF EXISTS cloud_costs;
CREATE DATABASE cloud_costs;
USE cloud_costs;

CREATE TABLE billing_data (
    resource_id VARCHAR(50),
    service_name VARCHAR(100),
    usage_quantity DECIMAL(15,4),
    usage_unit VARCHAR(50),
    region_zone VARCHAR(50),
    cpu_utilization DECIMAL(5,2),
    memory_utilization DECIMAL(5,2),
    network_inbound BIGINT,
    network_outbound BIGINT,
    usage_start DATETIME,
    usage_end DATETIME,
    cost_per_quantity DECIMAL(15,4),
    unrounded_cost DECIMAL(15,4),
    rounded_cost DECIMAL(15,4),
    total_cost_inr DECIMAL(15,2)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/hp/Documents/cloud_costs.csv'
INTO TABLE billing_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(resource_id, service_name, usage_quantity, usage_unit, region_zone, cpu_utilization,
 memory_utilization, network_inbound, network_outbound,  
 @usage_start, @usage_end, cost_per_quantity, unrounded_cost, rounded_cost, total_cost_inr)
SET  
 usage_start = STR_TO_DATE(@usage_start, '%d-%m-%Y %H:%i'),
 usage_end   = STR_TO_DATE(@usage_end, '%d-%m-%Y %H:%i');
SELECT * 
FROM billing_data 
LIMIT 10;

SELECT COUNT(*) AS total_rows 
FROM billing_data;

SELECT DISTINCT service_name 
FROM billing_data;

SELECT SUM(total_cost_inr) AS total_cost_inr 
FROM billing_data;

SELECT MIN(usage_start) AS first_usage, 
       MAX(usage_end) AS last_usage
FROM billing_data;

SELECT AVG(cpu_utilization) AS avg_cpu,
       AVG(memory_utilization) AS avg_memory
FROM billing_data;
SELECT service_name, 
       SUM(total_cost_inr) AS total_service_cost
FROM billing_data
GROUP BY service_name
ORDER BY total_service_cost DESC
LIMIT 5;
SELECT region_zone, 
       SUM(total_cost_inr) AS total_region_cost
FROM billing_data
GROUP BY region_zone
ORDER BY total_region_cost DESC;
SELECT DATE_FORMAT(usage_start, '%Y-%m') AS month,
       SUM(total_cost_inr) AS monthly_cost
FROM billing_data
GROUP BY month
ORDER BY month;
SELECT resource_id, service_name, region_zone,
       cpu_utilization, memory_utilization,
       total_cost_inr
FROM billing_data
WHERE cpu_utilization < 50
ORDER BY total_cost_inr DESC
LIMIT 10;
SELECT resource_id, service_name, region_zone,
       network_inbound, network_outbound,
       total_cost_inr
FROM billing_data
ORDER BY (network_inbound + network_outbound) DESC
LIMIT 10;
SELECT resource_id, service_name, region_zone,
       SUM(total_cost_inr) AS total_resource_cost
FROM billing_data
GROUP BY resource_id, service_name, region_zone
ORDER BY total_resource_cost DESC
LIMIT 10;
SELECT resource_id, service_name, region_zone,
       AVG(cpu_utilization) AS avg_cpu,
       AVG(memory_utilization) AS avg_memory,
       SUM(total_cost_inr) AS total_cost
FROM billing_data
GROUP BY resource_id, service_name, region_zone
HAVING (avg_cpu < 40 OR avg_memory < 40)
ORDER BY total_cost DESC
LIMIT 10;
SELECT resource_id, service_name, region_zone,
       SUM(total_cost_inr) / NULLIF(AVG(cpu_utilization), 0) AS cost_per_cpu_unit
FROM billing_data
GROUP BY resource_id, service_name, region_zone
ORDER BY cost_per_cpu_unit DESC
LIMIT 10;
SELECT resource_id, service_name, region_zone,
       SUM(total_cost_inr) / NULLIF(AVG(memory_utilization), 0) AS cost_per_memory_unit
FROM billing_data
GROUP BY resource_id, service_name, region_zone
ORDER BY cost_per_memory_unit DESC
LIMIT 10;
SELECT DATE(usage_start) AS usage_day,
       SUM(total_cost_inr) AS daily_cost
FROM billing_data
GROUP BY usage_day
ORDER BY daily_cost DESC
LIMIT 10;
