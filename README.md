# Airline_Flight_Delay

## ETL

- Extracted the data from 4 CSV files.

![image](https://github.com/user-attachments/assets/16aa4a6e-4f78-4307-9a86-a27cb5be7b37)


🗂️ **1.** **Flights Table**

- Is the Fact Table.
- Total Columns: 31
- Total Rows: 5819079 


### Transformation (Flights Table)

- Kept only the **necessary** collumns.

  ![image](https://github.com/user-attachments/assets/69d4db54-89c3-4218-87c4-fe06fe558c62)

- **Data Integrity:** The dataset is complete, with null values present in two columns: *Departure Delay* and *Cancellation Reason*. **These nulls are expected and meaningful.** They indicate instances where there was no delay or cancellation for the corresponding row, so there’s no need to remove them.

   ![image](https://github.com/user-attachments/assets/0741bcb2-c995-48b0-ae00-7f4efcb5f5cd)


 > [!IMPORTANT]
 > Important to note that null values represent the absence of data, which differs from an empty or blank entry.

 

- Added a new calculated column *Status* : **On Time, Delayed, Cancelled.**

  ![image](https://github.com/user-attachments/assets/a1b55fd9-1418-4bc8-8104-f0f3a9d03686)



🗂️ **2.** **Airlines Table** 

 - Total Columns: 2
 - Total Rows: 15

### Transformation (Airlines Table)
- Upgraded 1st row as header:

  ![image](https://github.com/user-attachments/assets/f2b35cb9-f324-42d7-8a5f-3909f116e430)

🗂️ **3.** **Airports Table** 

 - Total Columns: 7
 - Total Rows: 322

### Transformation (Airlines Table)

- No transformations needed 
