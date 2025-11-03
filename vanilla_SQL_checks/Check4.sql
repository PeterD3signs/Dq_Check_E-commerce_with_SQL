-- Vanilla SQL solution for Check 4:

WITH total_rows AS (
    SELECT COUNT(*) AS cnt FROM sales
)

SELECT 'Critical' AS category,
       COUNT(*) AS row_count,
       CASE WHEN (SELECT cnt FROM total_rows) = 0 THEN '0%'
            ELSE ROUND(COUNT(*)::NUMERIC / (SELECT cnt FROM total_rows) * 100, 2)::TEXT || '%'
       END AS percentage
FROM sales
WHERE
    "InvoiceNo" IS NULL
    OR "StockCode" IS NULL
    OR "Quantity" IS NULL
    OR "InvoiceDate" IS NULL
    OR "UnitPrice" IS NULL
    OR ("InvoiceNo" ~ '^\d+$' AND CAST("InvoiceNo" AS NUMERIC) < 0)
    OR ("CustomerID" IS NOT NULL AND "CustomerID" < 0)
    OR "UnitPrice" < 0
    OR "InvoiceDate" < TIMESTAMP '2010-01-01 00:00:00'
    OR "InvoiceDate" > NOW()
-- Important:
-- NULL OR TRUE == TRUE OR NULL => TRUE;
-- FALSE AND NULL == NULL AND FALSE => FALSE;
UNION ALL

SELECT 'Warning' AS category,
       COUNT(*) AS row_count,
       CASE WHEN (SELECT cnt FROM total_rows) = 0 THEN '0%'
            ELSE ROUND(COUNT(*)::NUMERIC / (SELECT cnt FROM total_rows) * 100, 2)::TEXT || '%'
       END AS percentage
FROM sales
WHERE NOT (
        "InvoiceNo" IS NULL
        OR "StockCode" IS NULL
        OR "Quantity" IS NULL
        OR "InvoiceDate" IS NULL
        OR "UnitPrice" IS NULL
        OR ("InvoiceNo" ~ '^\d+$' AND CAST("InvoiceNo" AS NUMERIC) < 0)
        OR ("CustomerID" IS NOT NULL AND "CustomerID" < 0)
        OR "UnitPrice" < 0
        OR "InvoiceDate" < TIMESTAMP '2010-01-01 00:00:00'
        OR "InvoiceDate" > NOW()
    )
  AND (
        "Country" IS NULL
     OR "CustomerID" IS NULL
     OR "Description" IS NULL
     OR "Quantity" < -5000 OR "Quantity" > 5000
     OR "UnitPrice" > 10000
     OR "Country" NOT IN (SELECT country_name FROM CountriesWeShipTo)
    )

UNION ALL

SELECT 'Any Missing' AS category,
       COUNT(*) AS row_count,
       CASE WHEN (SELECT cnt FROM total_rows) = 0 THEN '0%'
            ELSE ROUND(COUNT(*)::NUMERIC / (SELECT cnt FROM total_rows) * 100, 2)::TEXT || '%'
       END AS percentage
FROM sales
WHERE
    "InvoiceNo" IS NULL
    OR "StockCode" IS NULL
    OR "Quantity" IS NULL
    OR "InvoiceDate" IS NULL
    OR "UnitPrice" IS NULL
    OR "Country" IS NULL
    OR "CustomerID" IS NULL
    OR "Description" IS NULL

UNION ALL

SELECT 'Any Wrong' AS category,
       COUNT(*) AS row_count,
       CASE WHEN (SELECT cnt FROM total_rows) = 0 THEN '0%'
            ELSE ROUND(COUNT(*)::NUMERIC / (SELECT cnt FROM total_rows) * 100, 2)::TEXT || '%'
       END AS percentage
FROM sales
WHERE
    ("InvoiceNo" ~ '^\d+$' AND CAST("InvoiceNo" AS NUMERIC) < 0)
    OR ("CustomerID" IS NOT NULL AND "CustomerID" < 0)
    OR "Quantity" < -5000 OR "Quantity" > 5000
    OR "UnitPrice" < 0 OR "UnitPrice" > 10000
    OR "InvoiceDate" < TIMESTAMP '2010-01-01 00:00:00' OR "InvoiceDate" > NOW()
    OR "Country" NOT IN (SELECT country_name FROM CountriesWeShipTo)

UNION ALL

SELECT 'Fully OK' AS category,
       COUNT(*) AS row_count,
       CASE WHEN (SELECT COUNT(*) FROM sales) = 0 THEN '0%'
            ELSE ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM sales) * 100, 2)::TEXT || '%'
       END AS percentage
FROM (
    SELECT *
    FROM sales
    WHERE "InvoiceNo" IS NOT NULL
      AND "StockCode" IS NOT NULL
      AND "Quantity" IS NOT NULL
      AND "InvoiceDate" IS NOT NULL
      AND "UnitPrice" IS NOT NULL
      AND "CustomerID" IS NOT NULL
      AND "Country" IS NOT NULL
      AND "Description" IS NOT NULL
) AS t
WHERE
    ("InvoiceNo" !~ '^\d+$' OR CAST("InvoiceNo" AS NUMERIC) >= 0)
    AND "CustomerID" >= 0
    AND "Quantity" >= -5000 AND "Quantity" <= 5000
    AND "InvoiceDate" >= TIMESTAMP '2010-01-01 00:00:00' AND "InvoiceDate" <= NOW()
    AND "UnitPrice" >= 0 AND "UnitPrice" <= 10000
    AND "Country" IN (SELECT country_name FROM CountriesWeShipTo);
