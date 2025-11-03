-- procedure for Check 2:
CREATE OR REPLACE FUNCTION dq_check_invalid_values(
    minQuantity NUMERIC DEFAULT -100000,
    maxQuantity NUMERIC DEFAULT 100000,
    maxUnitPrice NUMERIC DEFAULT 50000,
    minDate TIMESTAMP DEFAULT '2000-12-01 08:00:00'
)
RETURNS TABLE(
    column_name TEXT,
    invalid_count BIGINT,
    severity TEXT
)
AS $$
DECLARE
    cnt BIGINT;
    total_critical BIGINT := 0;
    total_warning BIGINT := 0;
    total_unique_critical BIGINT := 0;
    total_unique_warning BIGINT := 0;
BEGIN
    -- InvoiceNo < 0 (if numeric)
    EXECUTE $sql$
        SELECT COUNT(*) FROM Sales
        WHERE "InvoiceNo" ~ '^\d+$'  -- matches integers
            AND CAST("InvoiceNo" AS NUMERIC) < 0;
    $sql$ INTO cnt;

    column_name := 'InvoiceNo';
    invalid_count := cnt;
    severity := CASE WHEN cnt = 0 THEN 'All OK' ELSE 'Critical' END;
    RETURN NEXT;
    total_critical := total_critical + cnt;

    -- CustomerID < 0 (if numeric)
    EXECUTE $sql$
        SELECT COUNT(*) FROM Sales
        WHERE "CustomerID" < 0;
    $sql$ INTO cnt;

    column_name := 'CustomerID';
    invalid_count := cnt;
    severity := CASE WHEN cnt = 0 THEN 'All OK' ELSE 'Critical' END;
    RETURN NEXT;
    total_critical := total_critical + cnt;

    -- Quantity < minQuantity or > maxQuantity
    EXECUTE format('
        SELECT COUNT(*) FROM Sales
        WHERE "Quantity" < %s OR "Quantity" > %s',
        minQuantity, maxQuantity)
    INTO cnt;

    column_name := 'Quantity';
    invalid_count := cnt;
    severity := CASE WHEN cnt = 0 THEN 'All OK' ELSE 'Warning' END;
    RETURN NEXT;
    total_warning := total_warning + cnt;

    -- UnitPrice < 0 (Critical)
    EXECUTE $sql$
        SELECT COUNT(*) FROM Sales
        WHERE "UnitPrice" < 0
    $sql$ INTO cnt;

    column_name := 'UnitPrice (Negative)';
    invalid_count := cnt;
    severity := CASE WHEN cnt = 0 THEN 'All OK' ELSE 'Critical' END;
    RETURN NEXT;
    total_critical := total_critical + cnt;

    -- UnitPrice > maxUnitPrice (Warning)
    EXECUTE format('
        SELECT COUNT(*) FROM Sales
        WHERE "UnitPrice" > %s', maxUnitPrice)
    INTO cnt;

    column_name := 'UnitPrice (Too High)';
    invalid_count := cnt;
    severity := CASE WHEN cnt = 0 THEN 'All OK' ELSE 'Warning' END;
    RETURN NEXT;
    total_warning := total_warning + cnt;

    -- InvoiceDate < minDate or > NOW()
    EXECUTE format('
        SELECT COUNT(*) FROM Sales
        WHERE "InvoiceDate" < %L OR "InvoiceDate" > NOW()', minDate)
    INTO cnt;

    column_name := 'InvoiceDate';
    invalid_count := cnt;
    severity := CASE WHEN cnt = 0 THEN 'All OK' ELSE 'Critical' END;
    RETURN NEXT;
    total_critical := total_critical + cnt;

    -- Country not in CountriesWeShipTo
    EXECUTE $sql$
        SELECT COUNT(*) FROM Sales s
        WHERE "Country" IS NOT NULL
          AND "Country" NOT IN (SELECT "country_name" FROM CountriesWeShipTo)
    $sql$ INTO cnt;

    column_name := 'Country';
    invalid_count := cnt;
    severity := CASE WHEN cnt = 0 THEN 'All OK' ELSE 'Warning' END;
    RETURN NEXT;
    total_warning := total_warning + cnt;

    -- Compute total unique invalid rows (Critical)
    EXECUTE format($sql$
        SELECT COUNT(*) FROM Sales
        WHERE ("InvoiceNo" ~ '^\d+$' AND CAST("InvoiceNo" AS NUMERIC) < 0)
           OR "CustomerID" < 0
           OR "UnitPrice" < 0
           OR "InvoiceDate" < %L OR "InvoiceDate" > NOW()
        $sql$, minDate)
    INTO total_unique_critical;

    -- Compute total unique invalid rows (Warning)
    EXECUTE format($sql$
        SELECT COUNT(*) FROM Sales
        WHERE "Quantity" < %s OR "Quantity" > %s
           OR "UnitPrice" > %s
           OR "Country" NOT IN (SELECT "country_name" FROM CountriesWeShipTo)
        $sql$, minQuantity, maxQuantity, maxUnitPrice)
    INTO total_unique_warning;

    -- Return totals
    column_name := 'Total (Critical)';
    invalid_count := total_critical;
    severity := CASE WHEN total_critical = 0 THEN 'All OK' ELSE 'Critical' END;
    RETURN NEXT;

    column_name := 'Total (Warning)';
    invalid_count := total_warning;
    severity := CASE WHEN total_warning = 0 THEN 'All OK' ELSE 'Warning' END;
    RETURN NEXT;

    column_name := 'Total Unique (Critical)';
    invalid_count := total_unique_critical;
    severity := CASE WHEN total_unique_critical = 0 THEN 'All OK' ELSE 'Critical' END;
    RETURN NEXT;

    column_name := 'Total Unique (Warning)';
    invalid_count := total_unique_warning;
    severity := CASE WHEN total_unique_warning = 0 THEN 'All OK' ELSE 'Warning' END;
    RETURN NEXT;

END;
$$ LANGUAGE plpgsql;


-- Run the check (args can be adjusted as needed, I chose those because biger values appear to be outliers):
SELECT 
  column_name AS "Column Name",
  invalid_count AS "Number of Invalid Entries",
  severity AS "Severity"
FROM dq_check_invalid_values(
    minQuantity := -5000,
    maxQuantity := 5000,
    maxUnitPrice := 10000,
    minDate := '2010-01-01 00:00:00'
);