-- Reference Table: CountriesWeShipTo
CREATE TABLE IF NOT EXISTS CountriesWeShipTo (
    country_code CHAR(2) PRIMARY KEY,
    country_name TEXT NOT NULL UNIQUE
);

-- Main Data Table: Sales
CREATE TABLE IF NOT EXISTS Sales (
    id SERIAL PRIMARY KEY,  -- separate key as we don't know whether data is complete yet
    InvoiceNo TEXT,
    StockCode TEXT,
    Description TEXT,
    Quantity INTEGER,
    InvoiceDate TIMESTAMP WITH TIME ZONE,
    UnitPrice NUMERIC(10,2),
    CustomerID INTEGER,
    Country TEXT
);




-- Indexes 
CREATE INDEX IF NOT EXISTS idx_sales_invoiceno   ON Sales(InvoiceNo);
CREATE INDEX IF NOT EXISTS idx_sales_invoicedate ON Sales(InvoiceDate);
CREATE INDEX IF NOT EXISTS idx_sales_customer    ON Sales(CustomerID);
CREATE INDEX IF NOT EXISTS idx_sales_country     ON Sales(Country);

CREATE INDEX IF NOT EXISTS idx_country_name ON CountriesWeShipTo (country_name);




-- RLS & Policies
ALTER TABLE Sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE CountriesWeShipTo ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow service role to read Sales"
  ON Sales
  FOR SELECT
  TO service_role
  USING (true);

CREATE POLICY "Allow service role to read CountriesWeShipTo"
  ON CountriesWeShipTo
  FOR SELECT
  TO service_role
  USING (true);




-- Insert example countries (based on original dataset)
INSERT INTO CountriesWeShipTo (country_code, country_name)
VALUES
    ('AU', 'Australia'),
    ('AT', 'Austria'),
    ('BH', 'Bahrain'),
    ('BE', 'Belgium'),
    ('BR', 'Brazil'),
    ('CA', 'Canada'),
    ('CI', 'Channel Islands'),
    ('CY', 'Cyprus'),
    ('CZ', 'Czech Republic'),
    ('DK', 'Denmark'),
    ('IE', 'EIRE'),
    ('FI', 'Finland'),
    ('FR', 'France'),
    ('DE', 'Germany'),
    ('GR', 'Greece'),
    ('HK', 'Hong Kong'),
    ('IS', 'Iceland'),
    ('IL', 'Israel'),
    ('IT', 'Italy'),
    ('JP', 'Japan'),
    ('LB', 'Lebanon'),
    ('LT', 'Lithuania'),
    ('MT', 'Malta'),
    ('NL', 'Netherlands'),
    ('NO', 'Norway'),
    ('PL', 'Poland'),
    ('PT', 'Portugal'),
    ('ZA', 'RSA'),
    ('SA', 'Saudi Arabia'),
    ('SG', 'Singapore'),
    ('ES', 'Spain'),
    ('SE', 'Sweden'),
    ('CH', 'Switzerland'),
    ('AE', 'United Arab Emirates'),
    ('GB', 'United Kingdom'),
    ('US', 'USA')
ON CONFLICT DO NOTHING;

-- CSV data copied manually (using Supabase interface)
-- If done with SQL, the following commang could be used:
--
-- COPY Sales(InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country)
-- FROM 'url_to_csv_file'
-- WITH (FORMAT csv, HEADER true);




-- Make colums capitalization consistent:
ALTER TABLE Sales
  RENAME COLUMN invoiceno TO "InvoiceNo";

ALTER TABLE Sales
  RENAME COLUMN stockcode TO "StockCode";

ALTER TABLE Sales
  RENAME COLUMN description TO "Description";

ALTER TABLE Sales
  RENAME COLUMN quantity TO "Quantity";

ALTER TABLE Sales
  RENAME COLUMN invoicedate TO "InvoiceDate";

ALTER TABLE Sales
  RENAME COLUMN unitprice TO "UnitPrice";

ALTER TABLE Sales
  RENAME COLUMN customerid TO "CustomerID";

ALTER TABLE Sales
  RENAME COLUMN country TO "Country";




-- -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
-- Insert either vanila SQL cheks or procedural checks here
-- -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
