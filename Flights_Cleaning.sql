SELECT * FROM dbo.FilteredFlights


SELECT DISTINCT YEAR
FROM dbo.FilteredFlights;


SELECT DISTINCT AIRLINE
FROM dbo.FilteredFlights;


SELECT DISTINCT ORIGIN_AIRPORT
FROM dbo.FilteredFlights;


SELECT DISTINCT CANCELLATION_REASON
FROM dbo.FilteredFlights;

--- Are there any nulls? 

SELECT 
    SUM(CASE WHEN YEAR IS NULL THEN 1 ELSE 0 END) AS NullCount_YEAR,
    SUM(CASE WHEN MONTH IS NULL THEN 1 ELSE 0 END) AS NullCount_MONTH,
    SUM(CASE WHEN DAY_OF_WEEK IS NULL THEN 1 ELSE 0 END) AS NullCount_DAY_OF_WEEK,
    SUM(CASE WHEN AIRLINE IS NULL THEN 1 ELSE 0 END) AS NullCount_AIRLINE,
    SUM(CASE WHEN ORIGIN_AIRPORT IS NULL THEN 1 ELSE 0 END) AS NullCount_ORIGIN_AIRPORT,
    SUM(CASE WHEN DEPARTURE_DELAY IS NULL THEN 1 ELSE 0 END) AS NullCount_DEPARTURE_DELAY,
    SUM(CASE WHEN CANCELLED IS NULL THEN 1 ELSE 0 END) AS NullCount_CANCELLED,
    SUM(CASE WHEN CANCELLATION_REASON IS NULL THEN 1 ELSE 0 END) AS NullCount_CANCELLATION_REASON
FROM 
    dbo.FilteredFlights;

--- It gives 0 for every column. 

--- To examin the dataset further lets UPDATE THE PREVIOUS QUERY and check for EMPTY too:


SELECT 
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN CANCELLATION_REASON IS NULL OR CANCELLATION_REASON = '' THEN 1 ELSE 0 END) AS EmptyOrNullCount_CANCELLATION_REASON,
    SUM(CASE WHEN DEPARTURE_DELAY IS NULL OR DEPARTURE_DELAY = '' THEN 1 ELSE 0 END) AS EmptyOrNullCount_DEPARTURE_DELAY,
    SUM(CASE WHEN AIRLINE IS NULL OR AIRLINE = '' THEN 1 ELSE 0 END) AS EmptyOrNullCount_AIRLINE,
    SUM(CASE WHEN ORIGIN_AIRPORT IS NULL OR ORIGIN_AIRPORT = '' THEN 1 ELSE 0 END) AS EmptyOrNullCount_ORIGIN_AIRPORT,
    SUM(CASE WHEN YEAR IS NULL OR YEAR = '' THEN 1 ELSE 0 END) AS EmptyOrNullCount_YEAR,
    SUM(CASE WHEN MONTH IS NULL OR MONTH = '' THEN 1 ELSE 0 END) AS EmptyOrNullCount_MONTH,
    SUM(CASE WHEN DAY_OF_WEEK IS NULL OR DAY_OF_WEEK = '' THEN 1 ELSE 0 END) AS EmptyOrNullCount_DAY_OF_WEEK,
    SUM(CASE WHEN CANCELLED IS NULL OR CANCELLED = '' THEN 1 ELSE 0 END) AS EmptyOrNullCount_CANCELLED
FROM 
    dbo.FilteredFlights;




--- I need a date column within the table. 

ALTER TABLE dbo.FilteredFlights
ADD FullDate DATE;

--- The Date column will have the combined data from the following columns:

UPDATE dbo.FilteredFlights
SET FullDate = CAST(CONCAT(YEAR, '-', MONTH, '-', DAY_OF_WEEK) AS DATE);

---- Checking if the date column is composed of unique values 

SELECT 
    COUNT(*) AS TotalRows
FROM 
    dbo.FilteredFlights;

SELECT 
    COUNT(DISTINCT FullDate) AS DistinctDateCount
FROM 
    dbo.FilteredFlights;

--- Result: TotalRows: 5,819,079, Distinct Date Count: 84

--- This indicates that there are only 84 unique dates across more than 5.8 million rows in the FilteredFlights table. 

--- I was expecting that the dataset covered an entire year - 365 days! but only 84 UNIQUE!!

--- So we have missing dates or this dataset refers to specific part of the year!


--- I will check the range: 

SELECT MIN(FullDate) AS StartDate, MAX(FullDate) AS EndDate
FROM dbo.FilteredFlights;


--- Result; Start Date_:2015-01-01, End Date: 2015-12-07

--- So it ends a the begining of DECEMBER 


--- I want to check how many records exist for each day:

SELECT FullDate, COUNT(*) AS RecordsPerDate
FROM dbo.FilteredFlights
GROUP BY FullDate
ORDER BY FullDate;

--- SO NOW I SEE that the current dataset contains data only for THE FIRST 7 DAYS OF EACH MONTH!.

--- Which, explains why the DISTINCT COUNT was 84 (= 7 days * 12 months)!!!


--- I want to add a a new calculated column about the Status of the flights : **On Time, Delayed, Cancelled.**


ALTER TABLE dbo.FilteredFlights
ADD Status AS (
    CASE 
        WHEN CANCELLED = 1 THEN 'Cancelled' 
        WHEN DEPARTURE_DELAY > 0 THEN 'Delayed' 
        ELSE 'On Time' 
    END
);

SELECT TOP 20 Status
FROM dbo.FilteredFlights;


