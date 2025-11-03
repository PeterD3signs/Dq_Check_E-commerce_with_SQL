-- Vanilla SQL solution for Check 1:

-- Individual missing counts per column
SELECT 'InvoiceNo' AS "Column Name", COUNT(*) AS "Number of Missing Entries", 
       CASE WHEN COUNT(*) = 0 THEN 'All Ok' ELSE 'Critical' END AS "Severity"
FROM sales
WHERE "InvoiceNo" IS NULL
UNION ALL
SELECT 'StockCode', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'All Ok' ELSE 'Critical' END
FROM sales
WHERE "StockCode" IS NULL
UNION ALL
SELECT 'Description', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'All Ok' ELSE 'Warning' END
FROM sales
WHERE "Description" IS NULL
UNION ALL
SELECT 'Quantity', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'All Ok' ELSE 'Critical' END
FROM sales
WHERE "Quantity" IS NULL
UNION ALL
SELECT 'InvoiceDate', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'All Ok' ELSE 'Critical' END
FROM sales
WHERE "InvoiceDate" IS NULL
UNION ALL
SELECT 'UnitPrice', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'All Ok' ELSE 'Critical' END
FROM sales
WHERE "UnitPrice" IS NULL
UNION ALL
SELECT 'CustomerID', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'All Ok' ELSE 'Warning' END
FROM sales
WHERE "CustomerID" IS NULL
UNION ALL
SELECT 'Country', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'All Ok' ELSE 'Warning' END
FROM sales
WHERE "Country" IS NULL
-- Totals
UNION ALL
-- Totals per severity, summing column-level counts
SELECT 'Total (Critical)' AS "Column Name",
       (
         (SELECT COUNT(*) FROM sales WHERE "InvoiceNo" IS NULL) +
         (SELECT COUNT(*) FROM sales WHERE "StockCode" IS NULL) +
         (SELECT COUNT(*) FROM sales WHERE "Quantity" IS NULL) +
         (SELECT COUNT(*) FROM sales WHERE "InvoiceDate" IS NULL) +
         (SELECT COUNT(*) FROM sales WHERE "UnitPrice" IS NULL)
       ) AS "Number of Missing Entries",
       CASE 
           WHEN 
             (
               (SELECT COUNT(*) FROM sales WHERE "InvoiceNo" IS NULL) +
               (SELECT COUNT(*) FROM sales WHERE "StockCode" IS NULL) +
               (SELECT COUNT(*) FROM sales WHERE "Quantity" IS NULL) +
               (SELECT COUNT(*) FROM sales WHERE "InvoiceDate" IS NULL) +
               (SELECT COUNT(*) FROM sales WHERE "UnitPrice" IS NULL)
             ) = 0
           THEN 'All Ok'
           ELSE 'Critical'
       END AS "Severity"
UNION ALL
SELECT 'Total (Warning)',
       (
         (SELECT COUNT(*) FROM sales WHERE "Description" IS NULL) +
         (SELECT COUNT(*) FROM sales WHERE "CustomerID" IS NULL) +
         (SELECT COUNT(*) FROM sales WHERE "Country" IS NULL)
       ),
       CASE 
           WHEN 
             (
               (SELECT COUNT(*) FROM sales WHERE "Description" IS NULL) +
               (SELECT COUNT(*) FROM sales WHERE "CustomerID" IS NULL) +
               (SELECT COUNT(*) FROM sales WHERE "Country" IS NULL)
             ) = 0
           THEN 'All Ok'
           ELSE 'Warning'
       END
UNION ALL
-- Totals for unique rows (much easier)
SELECT 'Total Unique (Critical)',
       (SELECT COUNT(*) FROM sales
        WHERE "InvoiceNo" IS NULL OR "StockCode" IS NULL OR "Quantity" IS NULL OR "InvoiceDate" IS NULL OR "UnitPrice" IS NULL),
       CASE WHEN (SELECT COUNT(*) FROM sales
                  WHERE "InvoiceNo" IS NULL OR "StockCode" IS NULL OR "Quantity" IS NULL OR "InvoiceDate" IS NULL OR "UnitPrice" IS NULL)=0 THEN 'All Ok' ELSE 'Critical' END
UNION ALL
SELECT 'Total Unique (Warning)',
       (SELECT COUNT(*) FROM sales
        WHERE "Description" IS NULL OR "CustomerID" IS NULL OR "Country" IS NULL),
       CASE WHEN (SELECT COUNT(*) FROM sales
                  WHERE "Description" IS NULL OR "CustomerID" IS NULL OR "Country" IS NULL)=0 THEN 'All Ok' ELSE 'Warning' END;
