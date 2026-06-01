-- Supply Chain Delay Analysis
-- Author: Clamencia Anthonyswamy
-- Dataset: 30 shipments across German cities, Jan-Mar 2024
-- Tool: SQLite

-- ============================================
-- CREATE TABLE
-- ============================================

CREATE TABLE shipments (
  shipment_id INTEGER PRIMARY KEY,
  shipment_date TEXT,
  delivery_date TEXT,
  expected_date TEXT,
  origin TEXT,
  destination TEXT,
  carrier TEXT,
  status TEXT,
  delay_days INTEGER,
  shipment_value REAL
);

-- ============================================
-- INSERT DATA
-- ============================================

INSERT INTO shipments VALUES
(1,'2024-01-03','2024-01-07','2024-01-05','Berlin','Munich','DHL','Delayed',2,1250.00),
(2,'2024-01-05','2024-01-08','2024-01-07','Hamburg','Berlin','DPD','On Time',0,890.00),
(3,'2024-01-08','2024-01-15','2024-01-10','Munich','Frankfurt','Hermes','Delayed',5,2100.00),
(4,'2024-01-10','2024-01-12','2024-01-12','Berlin','Hamburg','DHL','On Time',0,450.00),
(5,'2024-01-12','2024-01-18','2024-01-14','Frankfurt','Cologne','DPD','Delayed',4,3200.00),
(6,'2024-01-15','2024-01-17','2024-01-17','Cologne','Berlin','DHL','On Time',0,780.00),
(7,'2024-01-18','2024-01-25','2024-01-20','Berlin','Frankfurt','Hermes','Delayed',5,1560.00),
(8,'2024-01-20','2024-01-22','2024-01-22','Munich','Berlin','DPD','On Time',0,920.00),
(9,'2024-01-22','2024-01-28','2024-01-24','Hamburg','Munich','DHL','Delayed',4,2800.00),
(10,'2024-01-25','2024-01-27','2024-01-27','Berlin','Cologne','DPD','On Time',0,650.00),
(11,'2024-01-28','2024-02-04','2024-01-30','Frankfurt','Berlin','Hermes','Delayed',5,1900.00),
(12,'2024-02-01','2024-02-03','2024-02-03','Cologne','Hamburg','DHL','On Time',0,430.00),
(13,'2024-02-03','2024-02-09','2024-02-05','Berlin','Munich','DPD','Delayed',4,2200.00),
(14,'2024-02-06','2024-02-08','2024-02-08','Munich','Frankfurt','DHL','On Time',0,870.00),
(15,'2024-02-08','2024-02-14','2024-02-10','Hamburg','Berlin','Hermes','Delayed',4,3100.00),
(16,'2024-02-10','2024-02-12','2024-02-12','Berlin','Hamburg','DPD','On Time',0,560.00),
(17,'2024-02-12','2024-02-19','2024-02-14','Frankfurt','Munich','DHL','Delayed',5,1800.00),
(18,'2024-02-15','2024-02-17','2024-02-17','Cologne','Berlin','DPD','On Time',0,740.00),
(19,'2024-02-18','2024-02-24','2024-02-20','Munich','Cologne','Hermes','Delayed',4,2400.00),
(20,'2024-02-20','2024-02-22','2024-02-22','Berlin','Frankfurt','DHL','On Time',0,990.00),
(21,'2024-02-22','2024-03-01','2024-02-24','Hamburg','Frankfurt','DPD','Delayed',5,1650.00),
(22,'2024-02-25','2024-02-27','2024-02-27','Frankfurt','Berlin','DHL','On Time',0,820.00),
(23,'2024-02-27','2024-03-05','2024-03-01','Berlin','Cologne','Hermes','Delayed',4,2750.00),
(24,'2024-03-01','2024-03-03','2024-03-03','Munich','Hamburg','DPD','On Time',0,610.00),
(25,'2024-03-03','2024-03-09','2024-03-05','Cologne','Munich','DHL','Delayed',4,1950.00),
(26,'2024-03-05','2024-03-07','2024-03-07','Berlin','Munich','DPD','On Time',0,480.00),
(27,'2024-03-07','2024-03-14','2024-03-09','Hamburg','Cologne','Hermes','Delayed',5,2600.00),
(28,'2024-03-10','2024-03-12','2024-03-12','Frankfurt','Hamburg','DHL','On Time',0,710.00),
(29,'2024-03-12','2024-03-18','2024-03-14','Berlin','Frankfurt','DPD','Delayed',4,1850.00),
(30,'2024-03-15','2024-03-17','2024-03-17','Cologne','Frankfurt','DHL','On Time',0,530.00);

