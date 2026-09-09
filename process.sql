/*
#1. Classic bikes have to start/end at a docking station
ALSO remove rows that do not have a starting/ending latitude and longitude
remove trips with less than 1-minute duration or more than 1-day duration
*/

DELETE FROM tripdata
where LENGTH(ride_id)=7;

DELETE FROM tripdata
WHERE RIDEABLE_TYPE = 'classic_bike' AND
      START_STATION_NAME IS NULL OR
      END_STATION_NAME IS NULL;

DELETE FROM tripdata
WHERE START_LAT IS NULL OR
      END_LAT IS NULL;

DELETE FROM tripdata
WHERE "TIMESTAMPDIFF"(minute ,STARTED_AT , ENDED_AT) <= 1 OR
      "TIMESTAMPDIFF"(minute ,STARTED_AT , ENDED_AT) >= 1440;

/*
#2. Clean up station names,fill null station names with 'On Bike Lock' as these are occurrences when
the customer used the bike lock on the electric bike instead of docking it,and create date/ride-time columns
*/

UPDATE tripdata
SET
    start_station_name = COALESCE(TRIM(REPLACE(start_station_name, '(Temp)', '')), 'On Bike Lock'),
    end_station_name = COALESCE(TRIM(REPLACE(end_station_name, '(Temp)', '')), 'On Bike Lock');

-- Add the column
ALTER TABLE tripdata ADD COLUMN day_of_week VARCHAR(4);

-- Update with day names
UPDATE tripdata
SET day_of_week =
    CASE
        WHEN DAYOFWEEK(started_at) = 1 THEN 'Sun'
        WHEN DAYOFWEEK(started_at) = 2 THEN 'Mon'
        WHEN DAYOFWEEK(started_at) = 3 THEN 'Tues'
        WHEN DAYOFWEEK(started_at) = 4 THEN 'Wed'
        WHEN DAYOFWEEK(started_at) = 5 THEN 'Thur'
        WHEN DAYOFWEEK(started_at) = 6 THEN 'Fri'
        WHEN DAYOFWEEK(started_at) = 7 THEN 'Sat'
    END;

-- Add the column
ALTER TABLE tripdata ADD COLUMN month_abbr VARCHAR(4);

-- Update with month abbreviations
UPDATE tripdata
SET month_abbr =
    CASE
        WHEN MONTH(started_at) = 1 THEN 'Jan'
        WHEN MONTH(started_at) = 2 THEN 'Feb'
        WHEN MONTH(started_at) = 3 THEN 'Mar'
        WHEN MONTH(started_at) = 4 THEN 'Apr'
        WHEN MONTH(started_at) = 5 THEN 'May'
        WHEN MONTH(started_at) = 6 THEN 'Jun'
        WHEN MONTH(started_at) = 7 THEN 'Jul'
        WHEN MONTH(started_at) = 8 THEN 'Aug'
        WHEN MONTH(started_at) = 9 THEN 'Sep'
        WHEN MONTH(started_at) = 10 THEN 'Oct'
        WHEN MONTH(started_at) = 11 THEN 'Nov'
        ELSE 'Dec'
    END;

-- Add the column
ALTER TABLE tripdata ADD COLUMN ride_time_minutes INT;

-- Calculate and update duration in minutes
UPDATE tripdata
SET ride_time_minutes = TIMESTAMPDIFF('MINUTE', started_at, ended_at);


SELECT * FROM tripdata LIMIT 10;

SELECT COUNT(*) FROM tripdata;


-- from 5,597,041 rows to 4,412,703 rows