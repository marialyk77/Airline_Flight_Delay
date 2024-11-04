# Airline Flight Delay

## ETL

###  Extracted the data from 4 CSV files.

![image](https://github.com/user-attachments/assets/16aa4a6e-4f78-4307-9a86-a27cb5be7b37)




### Transformation (Flights Table)

- Is the Fact Table.
- Total Columns: 31
- Total Rows: 5819079 

- Kept only the **necessary** collumns.

  ![image](https://github.com/user-attachments/assets/69d4db54-89c3-4218-87c4-fe06fe558c62)

- **Data Integrity:** The dataset is complete, with null values present in two columns: *Departure Delay* and *Cancellation Reason*. **These nulls are expected and meaningful.** They indicate instances where there was no delay or cancellation for the corresponding row, so there’s no need to remove them.

   ![image](https://github.com/user-attachments/assets/0741bcb2-c995-48b0-ae00-7f4efcb5f5cd)


 > [!IMPORTANT]
 > Important to note that null values represent the absence of data, which differs from an empty or blank entry.

 

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


