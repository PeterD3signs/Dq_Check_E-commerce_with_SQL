# Data quality checks for E-Commerce Data

This is a very simple project including 5 examples of quality checks for given E-Commerce data.
For each check, the following is provided:
1. What is verified?
2. What data quality dimension is checked (completness / validity / uniqueness / usefulness)
3. SQL logic (both in pure SQL and in PostgreSQL)
4. Severity (either "warning" or "critical")

## Repo structure

In "<ins>PostgreSQL_checks/</ins>" there are the procedural versions for the checks.
In "<ins>vanilla_SQL_checks/</ins>" there are the vanilla SQL versions of the checks provided.
In "<ins>DatabaseSetup/</ins>" there is the SQL setup for a mock PostgreSQL database ( I decided to test it on Supabase.com)

In both folders mentioned above a "<ins>returnedValues.md</ins>" file can be found,  
with info about tables returned after performing the check on the data on Supabase.

The detailed explenation of what exactly each check does can be found in "<ins>Checks.md</ins>".

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

