-- Generate indicators_cdc for CDC data analysis

--DROP TABLE IF EXISTS indicators_cdc; (used to drop the table if it already exists to avoid errors when running the script multiple times)

CREATE TABLE indicators_cdc
(
    year INT,
    loc VARCHAR(255),
    question VARCHAR(512),
    response BOOLEAN,
    break_out VARCHAR(255),
    data_value FLOAT,
    low_ci FLOAT,
    high_ci FLOAT
);

-- Insert data into indicators_cdc table from the CDC dataset
COPY indicators_cdc
FROM '/workspaces/Mental-Health-Dashboard/data/indicators_cdc.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- Run query to check the first 10 rows of the cdc indicators table

SELECT *
FROM indicators_cdc
LIMIT 50;

-- Exploration and cleaning of data

SELECT DISTINCT year, question 
FROM indicators_cdc
ORDER BY year DESC;

ALTER TABLE indicators_cdc
DROP COLUMN question;

SELECT *
FROM indicators_cdc
WHERE break_out = 'Overall'
AND response = true;

SELECT * 
FROM indicators_cdc
WHERE year = 2020 AND data_value IS NOT NULL;

-- Checks for duplicates in the data

SELECT year, loc, break_out, response, COUNT(*)
FROM indicators_cdc
GROUP BY year, loc, break_out, response
HAVING COUNT(*) > 1;

--Adds a primary key to the indicators_cdc table for better data integrity and to facilitate efficient querying and analysis in the Mental Health Dashboard.

ALTER TABLE indicators_cdc
ADD COLUMN id SERIAL PRIMARY KEY;

--Checks for null values in the data_value column to ensure data quality and to identify any potential issues with the dataset that may need to be addressed before further analysis.

SELECT *
FROM indicators_cdc
WHERE data_value IS NULL;

DELETE FROM indicators_cdc
WHERE data_value IS NULL;

SELECT DISTINCT response 
FROM indicators_cdc;

--Standardizes columns to match data from other tables and to facilitate easier analysis and comparison across datasets in the Mental Health Dashboard.

ALTER TABLE indicators_cdc
RENAME COLUMN loc TO state;

ALTER TABLE indicators_cdc
RENAME COLUMN break_out TO demo_group;

ALTER TABLE indicators_cdc
RENAME COLUMN data_value TO value;

ALTER TABLE indicators_cdc
RENAME COLUMN question TO indicator;

-- Adds not null constraint to the column to ensure that all records have a valid value for accurate analysis and comparison with other tables in the Mental Health Dashboard.

ALTER TABLE indicators_cdc
ALTER COLUMN value SET NOT NULL;

--Final check of the indicators_cdc table after cleaning and standardization to ensure that the data is ready for analysis and visualization in the Mental Health Dashboard.

SELECT *
FROM indicators_cdc
ORDER BY year DESC, value;