-- ============================================
-- QUERY 1: Overall Delivery Performance
-- Question: What is the overall on-time vs delayed split?
-- ============================================

SELECT 
  status,
  COUNT(*) as total_shipments,
  ROUND(COUNT(*) * 100.0 / 
    (SELECT COUNT(*) FROM shipments), 1) as percentage
FROM shipments
GROUP BY status
ORDER BY total_shipments DESC;

-- Result: 50% delayed, 50% on time

-- ============================================
-- QUERY 2: Carrier Performance
-- Question: Which carrier causes the most delays?
-- ============================================

SELECT 
  carrier,
  COUNT(*) as total_shipments,
  SUM(CASE WHEN status = 'Delayed' THEN 1 ELSE 0 END) as delayed,
  SUM(CASE WHEN status = 'On Time' THEN 1 ELSE 0 END) as on_time,
  ROUND(AVG(delay_days), 1) as avg_delay_days,
  ROUND(SUM(CASE WHEN status = 'Delayed' THEN 1 ELSE 0 END) 
    * 100.0 / COUNT(*), 1) as delay_rate_percent
FROM shipments
GROUP BY carrier
ORDER BY delay_rate_percent DESC;

-- Result: Hermes highest delay rate

-- ============================================
-- QUERY 3: Most Delayed Routes
-- Question: Which origin-destination pairs delay most?
-- ============================================

SELECT 
  origin,
  destination,
  COUNT(*) as total_shipments,
  SUM(CASE WHEN status = 'Delayed' THEN 1 ELSE 0 END) as delayed,
  ROUND(AVG(delay_days), 1) as avg_delay_days
FROM shipments
GROUP BY origin, destination
HAVING COUNT(*) > 1
ORDER BY avg_delay_days DESC;

-- Result: Berlin to Frankfurt consistently problematic

-- ============================================
-- QUERY 4: Monthly Trend
-- Question: Are delays getting better or worse?
-- ============================================

SELECT 
  SUBSTR(shipment_date, 1, 7) as month,
  COUNT(*) as total_shipments,
  SUM(CASE WHEN status = 'Delayed' THEN 1 ELSE 0 END) as delayed,
  ROUND(AVG(delay_days), 1) as avg_delay_days,
  ROUND(SUM(shipment_value), 2) as total_value
FROM shipments
GROUP BY month
ORDER BY month;

-- Result: Volume dropped in March - worth monitoring

-- ============================================
-- QUERY 5: Financial Impact of Delays
-- Question: How much money is at risk per carrier?
-- ============================================

SELECT 
  carrier,
  ROUND(SUM(CASE WHEN status = 'Delayed' 
    THEN shipment_value ELSE 0 END), 2) as delayed_value,
  ROUND(SUM(shipment_value), 2) as total_value,
  ROUND(SUM(CASE WHEN status = 'Delayed' 
    THEN shipment_value ELSE 0 END) * 100.0 
    / SUM(shipment_value), 1) as percent_value_at_risk
FROM shipments
GROUP BY carrier
ORDER BY delayed_value DESC;

-- Result: Hermes = 16410 EUR at risk
-- Recommendation: Review Hermes contract immediately
