##########################################################
##########################################################
-- Data Cleaning Project: Cyclistic BikeShare
-- Understanding Bike Usage Patterns Among Casual Riders and Members

-- The primary objective of this analysis is to compare the behaviors 
-- of casual riders and members. By doing so, we aim to uncover distinct 
-- patterns that can help us tailor our services to better meet the needs 
-- of these diverse user groups.
##########################################################
##########################################################

-- The data was imported in SQL Server Management Studio, and upon doing so, I managed to change
-- the field names of Trips 2019 Q2 Dataset, so it is the same with other dataset.

#############################
-- 1. Introduction
-- In this task, retrieve data from the four tables in the database
#############################

--Retrieve data from Trips 2019 Q1 table
SELECT *
FROM [SQL PROJECTS].[dbo].[Divvy_Trips_2019_Q1];

--Retrieve data from Trips 2019 Q2 table
SELECT *
FROM [SQL PROJECTS].[dbo].[Divvy_Trips_2019_Q2];

--Retrieve data from Trips 2019 Q3 table
SELECT *
FROM [SQL PROJECTS].[dbo].[Divvy_Trips_2019_Q3];

--Retrieve data from Trips 2019 Q4 table
SELECT *
FROM [SQL PROJECTS].[dbo].[Divvy_Trips_2019_Q4];

#############################
-- 2. UNION
-- In this task, we will use the UNION or UNION ALL keyword to combine all tables into a single table.
#############################

-- Before we use the UNION or UNION ALL keyword, let us first review things to consider in using UNION keywords.
-- First, the number of columns must match. We can see that in the previous query. Second, column names do not 
-- have to match. I modify the column names upon importing for some uniformity purposes. And thirdly, data types
-- must match. Now let us decide what keyword to use, UNION or UNION ALL. The UNION keyword combines the results 
-- of two or more SELECT statements into one output. While, the UNION ALL combines two tables and preserve duplicates.
-- I could have use UNION keyword so that duplicates are instantly removed, but for the sake of exploration i will use
-- UNION ALL to preserve duplicates, besides we can still check the duplicates (no. 4) later on.
SELECT *
FROM [SQL PROJECTS].[dbo].[Divvy_Trips_2019_Q1]
UNION ALL
SELECT *
FROM [SQL PROJECTS].[dbo].[Divvy_Trips_2019_Q2]
UNION ALL
SELECT *
FROM [SQL PROJECTS].[dbo].[Divvy_Trips_2019_Q3]
UNION ALL
SELECT *
FROM [SQL PROJECTS].[dbo].[Divvy_Trips_2019_Q4];

#############################
-- 3. CREATE TABLE
-- We will create a single table with the combine tables previously, including duplicates.
#############################

CREATE TABLE [SQL PROJECTS].[dbo].[Trips_2019] (
	trip_id int,
	start_time datetime2,
	end_time datetime2,
	bikeid smallint,
	tripduration float,
	from_station_id smallint,
	from_station_name nvarchar(50),
	to_station_id smallint,
	to_station_name nvarchar(50),
	usertype nvarchar(50),
	gender nvarchar(50),
	birthyear smallint
	);

-- INSERT INTO
-- We will insert the combined data of Trip from Quarter 1 to Quarter 4.
INSERT INTO [SQL PROJECTS].[dbo].[Trips_2019]
SELECT *
FROM [SQL PROJECTS].[dbo].[Divvy_Trips_2019_Q1]
UNION ALL
SELECT *
FROM [SQL PROJECTS].[dbo].[Divvy_Trips_2019_Q2]
UNION ALL
SELECT *
FROM [SQL PROJECTS].[dbo].[Divvy_Trips_2019_Q3]
UNION ALL
SELECT *
FROM [SQL PROJECTS].[dbo].[Divvy_Trips_2019_Q4];

-- Retrieve the data from combined data Trips 2019 table.
-- This time we filter the query. When quickly viewing a table, it is best to return only a portion of
-- the table instead of the entire table. This executes the query faster than querying the whole table.
-- In other RDBMS, it is called the LIMIT Clause, but in SQL Server MS, we use different syntax with the
-- same functionality.

SELECT TOP 1000 *
FROM [SQL PROJECTS].[dbo].[Trips_2019]

#############################
-- 4. CHECKING DUPLICATES
-- We will return not the entire row, but ROWS with duplicates only, if any.
#############################

