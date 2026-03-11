-- Generate mh_care_cdc for data analysis

-- DROP TABLE IF EXISTS mh_care_cdc; (used to drop the table if it already exists to avoid errors when running the script multiple times)

CREATE TABLE mh_care_cdc
(
    indicator VARCHAR(255),
    "group" VARCHAR(255),
    state VARCHAR(255),
    subgroup VARCHAR(255),
    phase VARCHAR(255),
    time_period VARCHAR(255),
    time_period_label VARCHAR(255),
    time_start DATE,
    time_end DATE,
    value VARCHAR(255),
    low_ci VARCHAR(255),
    high_ci VARCHAR(255),
    con_int VARCHAR(255),
    quart_range VARCHAR(255),
    supp_flag VARCHAR(255)
);

-- Insert data into mh_care_cdc table from the CDC dataset
COPY mh_care_cdc
FROM '/workspaces/Mental-Health-Dashboard/data/mh_care_cdc.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8', NULL '');

-- Run query to check the first 10 rows of the cdc mental health care table
SELECT *
FROM mh_care_cdc
LIMIT 10;

--Adds a primary key to the mh_care_cdc for better data integrity and to facilitate efficient querying and analysis in the Mental Health Dashboard.

ALTER TABLE mh_care_cdc
ADD COLUMN id SERIAL PRIMARY KEY;

-- Removal of null values and exploration of data

SELECT *
FROM mh_care_cdc
WHERE phase = '-1';

DELETE FROM mh_care_cdc
WHERE phase = '-1';

SELECT *
FROM mh_care_cdc
WHERE value IS NULL;

DELETE FROM mh_care_cdc
WHERE value IS NULL;

SELECT *
FROM mh_care_cdc;

ALTER TABLE mh_care_cdc
DROP COLUMN supp_flag, 
DROP COLUMN phase,
DROP COLUMN con_int,
DROP COLUMN time_start,
DROP COLUMN time_end,
DROP COLUMN time_period,
DROP COLUMN state;

ALTER TABLE mh_care_cdc
RENAME COLUMN "group" TO demo_group;

ALTER TABLE mh_care_cdc
ALTER COLUMN low_ci TYPE double precision USING low_ci::double precision,
ALTER COLUMN high_ci TYPE double precision USING high_ci::double precision,
ALTER COLUMN value TYPE double precision USING value::double precision;

SELECT *
FROM mh_care_cdc
ORDER BY value DESC;

-- Change time_period_label to year for easier comparison with indicators_cdc table

ALTER TABLE mh_care_cdc
ADD COLUMN year INTEGER;

UPDATE mh_care_cdc
SET year = RIGHT(time_period_label, 4)::INTEGER;

--Drops time_period_label column as it is no longer needed after extracting the year for comparison with indicators_cdc table.
ALTER TABLE mh_care_cdc
DROP COLUMN time_period_label;

--Adds not null constraint to the column to ensure that all records have a valid year value for accurate analysis and comparison with the indicators_cdc table in the Mental Health Dashboard.

ALTER TABLE mh_care_cdc
ALTER COLUMN indicator SET NOT NULL,
ALTER COLUMN demo_group SET NOT NULL,
ALTER COLUMN value SET NOT NULL;

-- Determine if ci values are percentages and convert if necessary

SELECT 
    MIN(value) AS min_val,
    MAX(value) AS max_val,
    MIN(low_ci) AS min_ci,
    MAX(high_ci) AS max_ci
FROM mh_care_cdc;

-- Checks for duplicates in the mh_care_cdc to ensure data integrity and to identify any potential issues with duplicate records that may affect analysis and visualization in the Mental Health Dashboard.

SELECT indicator, demo_group, subgroup, time_period_label, COUNT(*)
FROM mh_care_cdc
GROUP BY indicator, demo_group, subgroup, time_period_label
HAVING COUNT(*) > 1;

-- Final check of the mh_care_cdc after all transformations and cleaning steps to ensure that the data is ready for analysis and visualization in the Mental Health Dashboard.

SELECT *
FROM mh_care_cdc
ORDER BY year DESC, value DESC;

