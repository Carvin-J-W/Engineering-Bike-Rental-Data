Create Table weather_data(
id integer PRIMARY KEY,
station varchar(100),
name varchar(200),
date DATE NOT NULL,
AWND float,
PRCP float,
SNOW float,
SNWD float,
TAVG integer,
TMAX integer, 
TMIN integer,
WDF2 integer,
WDF5 float,
WSF2 float,
WSF5 float,
UNIQUE(station, date)
); 

-- GROUP BY would not work with integer data type. In retrospect, will consider making all integers needed for analytics DOUBLE PRECISION or NUMERIC
ALTER TABLE weather_data
ALTER COLUMN tavg TYPE DOUBLE PRECISION;

-- Needed Postgre to make the primary key column
ALTER TABLE weather_data
ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY;

-- This is part of the orginal table relationship schema which I dropped (see write-up for reasons). 
CREATE TABLE main_bike_data(
main_id integer PRIMARY KEY,
trip_duartion integer,
bike_id integer,
user_type char(50),
birth_year integer,
gender integer
);

-- Same story has above, this table was part of the orginal schema. 
CREATE TABLE bike_trip_data(
trip_id integer PRIMARY KEY,
main_id integer REFERENCES main_bike_data(main_id),
start_time TIMESTAMP,
stop_time TIMESTAMP,
start_station_id integer,
start_station_name varchar(200),
start_station_latitude DOUBLE PRECISION,
start_station_longitude DOUBLE PRECISION,
end_station_id integer,
end_station_name varchar(200),
end_station_latitude DOUBLE PRECISION,
end_station_longitude DOUBLE PRECISION
);

DROP TABLE IF EXISTS main_bike_data, bike_trip_data;


-- This table is 'The' current relational table used in the running schema. 
CREATE TABLE bike_rental_data(
id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
trip_duartion integer,
start_time TIMESTAMP,
stop_time TIMESTAMP,
start_station_id integer,
start_station_name varchar(200),
start_station_latitude DOUBLE PRECISION,
start_station_longitude DOUBLE PRECISION,
end_station_id integer,
end_station_name varchar(200),
end_station_latitude DOUBLE PRECISION,
end_station_longitude DOUBLE PRECISION,
bike_id integer,
user_type char(50),
birth_year integer,
gender integer
);

ALTER TABLE bike_rental_data
RENAME COLUMN trip_duartion TO trip_duration;

SELECT * FROM weather_data
LIMIT 10;

SELECT * FROM bike_rental_data
LIMIT 10;

CREATE VIEW daily_trip_summary AS
SELECT DATE(start_time) AS trip_date,
	COUNT(*) AS total_trip,
		ROUND(AVG(trip_duration),2) AS avg_trip_duration
FROM bike_rental_data
GROUP BY DATE(start_time); 

SELECT * 
FROM daily_trip_summary
LIMIT 100;

CREATE VIEW user_type_summary AS 
SELECT user_type,
	COUNT(*) AS total_trip,
		ROUND(AVG(trip_duration),2) AS avg_trip_duration
FROM bike_rental_data
GROUP BY user_type; 

SELECT * 
FROM user_type_summary
LIMIT 100;

CREATE OR REPLACE VIEW daily_trip_weather_summary AS 
SELECT DATE(b.start_time) AS trip_date,
	COUNT(*) AS total_trip,
		w.awnd AS average_wind_speed,
			w.prcp AS daily_percipitation,
				w.tavg AS temperature_average
FROM bike_rental_data AS b
LEFT JOIN weather_data AS w
ON DATE(b.start_time) = w.date
GROUP BY 
DATE(b.start_time),
w.awnd,
w.prcp,
w.tavg
ORDER BY DATE(b.start_time);

SELECT * 
FROM daily_trip_weather_summary
LIMIT 20;


-- This query was a confirmation that AVG(tavg) would give accurate analytics. Though, instead of aggregating (weather) columns in the daily_trip_weather_summary I used GROUP BY.
SELECT date, 
	AVG(tavg)
FROM weather_data
GROUP BY date
ORDER BY date 
LIMIT 10;

