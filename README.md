# Supply Chain Delay Analysis using SQL

I work in logistics operations in Berlin. Every day I monitor 
shipments, track delays and investigate why deliveries go wrong.

One question kept coming up: which carriers are actually causing 
the most problems — and what is it costing?

This project is my attempt to answer that properly using SQL.

---

## The Question I Wanted to Answer

- Which carriers delay the most?
- Which routes are the biggest problem?
- How much money is actually at risk because of delays?
- Is it getting better or worse over time?

---

## The Dataset

I created a realistic logistics dataset based on my experience 
working with shipment data. It covers 30 shipments over 3 months 
across German cities — Berlin, Munich, Hamburg, Frankfurt 
and Cologne — using three carriers: DHL, DPD and Hermes.

Columns: shipment_id, shipment_date, delivery_date, 
expected_date, origin, destination, carrier, status, 
delay_days, shipment_value

---

## Tools

- SQL — SQLite
- SQLite Online IDE

---

## What I Found

**Half of all shipments were delayed.**

That was the first thing that stood out. 50% delay rate across 
30 shipments is not a small problem.

**Hermes is the biggest risk.**

Hermes had €16,410 worth of delayed shipments. For a carrier 
handling only 7 shipments total — that number is alarming. 
If I were presenting this to a manager, Hermes is the first 
conversation I would be having.

**Berlin to Frankfurt is the most problematic route.**

Consistently delayed across multiple carriers. Something about 
that route is not working — whether it's distance, handover 
points or carrier capacity.

**March volume dropped.**

January had 11 shipments, February had 12, March dropped to 7. 
Could be seasonal. Could be something else. Worth watching.

---

## The SQL Queries

### 1 — Overall delivery performance

```sql
SELECT 
  status,
  COUNT(*) as total_shipments,
  ROUND(COUNT(*) * 100.0 / 
    (SELECT COUNT(*) FROM shipments), 1) as percentage
FROM shipments
GROUP BY status
ORDER BY total_shipments DESC;
```

What this tells me: the overall split between on time 
and delayed shipments.

---

### 2 — Carrier performance

```sql
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
```

What this tells me: which carrier to be worried about.

---

### 3 — Most delayed routes

```sql
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
```

What this tells me: where the route problems are.

---

### 4 — Monthly trend

```sql
SELECT 
  SUBSTR(shipment_date, 1, 7) as month,
  COUNT(*) as total_shipments,
  SUM(CASE WHEN status = 'Delayed' THEN 1 ELSE 0 END) as delayed,
  ROUND(AVG(delay_days), 1) as avg_delay_days,
  ROUND(SUM(shipment_value), 2) as total_value
FROM shipments
GROUP BY month
ORDER BY month;
```

What this tells me: whether things are improving 
or getting worse over time.

---

### 5 — Financial impact of delays

```sql
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
```

What this tells me: the actual money at risk — 
not just the count of delays.

---

## If I Were Presenting This

Three things I would flag immediately:

1. Review the Hermes contract — €16,410 at risk is too high
2. Investigate the Berlin to Frankfurt route specifically
3. Keep an eye on the March volume drop

---

## About This Project

Built by Clamencia Anthonyswamy — Data Analyst based in Berlin.

I built this project to practice SQL analysis on a domain 
I know well from my day job. The dataset is simulated but 
the business problems are real.

[LinkedIn](https://linkedin.com/in/clamenciaanthonyswamy)
