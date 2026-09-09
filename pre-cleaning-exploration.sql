CREATE TABLE tripdata AS
SELECT * FROM CSVREAD('tripdata.csv');

drop table tripdata;

SELECT *
FROM tripdata
LIMIT 20;

SELECT COUNT(*)
FROM tripdata;

/* NOTES:
The table contains 5,597,041 row.

---------------Analyze all columns from left to right for cleaning----------------------------------------------

#1.ride_id:
- check length combinations for ride_id
- and all values are unique as ride_id is a primary key
*/

SELECT LENGTH(ride_id), count(*)
FROM tripdata
GROUP BY LENGTH(ride_id);

SELECT COUNT (DISTINCT ride_id)
FROM tripdata;

/* NOTES:
All ride_id strings are 16 characters long, and they are all distinct except for 11 rows that have 7 characters these rows represent
the headers of each table used in the fusion to create the finale 1 year long table.
*/

--#2. check the allowable rideable_types

SELECT DISTINCT rideable_type
FROM tripdata;

/* NOTES:
As seen above, there are 3 types of 'rideable_type':
electric_bike, classic_bike, electric_scooter.
*/

/*
#3. Check started_at and ended_at columns.
We only want the rows where the time length of the ride was longer than one minute,
but shorter than one day.
*/

SELECT count(*)
FROM tripdata
WHERE TIMESTAMPDIFF(MINUTE,
      PARSEDATETIME(started_at, 'yyyy-MM-dd HH:mm:ss'),
      PARSEDATETIME(ended_at, 'yyyy-MM-dd HH:mm:ss')) <= 1
   OR TIMESTAMPDIFF(MINUTE,
      PARSEDATETIME(started_at, 'yyyy-MM-dd HH:mm:ss'),
      PARSEDATETIME(ended_at, 'yyyy-MM-dd HH:mm:ss')) >= 1440;

/*
#4. Check the start/end station name/id columns for naming inconsistencies
*/

SELECT start_station_name, count(*)
FROM tripdata
GROUP BY start_station_name
ORDER BY start_station_name;

SELECT end_station_name, count(*)
FROM tripdata
GROUP BY end_station_name
ORDER BY end_station_name;

SELECT COUNT(DISTINCT(start_station_name)) AS unq_startname,
   COUNT(DISTINCT(end_station_name)) AS unq_endname,
   COUNT(DISTINCT(start_station_id)) AS unq_startid,
   COUNT(DISTINCT(end_station_id)) AS unq_endid
FROM tripdata;

/*
Start and end station names need to be cleaned up:
 -Remove leading and traling spaces.
 -Remove substrings '(Temp)' as Cyclisitc uses these substrings when repairs
  are happening to a station. All station names should have the same naming conventions.
 -Start and end station id columns have many naming convention errors and different string lengths.
  As they do not offer any use to the analysis and there is no benefit to cleaning them, they will be ignored.
*/

/*
#5. Check NULLS in start and end station name columns
*/

SELECT rideable_type, count(*) as num_of_rides
FROM tripdata
WHERE start_station_name IS NULL AND start_station_id IS NULL OR
    end_station_name IS NULL AND end_station_id IS NULL
GROUP BY rideable_type;

/*
Classic_bikes/docked_bikes will always start and end their trip locked in a docking station,
but electric bikes have more versatility. Electric bikes can be locked up using their bike lock
in the general vicinity of a docking station; thus, trips do not have to start or end at a station.
As such we will do the following:
- remove classic/docked bike trips that do not have a start or end station name and have no start/end station id to use to fill in the null.
- change the null station names to 'On Bike Lock' for electric bikes
*/

--#6. Check rows where latitude and longitude are null

SELECT *
FROM tripdata
WHERE start_lat IS NULL OR
 start_lng IS NULL OR
 end_lat IS NULL OR
 end_lng IS NULL;

-- NOTE: we will remove these rows as all rows should have location points

/*
#7. Confirm that there are only 2 member types in the member_casual column:
*/

SELECT DISTINCT member_casual
FROM tripdata

--NOTE: Yes the only values in this field are 'member' or 'casual'