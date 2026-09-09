-- How do annual members and casual riders use Cyclistic bikes differently?
-- type of members
CREATE TABLE type_of_member AS
(
   SELECT MEMBER_CASUAL, count(*) AS amount_of_rides
   FROM tripdata
   GROUP BY MEMBER_CASUAL
   ORDER BY MEMBER_CASUAL, amount_of_rides DESC
);
-- type of rides:
CREATE TABLE type_of_ride AS
(
   SELECT RIDEABLE_TYPE, MEMBER_CASUAL, count(*) AS amount_of_rides
   FROM tripdata
   GROUP BY RIDEABLE_TYPE, MEMBER_CASUAL
   ORDER BY MEMBER_CASUAL, amount_of_rides DESC
);
-- number of rides per month:
CREATE TABLE rides_per_month AS
(
   SELECT MEMBER_CASUAL, MONTH_ABBR, count(*) AS num_of_rides
   FROM tripdata
   GROUP BY MEMBER_CASUAL, MONTH_ABBR
);

-- number of rides per day:
CREATE TABLE rides_per_day AS
(
   SELECT MEMBER_CASUAL, day_of_week, count(*) AS num_of_rides
   FROM tripdata
   GROUP BY MEMBER_CASUAL, day_of_week
);

-- number of rides per hour:
CREATE TABLE rides_per_hour AS
(
   SELECT MEMBER_CASUAL, EXTRACT(HOUR FROM started_at) AS time_of_day, count(*) as num_of_rides
   FROM tripdata
   GROUP BY MEMBER_CASUAL, time_of_day
);

--average length of ride per day:
CREATE TABLE avg_trip_length AS
(
   SELECT MEMBER_CASUAL,
      day_of_week,
      ROUND(AVG(ride_time_minutes), 0) AS avg_ride_time_minutes,
      AVG(AVG(ride_time_minutes)) OVER(PARTITION BY MEMBER_CASUAL) AS combined_avg_ride_time
   FROM tripdata
   GROUP BY MEMBER_CASUAL, day_of_week
);

-- starting docking station location for casuals:
CREATE TABLE start_station_casual AS
(
   SELECT start_station_name,
      start_lat,
      start_lng,
      count(*) AS num_of_rides
   FROM tripdata
   WHERE MEMBER_CASUAL = 'casual' AND start_station_name <> 'On Bike Lock'
   GROUP BY start_station_name, start_lat, start_lng
);

-- starting docking station location for members:
CREATE TABLE start_station_member AS
(
   SELECT start_station_name,
      start_lat,
      start_lng,
      count(*) AS num_of_rides
   FROM tripdata
   WHERE MEMBER_CASUAL = 'member' AND start_station_name <> 'On Bike Lock'
   GROUP BY start_station_name, start_lat, start_lng
);

-- ending docking station name for casuals:
CREATE TABLE end_station_casual AS
(
   SELECT end_station_name,
      end_lat,
      end_lng,
      count(*) AS num_of_rides
   FROM tripdata
   WHERE MEMBER_CASUAL = 'casual' AND end_station_name <> 'On Bike Lock'
   GROUP BY end_station_name, end_lat, end_lng
);

-- ending bike station for members:
CREATE TABLE end_station_member AS
(
   SELECT end_station_name,
      end_lat,
      end_lng,
      count(*) AS num_of_rides
   FROM tripdata
   WHERE MEMBER_CASUAL = 'member' AND end_station_name <> 'On Bike Lock'
   GROUP BY end_station_name, end_lat, end_lng
);

SELECT * FROM type_of_member;
SELECT * FROM type_of_ride;
SELECT * FROM rides_per_month;
SELECT * FROM rides_per_day;
SELECT * FROM rides_per_hour;
SELECT * FROM avg_trip_length;
SELECT * FROM start_station_casual
ORDER BY num_of_rides DESC
LIMIT 5;
SELECT * FROM start_station_member
ORDER BY num_of_rides DESC
LIMIT 5;
SELECT * FROM end_station_casual
ORDER BY num_of_rides DESC
LIMIT 5;
SELECT * FROM end_station_member
ORDER BY num_of_rides DESC
LIMIT 5;

