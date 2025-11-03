-- procedure for Check 4:
CREATE OR REPLACE FUNCTION dq_overall_data_quality(
    minQuantity BIGINT DEFAULT -100000,
    maxQuantity BIGINT DEFAULT 100000,
    maxUnitPrice NUMERIC DEFAULT 50000,
    minDate TIMESTAMP DEFAULT '2000-12-01 08:00'
)
RETURNS TABLE(
    category TEXT,
    row_count BIGINT,
    percentage TEXT
)
AS $$
DECLARE
    total_rows BIGINT;
    cnt BIGINT;
BEGIN
    -- Total rows
    SELECT COUNT(*) INTO total_rows FROM sales;

    -- Rows with Critical issues
    EXECUTE $sql$
        SELECT COUNT(*) FROM sales s
        WHERE
            "InvoiceNo" IS NULL
            OR "StockCode" IS NULL
            OR "Quantity" IS NULL
            OR "InvoiceDate" IS NULL
            OR "UnitPrice" IS NULL
            OR ("InvoiceNo" ~ '^\d+$' AND CAST("InvoiceNo" AS NUMERIC) < 0)
            OR "CustomerID" < 0
            OR "UnitPrice" < 0
            OR "InvoiceDate" < $1
            OR "InvoiceDate" > NOW()
    $sql$ USING minDate
    INTO cnt;

    category := 'Critical';
    row_count := cnt;
    percentage := CASE WHEN total_rows = 0 THEN '0%' ELSE ROUND((cnt::NUMERIC / total_rows) * 100, 2)::TEXT || '%' END;
    RETURN NEXT;

    -- Rows with Warning (no Critical, but at least one Warning)
    EXECUTE $sql$
        SELECT COUNT(*) FROM sales s
        WHERE NOT (
            "InvoiceNo" IS NULL
            OR "StockCode" IS NULL
            OR "Quantity" IS NULL
            OR "InvoiceDate" IS NULL
            OR "UnitPrice" IS NULL
            OR ("InvoiceNo" ~ '^\d+$' AND CAST("InvoiceNo" AS NUMERIC) < 0)
            OR ("CustomerID" IS NOT NULL AND "CustomerID" < 0)
            OR "UnitPrice" < 0
            OR "InvoiceDate" < $1
            OR "InvoiceDate" > NOW()
        )
        AND (
            "Country" IS NULL
            OR "CustomerID" IS NULL
            OR "Description" IS NULL
            OR "Quantity" < $2 OR "Quantity" > $3
            OR "UnitPrice" > $4
            OR "Country" NOT IN (SELECT country_name FROM CountriesWeShipTo)
        )
    $sql$ USING minDate, minQuantity, maxQuantity, maxUnitPrice
    INTO cnt;

    category := 'Warning';
    row_count := cnt;
    percentage := CASE WHEN total_rows = 0 THEN '0%' ELSE ROUND((cnt::NUMERIC / total_rows) * 100, 2)::TEXT || '%' END;
    RETURN NEXT;

    -- Rows with any missing values (regardless of wrong values)
    EXECUTE $sql$
        SELECT COUNT(*) FROM sales
        WHERE
            "InvoiceNo" IS NULL
            OR "StockCode" IS NULL
            OR "Quantity" IS NULL
            OR "InvoiceDate" IS NULL
            OR "UnitPrice" IS NULL
            OR "Country" IS NULL
            OR "CustomerID" IS NULL
            OR "Description" IS NULL
    $sql$
    INTO cnt;

    category := 'Any Missing';
    row_count := cnt;
    percentage := CASE WHEN total_rows = 0 THEN '0%' ELSE ROUND((cnt::NUMERIC / total_rows) * 100, 2)::TEXT || '%' END;
    RETURN NEXT;

    -- Rows with any wrong values (regardless of missing values)
    EXECUTE $sql$
        SELECT COUNT(*) FROM sales s
        WHERE
            ("InvoiceNo" ~ '^\d+$' AND CAST("InvoiceNo" AS NUMERIC) < 0)
            OR "CustomerID" < 0
            OR "Quantity" < $2 OR "Quantity" > $3
            OR "UnitPrice" < 0 OR "UnitPrice" > $4
            OR "InvoiceDate" < $1 OR "InvoiceDate" > NOW()
            OR "Country" NOT IN (SELECT country_name FROM CountriesWeShipTo)
    $sql$ USING minDate, minQuantity, maxQuantity, maxUnitPrice
    INTO cnt;

    category := 'Any Wrong';
    row_count := cnt;
    percentage := CASE WHEN total_rows = 0 THEN '0%' ELSE ROUND((cnt::NUMERIC / total_rows) * 100, 2)::TEXT || '%' END;
    RETURN NEXT;

    -- Fully OK rows (no Critical, no Warning)
    EXECUTE $sql$
        SELECT COUNT(*) FROM sales s
        WHERE
            "InvoiceNo" IS NOT NULL
            AND "StockCode" IS NOT NULL
            AND "Quantity" IS NOT NULL AND "Quantity" >= $2 AND "Quantity" <= $3
            AND "InvoiceDate" IS NOT NULL AND "InvoiceDate" >= $1 AND "InvoiceDate" <= NOW()
            AND "UnitPrice" IS NOT NULL AND "UnitPrice" >= 0 AND "UnitPrice" <= $4
            AND ("InvoiceNo" !~ '^\d+$' OR CAST("InvoiceNo" AS NUMERIC) >= 0)
            AND "CustomerID" >= 0
            AND "Country" IS NOT NULL AND "Country" IN (SELECT country_name FROM CountriesWeShipTo)
            AND "Description" IS NOT NULL
    $sql$ USING minDate, minQuantity, maxQuantity, maxUnitPrice
    INTO cnt;

    category := 'Fully OK';
    row_count := cnt;
    percentage := CASE WHEN total_rows = 0 THEN '0%' ELSE ROUND((cnt::NUMERIC / total_rows) * 100, 2)::TEXT || '%' END;
    RETURN NEXT;

END;
$$ LANGUAGE plpgsql;


-- Run the check: (args selected as for Check 2)
SELECT
    category AS "Deta entries",
    row_count AS "Number of occurrences",
    percentage AS "Percentage of whole data"
FROM dq_overall_data_quality(
    minQuantity := -5000,
    maxQuantity := 5000,
    maxUnitPrice := 10000,
    minDate := '2010-01-01 00:00:00'
);