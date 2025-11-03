# Values returned for procedural checks:

## Check 1:

Column Name | Number of Missing Entries | Severity 
--- | --- | --- 
InvoiceNo | 0 | All Ok
StockCode | 0 | All Ok
Description | 1454 | Warning
Quantity | 0 | All Ok
InvoiceDate | 0 | All Ok
UnitPrice | 0 | All Ok
CustomerID| 135080 | Warning
Country | 0 | All Ok
Total (Critical) | 0 | All Ok
Total (warning) | 136534 | Warning
Total Unique (Critical) | 0 | All Ok
Total Unique (Warning) | 135080 | Warning

## Check 2:

Column Name | Number of Invalid Entries | Severity 
--- | --- | --- 
InvoiceNo | 0 | All Ok
CustomerID | 0 | All Ok
Quantity | 11 | Warning
UnitPrice (Negative) | 2 | Critical
UnitPrice (Too High) | 10 | Warning
InvoiceDate | 0 | All Ok
Country | 798 | Warning
Total (Critical) | 2 | Critical
Total (warning) | 819 | Warning
Total Unique (Critical) | 2 | Critical
Total Unique (Warning) | 819 | Warning


## Check 3:

Potential problem | Number of Duplicates | Percentage of affected data | Severity 
--- | --- | --- | ---
InvoiceNo with Multiple Dates | 43 | 0.01% | Critical
Fully Identical Rows | 4879 | 0.90% | Warning

## Check 4:

Data entries | Number of occurrences | Percentage of whole data
--- | --- | --- 
Critical | 2 | 0.00%
Warning | 135681 | 25.04%
Any Missing | 135080 | 24.93%
Any Wrong | 821 | 0.15%
Fully OK | 406226 | 74.96%

## Check 5:

id | InvoiceNo | StockCode | Description | Quantity | InvoiceDate | UnitPrice | CustomerID | Country |
--- | --- | --- | --- | --- | --- | --- | --- | --- |
299984 | A563186 | B | Adjust bad debt | 1 | 2011-08-12 14:51:00+00 | -11062.06 | NULL | United Kingdom |
299985 | A563187 | B | Adjust bad debt | 1 | 2011-08-12 14:52:00+00 | -11062.06 | NULL | United Kingdom |