SELECT trip_id, COUNT(*) AS num_rows
FROM [SQL PROJECTS].[dbo].[Trips_2019]
GROUP BY trip_id
HAVING COUNT(*) > 1

#############################
-- 5. CHECKING NULL
-- We will check if there is any NULL values in the table.
#############################

SELECT *
FROM [SQL PROJECTS].[dbo].[Trips_2019]
WHERE trip_id IS NULL
	OR start_time IS NULL
	OR end_time IS NULL
	OR bikeid IS NULL
	OR tripduration IS NULL
	OR from_station_id IS NULL
	OR from_station_name IS NULL
	OR to_station_id IS NULL
	OR to_station_name IS NULL
	OR usertype IS NULL
	OR gender IS NULL
	OR birthyear IS NULL;

-- The result of the query above returns a table with lots of NULL values in gender and birthyear column.
-- However, since our primary objective is differentiating how usertype use bikes differently, we can drop
-- gender and birthyear column for they will not be of much use in this analysis. We will do that later on.

#############################
-- 6. CLEANING UP AND ADDING DATA FOR ANALYSIS
-- After checking for duplicates and null values, we will inspect the new table so that we will have an
-- idea on how we are going to clean the table.
#############################

-- Inspecting the usertype and its count.
SELECT usertype, COUNT(*) AS user_count
FROM [SQL PROJECTS].[dbo].[Trips_2019]
GROUP BY usertype

-- Checking tripduration if there are any negative values or errors.
SELECT *
FROM [SQL PROJECTS].[dbo].[Trips_2019]
WHERE tripduration < 0

SELECT to_station_name, COUNT(*) AS count
FROM [SQL PROJECTS].[dbo].[Trips_2019]
GROUP BY to_station_name
-- The result of the query includes a docking station where they took bike out of circulation for quality control. 
-- Preview the rows of bikes under quality control. This will not be included in our analysis because Divvy took it out
-- of circulation.
SELECT *
FROM [SQL PROJECTS].[dbo].[Trips_2019]
WHERE to_station_name LIKE 'HUBB%'

-- Deleting rows with bikes under quality control.
DELETE FROM [SQL PROJECTS].[dbo].[Trips_2019]
WHERE to_station_name LIKE 'HUBB%'

-- Extracting a part of a date or time is very useful in this analysis. Where we are going to create a new column with day,
-- month, and weekday that can be help us provide more opportunities to aggregate the data. We will not include year beacuse
-- we know that all the data is only from year 2019.
-- Create new column out of start time and end time column.
SELECT DAY(start_time) AS Start_Day,
	MONTH(start_time) AS Start_Month,
	DAY(end_time) AS End_Day,
	MONTH(end_time) AS End_Month,
	DATEPART(weekday,start_time) AS start_weekday,
	DATEPART(weekday,end_time) AS end_weekday
FROM [SQL PROJECTS].[dbo].[Trips_2019]

-- ALTER TABLE
-- Create new columns like start and end of day, month, year and weekday.
ALTER TABLE [SQL PROJECTS].[dbo].[Trips_2019]
ADD Start_Day INT,
    Start_Month VARCHAR(15),
    End_Day INT,
    End_Month VARCHAR(15),
    Start_Weekday VARCHAR(15),
    End_Weekday VARCHAR(15);

UPDATE [SQL PROJECTS].[dbo].[Trips_2019]
SET 
	start_day = DAY(start_time),
    start_month = MONTH(start_time),
    end_day = DAY(end_time),
    end_month = MONTH(end_time),
    start_weekday = DATEPART(WEEKDAY, start_time),
    end_weekday = DATEPART(WEEKDAY, end_time);


-- Update some values in the added column to make it more accurate and easy to understand. 
-- This time we will use CASE statement. It is used to apply if-else logic within a query.
-- In our case, i want to change the numeric value of start month, end month, start and end
-- weekday to its equivalent values. To do this, please refer to the query below.
UPDATE [SQL PROJECTS].[dbo].[Trips_2019]
SET start_month =
    CASE 
        WHEN start_month = 1 THEN 'January'
        WHEN start_month = 2 THEN 'February'
        WHEN start_month = 3 THEN 'March'
		WHEN start_month = 4 THEN 'April'
		WHEN start_month = 5 THEN 'May'
		WHEN start_month = 6 THEN 'June'
		WHEN start_month = 7 THEN 'July'
		WHEN start_month = 8 THEN 'August'
		WHEN start_month = 9 THEN 'September'
		WHEN start_month = 10 THEN 'October'
		WHEN start_month = 11 THEN 'November'
		WHEN start_month = 12 THEN 'December'
    END

