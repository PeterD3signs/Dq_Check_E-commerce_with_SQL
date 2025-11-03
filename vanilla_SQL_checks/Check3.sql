-- Vanilla SQL solution for Check 3:

WITH total_rows AS (
    SELECT COUNT(*) AS cnt FROM sales
),

-- InvoiceNo with multiple dates (Critical)
multi_date AS (
    SELECT COUNT(*) AS cnt
    FROM (
        SELECT "InvoiceNo"
        FROM sales
        GROUP BY "InvoiceNo"
        HAVING COUNT(DISTINCT "InvoiceDate") > 1
    ) t
),

-- Fully identical rows (Warning)
fully_identical AS (
    SELECT COUNT(*) AS cnt
    FROM (
        SELECT "InvoiceNo", "StockCode", "Description", "Quantity", "InvoiceDate", "UnitPrice", "CustomerID", "Country"
        FROM sales
        GROUP BY "InvoiceNo", "StockCode", "Description", "Quantity", "InvoiceDate", "UnitPrice", "CustomerID", "Country"
        HAVING COUNT(*) > 1
    ) t
)

SELECT 'InvoiceNo with Multiple Dates' AS "Potential problem",
       multi_date.cnt AS "Number of Duplicates",
       CASE WHEN total_rows.cnt = 0 THEN '0%' 
            ELSE ROUND((multi_date.cnt::NUMERIC / total_rows.cnt) * 100, 2)::TEXT || '%' 
       END AS "Percentage of affected data",
       CASE WHEN multi_date.cnt = 0 THEN 'All OK' ELSE 'Critical' END AS "Severity"
FROM multi_date, total_rows

UNION ALL

SELECT 'Fully Identical Rows' AS "Potential problem",
       fully_identical.cnt AS "Number of Duplicates",
       CASE WHEN total_rows.cnt = 0 THEN '0%' 
            ELSE ROUND((fully_identical.cnt::NUMERIC / total_rows.cnt) * 100, 2)::TEXT || '%' 
       END AS "Percentage of affected data",
       CASE WHEN fully_identical.cnt = 0 THEN 'All OK' ELSE 'Warning' END AS "Severity"
FROM fully_identical, total_rows;
