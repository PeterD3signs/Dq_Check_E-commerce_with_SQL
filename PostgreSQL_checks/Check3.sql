-- procedure for Check 3:
CREATE OR REPLACE FUNCTION dq_check_duplicate_invoices()
RETURNS TABLE(
    column_name TEXT,
    duplicate_count BIGINT,
    percentage TEXT,
    severity TEXT
)
AS $$
DECLARE
    cnt BIGINT;
    total_rows BIGINT;
BEGIN
    -- Get total number of rows in sales
    SELECT COUNT(*) INTO total_rows FROM sales;

    -- InvoiceNo with different InvoiceDate (Critical)
    EXECUTE $sql$
        SELECT COUNT(*) 
        FROM (
            SELECT "InvoiceNo"
            FROM Sales
            GROUP BY "InvoiceNo"
            HAVING COUNT(DISTINCT "InvoiceDate") > 1
        ) t
    $sql$ INTO cnt;

    column_name := 'InvoiceNo with Multiple Dates';
    duplicate_count := cnt;
    percentage := CASE WHEN total_rows = 0 THEN '0%' ELSE ROUND((cnt::NUMERIC / total_rows) * 100, 2)::TEXT || '%';
    severity := CASE WHEN cnt = 0 THEN 'All OK' ELSE 'Critical' END;
    RETURN NEXT;

    -- Completely identical rows (Warning)
    EXECUTE $sql$
        SELECT COUNT(*) 
        FROM (
            SELECT "InvoiceNo", "StockCode", "Description", "Quantity", "InvoiceDate", "UnitPrice", "CustomerID", "Country", COUNT(*) AS c
            FROM Sales
            GROUP BY "InvoiceNo", "StockCode", "Description", "Quantity", "InvoiceDate", "UnitPrice", "CustomerID", "Country"
            HAVING COUNT(*) > 1
        ) t
    $sql$ INTO cnt;

    column_name := 'Fully Identical Rows';
    duplicate_count := cnt;
    percentage := CASE WHEN total_rows = 0 THEN '0%' ELSE ROUND((cnt::NUMERIC / total_rows) * 100, 2)::TEXT || '%';
    severity := CASE WHEN cnt = 0 THEN 'All OK' ELSE 'Warning' END;
    RETURN NEXT;

END;
$$ LANGUAGE plpgsql;


-- Run the check:
SELECT 
    column_name AS "Potential problem",
    duplicate_count AS "Number of Duplicates",
    percentage AS "Percentage of affected data",
    severity AS "Severity"
FROM dq_check_duplicate_invoices();