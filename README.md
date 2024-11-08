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

## Data source 

4 Csv files with flight data from 2015.  

![image](https://github.com/user-attachments/assets/16aa4a6e-4f78-4307-9a86-a27cb5be7b37)



## Flights Table

- Challenges Encountered

The Flights table was too large, which impacted performance and efficiency during analysis in Power BI.

To address this, I chose to perform data cleaning and transformation in SQL Server directly, rather than within Power BI, for improved processing speed. 💡 (*A decision made solely by the project author*) 💡

![image](https://github.com/user-attachments/assets/dd97f4b3-aaac-48b4-8428-758d3ae37924)

### ETL

**1. Extract**

The data was extracted from the original dbo.flights table in SQL Server, which contained:
- Columns: 31
- Rows: 5,819,079
- Table Type: This is the Fact Table in the data model, as it holds core flight data (e.g., departure details, airline info, delays).


**2. Transform**

Data Cleaning and Filtering in **SQL Server**:

Selected only the necessary columns to create a more efficient dataset focused on relevant information, which I called: dbo.FilteredFlights.

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
**Result**: By reducing the data in SQL Server, I was able to create a clean and manageable dataset.

### EDA


- 📝 **Data Integrity:** Ensured that the dataset had no null values.

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

- 📝 **Data Completeness:** Identified 2 columns with missing values. 

![image](https://github.com/user-attachments/assets/4df0cbce-96b9-4b21-84f1-8c6080d7af1a)

> [!TIP]
> Quick Observation:

1. **Cancellation Reason**: Out of the total 5,819,079 rows, **5,729,195 were empty**! That is a good thing: The vast majority of flights **did not face cancellations**. 
2. **Departure Delay**: Out of the total 5,819,079 rows, **86,153 were empty**! That is not so a good thing: The vast majority of flights **recorded a departure delay**. Therefore, it suggests that these flights experienced delays. We should later investigate how significant these delays were.

### Data Transformation for Analysis

- 📝 Adding a **Date Column**: Created a new *FullDate* column by combining Year, Month, and Day_of_Week.
  
```ruby
ALTER TABLE dbo.FilteredFlights
ADD FullDate DATE;

UPDATE dbo.FilteredFlights
SET FullDate = CAST(CONCAT(YEAR, '-', MONTH, '-', DAY_OF_WEEK) AS DATE);

```
- 📝 Checking **Distinct Dates**: Analyzed the distinct dates in the *FullDate* column to assess temporal coverage.

```ruby
SELECT 
    COUNT(DISTINCT FullDate) AS DistinctDateCount
FROM 
    dbo.FilteredFlights;
```
**Result:** Only 84 distinct days are recorded, indicating that the dataset does not cover the entire year.

![image](https://github.com/user-attachments/assets/12018294-ff20-42c3-8465-b5341832c1f3)


- 📝 Analyzing **Records Per Date**: Further analyzed data by checking the number of records per date to identify any patterns or gaps.

```ruby
SELECT FullDate, COUNT(*) AS RecordsPerDate
FROM dbo.FilteredFlights
GROUP BY FullDate
ORDER BY FullDate;
```

**Result:** The current dataset contains data only for **THE FIRST 7 DAYS OF EACH MONTH!**.

![image](https://github.com/user-attachments/assets/1337b0b4-3444-40b9-b54e-a1ed08c9135a)



- 📝 Adding a **Status Column**: Created a calculated column Status to categorize flights as "On Time," "Delayed," or "Cancelled."

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


### LOAD 

- **Connecting Power BI to SQL Server**: After preparing the FilteredFlights table in SQL Server, I connected Power BI to SQL Server to import the clean data.

**Using a Parameter for Connection**: I set up the connection using a parameter to define the SQL Server source. While this level of flexibility isn’t strictly necessary for this project, I included it as an opportunity to practice parameterization, which can improve scalability and maintainability in larger or more complex projects.
I established the connection between Power BI and SQL Server using a parameter. I know it might be a bit of an exaggeration for this project, but I'm always happy to practice my skills.

![image](https://github.com/user-attachments/assets/ff657b7d-b7e7-4961-9760-fa787563ae6a)



## Airlines Table

 - Total Columns: 2
 - Total Rows: 15
 - Data cleaning was performed in **Power BI**.

 - Upgraded 1st row as header:

  ![image](https://github.com/user-attachments/assets/f2b35cb9-f324-42d7-8a5f-3909f116e430)


## Airlines Table

 - Total Columns: 7
 - Total Rows: 322
 - Data cleaning was performed in **Power BI**.

 - No transformations needed

## Cancelation Codes Table

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


## Explanatory Analysis 

For the current project, the **Explanatory Analysis** involved the following key performance indicators (KPIs):

**1. Total Flights**

- Breakdown: Total Flights by Month

- Result: 5.8 million flights in total, with July being the busiest month.

**2. Total Delayed Flights**

- Breakdown: Delayed Flights by Month
- Result: 2.1 million delayed flights, with June experiencing the most delays.
  
**3. Total Cancellations**

Breakdown: Cancellations by Month
Result: 89.9 thousand cancellations, with February having the highest number of cancellations.


