-- Update end month from numeric to its equivalent values.
UPDATE [SQL PROJECTS].[dbo].[Trips_2019]
SET end_month =
    CASE 
        WHEN end_month = 1 THEN 'January'
        WHEN end_month = 2 THEN 'February'
        WHEN end_month = 3 THEN 'March'
		WHEN end_month = 4 THEN 'April'
		WHEN end_month = 5 THEN 'May'
		WHEN end_month = 6 THEN 'June'
		WHEN end_month = 7 THEN 'July'
		WHEN end_month = 8 THEN 'August'
		WHEN end_month = 9 THEN 'September'
		WHEN end_month = 10 THEN 'October'
		WHEN end_month = 11 THEN 'November'
		WHEN end_month = 12 THEN 'December'
    END

-- Update start weekday from numeric to its equivalent values.
UPDATE [SQL PROJECTS].[dbo].[Trips_2019]
SET start_weekday =
    CASE 
        WHEN start_weekday = 1 THEN 'Sunday'
        WHEN start_weekday = 2 THEN 'Monday'
        WHEN start_weekday = 3 THEN 'Tuesday'
		WHEN start_weekday = 4 THEN 'Wednesday'
		WHEN start_weekday = 5 THEN 'Thursday'
		WHEN start_weekday = 6 THEN 'Friday'
		WHEN start_weekday = 7 THEN 'Saturday'
	END

-- Update end weekday from numeric to its equivalent values.
UPDATE [SQL PROJECTS].[dbo].[Trips_2019]
SET end_weekday =
	CASE
		WHEN end_weekday = 1 THEN 'Sunday'
        WHEN end_weekday = 2 THEN 'Monday'
        WHEN end_weekday = 3 THEN 'Tuesday'
		WHEN end_weekday = 4 THEN 'Wednesday'
		WHEN end_weekday = 5 THEN 'Thursday'
		WHEN end_weekday = 6 THEN 'Friday'
		WHEN end_weekday = 7 THEN 'Saturday'
	END

-- Upon observing, i realized that it could be helpful to add another Season column to explore different use in different seasons.
-- Create new column Season.
ALTER TABLE [SQL PROJECTS].[dbo].[Trips_2019]
ADD Season NVARCHAR(15);

-- Update end weekday from numeric to its equivalent values.
UPDATE [SQL PROJECTS].[dbo].[Trips_2019]
SET Season =
	CASE
		WHEN start_month IN ('January', 'February', 'December')  THEN 'Winter'
        WHEN start_month IN ('March', 'April', 'May') THEN 'Spring'
        WHEN start_month IN ('June', 'July', 'August') THEN 'Summer'
		WHEN start_month IN ('September', 'October', 'November') THEN 'Fall'
	END

-- Checking all columns and arranging it in a meaningful way and on how you want it to be arrange before exporting.
-- This time, i want to do a final cleaning to my data. I want to change the column name of start time and end time to start timestamps and end timestamps
-- and create another column, extracting only time from the timestamps naming it with start time and end time.
SELECT usertype, 
	trip_id,  
	start_time AS start_timestamps,
	CAST(start_time AS TIME) AS start_time,
	start_day, 
	start_weekday, 
	start_month, 
	end_time AS end_timestamps, 
	CAST(end_time AS TIME) AS end_time,
	end_day, 
	end_weekday, 
	end_month,
	season,
	tripduration,
	from_station_name,
	to_station_name
FROM [SQL PROJECTS].[dbo].[Trips_2019]

-- Create a view of your finished dataset.
CREATE VIEW BikeShare AS
SELECT usertype, 
	trip_id,  
	start_time AS start_timestamps,
	CAST(start_time AS TIME) AS start_time,
	start_day, 
	start_weekday, 
	start_month, 
	end_time AS end_timestamps, 
	CAST(end_time AS TIME) AS end_time,
	end_day, 
	end_weekday, 
	end_month,
	season,
	tripduration,
	from_station_name,
	to_station_name
FROM [SQL PROJECTS].[dbo].[Trips_2019]

-- Retrieve the view
SELECT *
FROM BikeShare