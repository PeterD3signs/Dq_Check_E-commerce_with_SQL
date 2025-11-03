# Data quality checks for E-Commerce Data

This is a very simple project including 5 examples of quality checks for given E-Commerce data.
For each check, the following is provided:
1. What is verified?
2. What data quality dimension is checked (completness / validity / uniqueness / usefulness)
3. SQL logic (both in pure SQL and in PostgreSQL)
4. Severity (either "warning" or "critical")

## Repo structure

In 'PostgreSQL_checks/' there are the procedural versions for the checks together with
code that was used to create the tables for testing purpouses (testing done on Supabase.com).

In 'vanilla_SQL_checks/' there are the vanilla SQL versions of the checks provided.

The detailed explenation of what exactly each check does can be found in 'Checks.md'.

## Data structure

Column name: | InvoiceNo | StockCode | Description | Quantity | InvoiceDate | UnitPrice | CustomerID | Country |
--- | --- | --- | --- | --- | --- | --- | --- | --- |
Data type: | String | String | String | Number | DateTime | Number | ID | String |

Data source:  https://www.kaggle.com/datasets/carrie1/ecommerce-data

## Important notes

1. No data is unique (regardless of the column).
2. Returns are marked with negative Quantity.
3. Each invoice must be unique => no two invoices with same InvoiceNo on different InvoiceDate.
4. Negative UnitPrice is an adjustment of bad debt (but in my personal opinion this should not be present in the dataset and is an outlier).

