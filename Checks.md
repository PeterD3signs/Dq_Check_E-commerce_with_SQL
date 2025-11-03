# Explanation of data checks performed:

## Check 1:

This check is done to find missing values in any of the columns. It measures Completeness.  
  
It returns a table with the cumulative number of missing entries and the severity of missing data.  
It also returns a cumulative (both all and unique) count of entries with a Warning or a Critical state,  

Example:
Column name | Number of missing entries | Severity 
--- | --- | --- 
col A | 0 | All Ok
col B | 10 | Warning
col C | 20 | Critical
col D | 50 | Warning
total warings | 60 | Warning
total unique warnings | 55 | Warning
total critical | 20 | Critical
total unique critical | 20 | Critical

The severity is marked as follows:  
Lack of: "InvoiceNo", "StockCode", "Quantity", "InvoiceDate", "UnitPrice" - Critical  
Lack of: "Country", "CustomerID", "Description" - Warning  
  

## Check 2:

This check is done to find incorrect values. It measures Validity.  

Similarly to check nr one, this returns the cumulative numbers for incorrect values (for all columns that can be reliably checked), together with cumulative totals.  

Values that are considered incorrect are:

- for InvoiceNo, customerID - values that are smaller than 0 (if can be parsed from String) -> severity: Critical.
- for Quantity - values that are bigger / smaller than args minQuantity (default: -100 000) and maxQuantity (default: 100 000) -> severity: Warning.
- for UnitPrice - values smaller than 0 (Critical) or bigger than passed arg maxUnitPrice (default: 50 000, severity: Warning).
- for InvoiceDate - dates before arg minDate (default: 2000-12-1 at 8:00) or after present date -> severity: Critical.
- for Country - country that is not present on CountriesWeShipTo table -> severity: Warning.
- for others - no check (pointless / impossible).

NOTES:
1. Incomplete values are not checked here at all. This is the task for "Check 1".  
2. CountriesWeShipTo is a table made up for this exercise. For real life scenarios,
it can either be created on the spot or just skipped, depending on the QA focus.


## Check 3:

This check is done to find doubled invoices. It measures Uniqueness.

In theory there can be multiple repeating entries with same invoice numbers,
as the database keeps track of items on invoices, not the invoices themselves.
It is still possible to check their uniqueness though, by conducting those two test:

1. Check whether there are no two entries with two identical InvoiceNo but different InvoiceDate.
2. Check whether there are no two exactly similar entries.

This is an important check, as different invoices with the same numbers could cause legal issues for the business.
For the given use case, which is analytics and reporting, it is also quite important!


## Check 4:

This is a cumulative check that looks both for missing and incorrect values and checks the severity.
The difference is that instead of counting for each column, it gives a single cumulative count.

It is aimed to show the general patterns in the data, which is very useful for analytics.
It returns the % of fully correct entries, the % of entries with missing values, the % of entries with wrong values, the % of entries with Warnings (but without Critical errors) and the % of entries with Critical errors.

It speaks about the general Usefulness of the data.

### Quick recap:
Critical:
- missing "InvoiceNo", "StockCode", "Quantity", "InvoiceDate", "UnitPrice";
- wrong data in:
    1. "InvoiceNo" (values smaller than 0).
    2. "customerID" (values smaller than 0).
    3. "UnitPrice" (values smaller than 0).
    4. "InvoiceDate" (date before minDate (passed as an arg), or after NOW()).

Warning:
- missing "Country", "CustomerID", "Description";
- wrong data in:
    1. "Quantity" (values smaller or bigger than passed args).
    3. "UnitPrice" (values bigger than an arg maxUnitPrice).
    4. "County" (country not present on CountriesWeShipTo table).

Note:
- This Check can be thought as a cumilative (less precise) Check 1 and 2. It does not include Check 3 functionality.

## Check 5:

This check shows entries with negative values in the UnitPrice column.

It is an example of how to check for strange patterns in data, when previous checks pointed towards areas,
where further insight is needed.

This is the simplest of the queries, but it is still important, as it helps to understand
some context behind why data is presented in a particular fashion.



