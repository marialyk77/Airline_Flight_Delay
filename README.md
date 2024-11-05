# Airline Flight Delay

## ETL

###  Extracted the data from 4 CSV files.

![image](https://github.com/user-attachments/assets/16aa4a6e-4f78-4307-9a86-a27cb5be7b37)

I quickly realized that the *Flights table* **was too large**, which was impacting model performance. To address this, I saved the file in **SQL Server**, performed the necessary data cleaning there, and then established a connection between SQL Server and Power BI to import **the cleaned Flights table**.

![image](https://github.com/user-attachments/assets/dd97f4b3-aaac-48b4-8428-758d3ae37924)

I established the connection between Power BI and SQL Server using a parameter. I know it might be a bit of an exaggeration, but I'm always happy to practice my skills.

![image](https://github.com/user-attachments/assets/ff657b7d-b7e7-4961-9760-fa787563ae6a)



### Transformation (Flights Table)

- Is the Fact Table.
- Total Columns: 31
- Total Rows: 5.819.079
- Data cleaning was performed in **SQL Server**. 💡 (*A decision made solely by the project author*) 💡

- 📝 Kept only the **necessary** collumns.

```ruby
SELECT 
    YEAR,
    MONTH,
    DAY_OF_WEEK,
    AIRLINE,
    ORIGIN_AIRPORT,
    DEPARTURE_DELAY,
    CANCELLED,
    CANCELLATION_REASON
INTO 
    dbo.FilteredFlights
FROM 
    dbo.flights;
```

- 📝 **Data Integrity:** The dataset is complete. No Nulls

```ruby
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
```

![image](https://github.com/user-attachments/assets/822769bc-4e8f-45dd-bf71-0ec72340c55f)

 > [!IMPORTANT]
 > Important to note that null values represent the absence of data (*in other words it is not known if there should have been a value*), which differs from an empty or blank entry (*Empty indicates that the absence of content is intentional*).

- 📝 **Data Completeness:** The dataset contained 2 columns with Empty values: 

![image](https://github.com/user-attachments/assets/4df0cbce-96b9-4b21-84f1-8c6080d7af1a)

> [!TIP]
> Quick Observation:

1. **Cancellation Reason**: Out of the total 5,819,079 rows, **5,729,195 were empty**! That is a good thing: The vast majority of flights **did not face cancellations**. 
2. **Departure Delay**: Out of the total 5,819,079 rows, **86,153 were empty**! That is not so a good thing: The vast majority of flights **recorded a departure delay**. Therefore, it suggests that these flights experienced delays. We should later investigate how significant these delays were.


- 📝 Added a new column *Date* by combining the colums: *Year, Month & Day of Week*.
  
```ruby
ALTER TABLE dbo.FilteredFlights
ADD FullDate DATE;

UPDATE dbo.FilteredFlights
SET FullDate = CAST(CONCAT(YEAR, '-', MONTH, '-', DAY_OF_WEEK) AS DATE);

```
- 📝 Check if the *FullDate* column includes data for the entire year: 

```ruby
SELECT 
    COUNT(DISTINCT FullDate) AS DistinctDateCount
FROM 
    dbo.FilteredFlights;
```
**Result:** Only 84 distinct days are recorded, indicating that the dataset does not cover the entire year.

![image](https://github.com/user-attachments/assets/12018294-ff20-42c3-8465-b5341832c1f3)


- 📝 Check how many records exist for each day:

```ruby
SELECT FullDate, COUNT(*) AS RecordsPerDate
FROM dbo.FilteredFlights
GROUP BY FullDate
ORDER BY FullDate;
```

**Result:** The current dataset contains data only for **THE FIRST 7 DAYS OF EACH MONTH!**.

![image](https://github.com/user-attachments/assets/1337b0b4-3444-40b9-b54e-a1ed08c9135a)



- 📝 Added a new calculated column *Status* : **On Time, Delayed, Cancelled.**

```ruby
ALTER TABLE dbo.FilteredFlights
ADD Status AS (
    CASE 
        WHEN CANCELLED = 1 THEN 'Cancelled' 
        WHEN DEPARTURE_DELAY > 0 THEN 'Delayed' 
        ELSE 'On Time' 
    END
);
```

**Result:**

![image](https://github.com/user-attachments/assets/a86cb9d5-6a9e-4d52-b263-0bf5b9404b6e)



### Transformation (Airlines Table)

 - Total Columns: 2
 - Total Rows: 15
 - Data cleaning was performed in **Power BI**.

 - Upgraded 1st row as header:

  ![image](https://github.com/user-attachments/assets/f2b35cb9-f324-42d7-8a5f-3909f116e430)


### Transformation (Airlines Table)

 - Total Columns: 7
 - Total Rows: 322
 - Data cleaning was performed in **Power BI**.

 - No transformations needed

### Transformation (Cancelation Codes Table)

 - Total Columns: 2
 - Total Rows: 5

 - Upgraded 1st row as header:

### 💡 Adding a Seperate Date Table (*A decision made solely by the project author*) 💡

> [!WARNING]
> The Fact table contains only **a portion of the year**. 

> [!CAUTION]
> Use a specialized Dates table by establishing a **LEFT JOIN**.

 🔥 **Risks in Joining a Full Date Table with Partial Fact Table Data:** 

- **Incomplete Analysis**: Joining a full date table with a fact table containing data for only specific days may result in many NULLs or zeros, skewing averages and totals.

- **Misleading Trends**: Analyzing trends over time can lead to incorrect interpretations, as averages may include days with zero flights, underrepresenting actual delays.

- **Distorted Visualizations**: Visuals may show spikes or dips on days without data, misrepresenting patterns and leading to confusion about flight delays.

**Steps creating the specialized Dates table**.

- Opened a Blank Query.
- In the Advanced Editor, I entered the date code:

```ruby
let fnDateTable = (StartDate as date, EndDate as date, FYStartMonth as number) as table =>
  let
    DayCount = Duration.Days(Duration.From(EndDate - StartDate)),
    Source = List.Dates(StartDate,DayCount,#duration(1,0,0,0)),
    TableFromList = Table.FromList(Source, Splitter.SplitByNothing()),   
    ChangedType = Table.TransformColumnTypes(TableFromList,{{"Column1", type date}}),
    RenamedColumns = Table.RenameColumns(ChangedType,{{"Column1", "Date"}}),
    InsertYear = Table.AddColumn(RenamedColumns, "Year", each Date.Year([Date]),type text),
    InsertYearNumber = Table.AddColumn(RenamedColumns, "YearNumber", each Date.Year([Date])),
    InsertQuarter = Table.AddColumn(InsertYear, "QuarterOfYear", each Date.QuarterOfYear([Date])),
    InsertMonth = Table.AddColumn(InsertQuarter, "MonthOfYear", each Date.Month([Date]), type text),
    InsertDay = Table.AddColumn(InsertMonth, "DayOfMonth", each Date.Day([Date])),
    InsertDayInt = Table.AddColumn(InsertDay, "DateInt", each [Year] * 10000 + [MonthOfYear] * 100 + [DayOfMonth]),
    InsertMonthName = Table.AddColumn(InsertDayInt, "MonthName", each Date.ToText([Date], "MMMM"), type text),
    InsertCalendarMonth = Table.AddColumn(InsertMonthName, "MonthInCalendar", each (try(Text.Range([MonthName],0,3)) otherwise [MonthName]) & " " & Number.ToText([Year])),
    InsertCalendarQtr = Table.AddColumn(InsertCalendarMonth, "QuarterInCalendar", each "Q" & Number.ToText([QuarterOfYear]) & " " & Number.ToText([Year])),
    InsertDayWeek = Table.AddColumn(InsertCalendarQtr, "DayInWeek", each Date.DayOfWeek([Date])),
    InsertDayName = Table.AddColumn(InsertDayWeek, "DayOfWeekName", each Date.ToText([Date], "dddd"), type text),
    ChangedType1 = Table.TransformColumnTypes( InsertDayName,{{"QuarternYear", Int64.Type},{"Week Number", Int64.Type},{"Year", type text},{"MonthnYear", Int64.Type}, {"DateInt", Int64.Type}, {"DayOfMonth", Int64.Type}, {"MonthOfYear", Int64.Type}, {"QuarterOfYear", Int64.Type}, {"MonthInCalendar", type text}, {"QuarterInCalendar", type text}, {"DayInWeek", Int64.Type}})

in
    ChangedType1 

in
    fnDateTable
```

 


- After creating a specialized Date table, I **deleted any date-related columns from the *Flights table* to avoid redundancy**. 
 
 ![image](https://github.com/user-attachments/assets/16a5493f-fdf2-4784-9c30-f67505a16338)



## Relational Model - Star Schema 

![image](https://github.com/user-attachments/assets/09504491-d8a0-4410-a493-d9f29dbffef7)

![image](https://github.com/user-attachments/assets/f7cd1014-3ed8-4bfc-9939-f37aa875080a)

