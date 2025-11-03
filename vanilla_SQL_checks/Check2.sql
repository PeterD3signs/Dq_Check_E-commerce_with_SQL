-- Vanilla SQL solution for Check 2:

-- IMPORTANT NOTES:
-- 1. values are hard coded, no aruments possible in vanilla SQL
-- 2. hard coded values in accordance with args passed with a procedure call for PostgreSQL Check 2.

-- Individual wrong value counts
SELECT 'InvoiceNo' AS "Column Name", COUNT(*) AS "Number of Wrong Entries",
       CASE WHEN COUNT(*) > 0 THEN 'Critical' ELSE 'All Ok' END AS "Severity"
FROM sales
WHERE "InvoiceNo" ~ '^\d+$' AND CAST("InvoiceNo" AS NUMERIC) < 0
UNION ALL
SELECT 'CustomerID', COUNT(*),
       CASE WHEN COUNT(*) > 0 THEN 'Critical' ELSE 'All Ok' END
FROM sales
WHERE "CustomerID" < 0
UNION ALL
SELECT 'Quantity', COUNT(*),
       CASE WHEN COUNT(*) > 0 THEN 'Warning' ELSE 'All Ok' END
FROM sales
WHERE "Quantity" < -5000 OR "Quantity" > 5000
UNION ALL
SELECT 'UnitPrice (Negative)', COUNT(*),
       CASE WHEN COUNT(*) > 0 THEN 'Critical' ELSE 'All Ok' END
FROM sales
WHERE "UnitPrice" < 0
UNION ALL
SELECT 'UnitPrice (Too High)', COUNT(*),
       CASE WHEN COUNT(*) > 0 THEN 'Warning' ELSE 'All Ok' END
FROM sales
WHERE "UnitPrice" > 10000
UNION ALL
SELECT 'InvoiceDate', COUNT(*),
       CASE WHEN COUNT(*) > 0 THEN 'Critical' ELSE 'All Ok' END
FROM sales
WHERE "InvoiceDate" < TIMESTAMP '2010-01-01 00:00:00' OR "InvoiceDate" > NOW()
UNION ALL
SELECT 'Country', COUNT(*),
       CASE WHEN COUNT(*) > 0 THEN 'Warning' ELSE 'All Ok' END
FROM sales
WHERE "Country" NOT IN (SELECT country_name FROM CountriesWeShipTo)
-- Totals per severity (sum of column-level counts)
UNION ALL
SELECT 'Total (Critical)',
       (
         (SELECT COUNT(*) FROM sales WHERE "InvoiceNo" ~ '^\d+$' AND CAST("InvoiceNo" AS NUMERIC) < 0) +
         (SELECT COUNT(*) FROM sales WHERE "CustomerID" < 0) +
         (SELECT COUNT(*) FROM sales WHERE "UnitPrice" < 0) +
         (SELECT COUNT(*) FROM sales WHERE "InvoiceDate" < TIMESTAMP '2010-01-01 00:00:00') +
         (SELECT COUNT(*) FROM sales WHERE "InvoiceDate" > NOW())
       ) AS "Number of Wrong Entries",
       CASE WHEN 
         (
           (SELECT COUNT(*) FROM sales WHERE "InvoiceNo" ~ '^\d+$' AND CAST("InvoiceNo" AS NUMERIC) < 0) +
           (SELECT COUNT(*) FROM sales WHERE "CustomerID" < 0) +
           (SELECT COUNT(*) FROM sales WHERE "UnitPrice" < 0) +
           (SELECT COUNT(*) FROM sales WHERE "InvoiceDate" < TIMESTAMP '2010-01-01 00:00:00') +
           (SELECT COUNT(*) FROM sales WHERE "InvoiceDate" > NOW())
         ) > 0 THEN 'Critical' ELSE 'All Ok' END
UNION ALL
SELECT 'Total (Warning)',
       (
         (SELECT COUNT(*) FROM sales WHERE "Quantity" < -5000 OR "Quantity" > 5000) +
         (SELECT COUNT(*) FROM sales WHERE "UnitPrice" > 10000) +
         (SELECT COUNT(*) FROM sales WHERE "Country" NOT IN (SELECT country_name FROM CountriesWeShipTo))
       ),
       CASE WHEN 
         (
           (SELECT COUNT(*) FROM sales WHERE "Quantity" < -5000 OR "Quantity" > 5000) +
           (SELECT COUNT(*) FROM sales WHERE "UnitPrice" > 10000) +
           (SELECT COUNT(*) FROM sales WHERE "Country" NOT IN (SELECT country_name FROM CountriesWeShipTo))
         ) > 0 THEN 'Warning' ELSE 'All Ok' END
-- Totals for unique rows (row-level, counting each affected row once)
UNION ALL
SELECT 'Total Unique (Critical)',
       COUNT(*),
       CASE WHEN COUNT(*) > 0 THEN 'Critical' ELSE 'All Ok' END
FROM sales
WHERE ("InvoiceNo" ~ '^\d+$' AND CAST("InvoiceNo" AS NUMERIC) < 0)
   OR "CustomerID" < 0
   OR "UnitPrice" < 0
   OR "InvoiceDate" < TIMESTAMP '2010-01-01 00:00:00'
   OR "InvoiceDate" > NOW()
UNION ALL
SELECT 'Total Unique (Warning)',
       COUNT(*),
       CASE WHEN COUNT(*) > 0 THEN 'Warning' ELSE 'All Ok' END
FROM sales s
WHERE NOT (
        ("InvoiceNo" ~ '^\d+$' AND CAST("InvoiceNo" AS NUMERIC) < 0)
     OR ("CustomerID" IS NOT NULL AND "CustomerID" < 0)
     OR "UnitPrice" < 0
     OR "InvoiceDate" < TIMESTAMP '2010-01-01 00:00:00'
     OR "InvoiceDate" > NOW()
    )
  AND (
        "Quantity" < -5000 OR "Quantity" > 5000
     OR "UnitPrice" > 10000
     OR "Country" NOT IN (SELECT country_name FROM CountriesWeShipTo)
    );