-- procedure for Check 1:
CREATE OR REPLACE FUNCTION dq_check_missing_values()
RETURNS TABLE(column_name TEXT, missing_count BIGINT, severity TEXT)
AS $$
DECLARE
    rec RECORD;
    missing_count_local BIGINT;
    total_critical BIGINT := 0;
    total_warning BIGINT := 0;
    total_unique_critical BIGINT := 0;
    total_unique_warning BIGINT := 0;
BEGIN
    -- Loop over all columns with their severity levels
    FOR rec IN 
        SELECT col, sev FROM (VALUES
            ('InvoiceNo', 'Critical'),
            ('StockCode', 'Critical'),
            ('Description', 'Warning'),
            ('Quantity', 'Critical'),
            ('InvoiceDate', 'Critical'),
            ('UnitPrice', 'Critical'),
            ('CustomerID', 'Warning'),
            ('Country', 'Warning')
        ) AS t(col, sev)
    LOOP
        -- Dynamic count query
        EXECUTE format('SELECT COUNT(*) FROM Sales WHERE "%s" IS NULL', rec.col)
        INTO missing_count_local;

        -- Output for each column
        column_name := rec.col;
        missing_count := missing_count_local;
        severity := CASE 
                      WHEN missing_count_local = 0 THEN 'All OK'
                      ELSE rec.sev
                    END;
        RETURN NEXT;

        -- Aggregate totals
        IF rec.sev = 'Critical' THEN
            total_critical := total_critical + missing_count_local;
        ELSE
            total_warning := total_warning + missing_count_local;
        END IF;
    END LOOP;

    -- Totals for unique rows
    EXECUTE $sql$
        SELECT COUNT(*) FROM Sales
        WHERE ("InvoiceNo" IS NULL OR "StockCode" IS NULL OR "Quantity" IS NULL
               OR "InvoiceDate" IS NULL OR "UnitPrice" IS NULL)
    $sql$ INTO total_unique_critical;

    EXECUTE $sql$
        SELECT COUNT(*) FROM Sales
        WHERE ("Country" IS NULL OR "CustomerID" IS NULL OR "Description" IS NULL)
    $sql$ INTO total_unique_warning;

    -- Return totals
    column_name := 'Total (Critical)';
    missing_count := total_critical;
    severity := CASE 
                    WHEN total_critical = 0 THEN 'All OK' 
                    ELSE 'Critical' 
                END;
    RETURN NEXT;

    column_name := 'Total (Warning)';
    missing_count := total_warning;
    severity := CASE 
                    WHEN total_warning = 0 THEN 'All OK' 
                    ELSE 'Warning' 
                END;
    RETURN NEXT;

    column_name := 'Total Unique (Critical)';
    missing_count := total_unique_critical;
    severity := CASE 
                    WHEN total_unique_critical = 0 THEN 'All OK' 
                    ELSE 'Critical' 
                END;
    RETURN NEXT;

    column_name := 'Total Unique (Warning)';
    missing_count := total_unique_warning;
    severity := CASE 
                    WHEN total_unique_warning = 0 THEN 'All OK' 
                    ELSE 'Warning' 
                END;
    RETURN NEXT;

END;
$$ LANGUAGE plpgsql;


-- Run the check:
SELECT 
  column_name AS "Column Name",
  missing_count AS "Number of Missing Entries",
  severity AS "Severity"
FROM dq_check_missing_values();