# Airline Flight Delay

## ETL

###  Extracted the data from 4 CSV files.

![image](https://github.com/user-attachments/assets/16aa4a6e-4f78-4307-9a86-a27cb5be7b37)

I quickly realized that the *Flights table* **was too large**, which was impacting model performance. To address this, I saved the file in **SQL Server**, performed the necessary data cleaning there, and then established a connection between SQL Server and Power BI to import **the cleaned Flights table**.

![image](https://github.com/user-attachments/assets/dd97f4b3-aaac-48b4-8428-758d3ae37924)




### Transformation (Flights Table)

- Is the Fact Table.
- Total Columns: 31
- Total Rows: 5.819.079
- Data cleaning was performed in **SQL Server**.

- Kept only the **necessary** collumns.

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

- **Data Integrity:** The dataset is complete. No Nulls

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

The dataset contained 2 columns with Empty values: 

![image](https://github.com/user-attachments/assets/4df0cbce-96b9-4b21-84f1-8c6080d7af1a)

> [!TIP]
> Quick Observation:

1. **Cancellation Reason**: Out of the total 5,819,079 rows, **5,729,195 were empty**! That is a good thing: The vast majority of flights **did not face cancellations**. 
2. **Departure Delay**: Out of the total 5,819,079 rows, **86,153 were empty**! That is not so a good thing: The vast majority of flights **recorded a departure delay**. Therefore, it suggests that these flights experienced delays. We should later investigate how significant these delays were.



- Added a new calculated column *Status* : **On Time, Delayed, Cancelled.**

  ![image](https://github.com/user-attachments/assets/a1b55fd9-1418-4bc8-8104-f0f3a9d03686)



### Transformation (Airlines Table)

 - Total Columns: 2
 - Total Rows: 15

 - Upgraded 1st row as header:

  ![image](https://github.com/user-attachments/assets/f2b35cb9-f324-42d7-8a5f-3909f116e430)


### Transformation (Airlines Table)

 - Total Columns: 7
 - Total Rows: 322

 - No transformations needed

### Transformation (Cancelation Codes Table)

 - Total Columns: 2
 - Total Rows: 5

 - Upgraded 1st row as header:

### 💡 Adding a Seperate Date Table (*A decision made solely by the project author*) 💡

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
    ChangedType1 = Table.TransformColumnTypes( InsertDayName,{{"QuarternYear", Int64.Type},{"Week Number", Int64.Type},{"Year", type text},{"MonthnYear", Int64.Type}, {"DateInt", Int64.Type}, {"DayOfMonth", Int64.Type}, {"MonthOfYear", Int64.Type}, {"QuarterOfYear", Int64.Type}, {"MonthInCalendar", type text}, {"QuarterInCalendar", type text}, {"DayInWeek", Int64.Type}}),
    InsertShortYear = Table.AddColumn(ChangedType1, "ShortYear", each Text.End(Text.From([Year]), 2), type text),
    AddFY = Table.AddColumn(InsertShortYear, "FY", each "FY"&(if [MonthOfYear]>=FYStartMonth then Text.From(Number.From([ShortYear])+1) else [ShortYear]))
in
    AddFY
in
    fnDateTable
```

  ![image](https://github.com/user-attachments/assets/4d71b154-5401-486d-a44b-304a6eb597ed)

- Applied Futher transformations within the *Date table*.  

 ![image](https://github.com/user-attachments/assets/49174447-7993-4dad-9252-d2c0e75b4806)


- **After creating a specialized Date table, I made additional transformations in the Fact table: *Flights***

1. Merged the Date column from the Date table into the Flights table. **Reason:** This was done to ensure that both tables have common data for establishing the relationship later.
 
 ![image](https://github.com/user-attachments/assets/5238a505-0578-4d25-9092-1e0e54365f0b)

 ![image](https://github.com/user-attachments/assets/83b53c15-b04b-466b-a49b-56f6004fab08)

  2. Deleted any date-related columns from the *Flights table* to avoid redundancy. 
 
 ![image](https://github.com/user-attachments/assets/16a5493f-fdf2-4784-9c30-f67505a16338)

### Load 

![image](https://github.com/user-attachments/assets/aa1c9f83-1359-487d-9eb7-db8a89cbaf54)

## Relational Model - Star Schema 

![image](https://github.com/user-attachments/assets/09504491-d8a0-4410-a493-d9f29dbffef7)


