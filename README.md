# Airline Flight Delay


## Project Overview

- For this project, I used flight data from Maven Analytics, specifically following the Maven Crash Course as a starting point (https://mavenanalytics.io/crash-courses/go-from-data-to-dashboard-in-15-minutes-in-power-bi). 

- While the course provided a strong starting point, I implemented additional, more advanced techniques to refine the data, improve organization, and enhance the user experience with insightful visualizations.

## Key Enhancements and Deviations from the Original Course 

**1. Data Cleaning with SQL Server.**
   
   Reason: The dataset was too large, which negatively impacted Power BI's performance. Through thorough cleaning, I discovered that the Flights table only had data for the first 7 days of each month.
   
**2. Addition of one more table to the model with the use of Dax.**
   
   Reason: To include the day name in the Bar Graph of cancellation rates for each day of the week. The additional table enabled better sorting of the days.
   
**3. Created a specialized Measures Table with one subfolder.**
  
   Reason: Measures used to build the visuals were organized into a subfolder for better structure.
   
**4. Applied Conditional Formatting to the Bar Graph.**
   
   Reason: Conditional formatting was used to highlight bars that exceeded a specific threshold value, using different colors.

**5. Customized Clustered Bar Chart with Advanced Labels.**

   Reason: This customization improved visibility and reduced clutter on the chart.

**6. Designed a pop-up panel.**

   Reason: The pop-up panel was designed to enhance usability and emphasize key insights.

## Questions 

1. What is the overall performance of flights, in terms of delays and cancellations?

2. What are the key factors contributing to flight cancellations?

3. Are there patterns in flight delays or cancellations by day of the week?

## Summary of Insights 

- **Total Flights**: 5.8 M

- **On- Time rate**: 62%

- **Delayed rate**: 36.5%

- **Cancellation rate**: 1.5%

- **Busiest Month**: July

- **Most Delays occur in**: June

- **Cancellation reason is**: Weather

- **Busiest Airport is**: Chicago

- **Top Airline**: United Air Lines Inc.

## Suggestions for Improvement:

1. Weather-related delays might benefit from improved predictive measures or alternative routing where possible.

2. Analyze weekday travel trends to optimize staffing and resources on days with the highest demand.


## Tools Used

SQL Server, Power BI

## ETL

###  Extracted the data from 4 CSV files.

The files contain data from 2015. 

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



## Relational Model - Star Schema 

![image](https://github.com/user-attachments/assets/09504491-d8a0-4410-a493-d9f29dbffef7)

![image](https://github.com/user-attachments/assets/524b2456-3e69-4947-be30-9eb1dfc1a7cf)

- Later, when building the dashboard, I chose to create a bar graph showing the **Day Name** against the cancellation rate (*rather than using the Day of the Week number*).
- I added **a separate Day of Week table** to the model using DAX. And utilized the Day Name column, sorted properly for my vizualization. 

```ruby
DayOfWeekSortTable = 
DATATABLE(
    "Day Name", STRING,
    "Sort Order", INTEGER,
    {
        {"Mon", 1},
        {"Tue", 2},
        {"Wed", 3},
        {"Thu", 4},
        {"Fri", 5},
        {"Sat", 6},
        {"Sun", 7}
    }
)
```
  
- Final Model:

![image](https://github.com/user-attachments/assets/8f6bb873-1991-4ed0-90e7-5de117ddc16d)




















