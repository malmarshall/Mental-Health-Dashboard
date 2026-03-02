-- Generate global OWID table for general data analysis 

--DROP TABLE IF EXISTS global_owid; (used to drop the table if it already exists to avoid errors when running the script multiple times)

CREATE TABLE global_owid

(
    ENTITY TEXT,
    CODE TEXT,
    YEAR INT,
    anx_dep FLOAT
);

-- Insert data into global_owid table from the original OWID dataset

COPY global_owid
FROM '/workspaces/Mental-Health-Dashboard/data/global_owid.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- Run query to check the first 10 rows of the global_owid table

SELECT *
FROM global_owid
LIMIT 10;

--Exploration of data and assessment of null values (will rename null values in this column as they have an associated anx_dep value)

SELECT *
FROM global_owid
WHERE code IS NULL;

-- Renames null values in code column 

UPDATE global_owid
SET code = CASE
    WHEN entity = 'Africa' THEN 'AFR'
    WHEN entity = 'Asia' THEN 'ASIA'
    WHEN entity = 'Europe' THEN 'EUR'
    WHEN entity = 'North America' THEN 'NA'
    WHEN entity = 'South America' THEN 'SA'
    WHEN entity = 'Oceania' THEN 'OCE'
    WHEN entity = 'High-income countries' THEN 'HIC'
    WHEN entity = 'Low-income countries' THEN 'LIC'
    WHEN entity = 'Lower-middle-income countries' THEN 'LMIC'
    WHEN entity = 'Upper-middle-income countries' THEN 'UMIC'
    ELSE code
END
WHERE code IS NULL;

--Adds a primary key to the global_owid table for better data integrity and to facilitate efficient querying and analysis in the Mental Health Dashboard.

ALTER TABLE global_owid
ADD COLUMN id SERIAL PRIMARY KEY;

-- Assess anx_dep column to determine if they are percentages or raw numbers and convert if necessary (did not convert in mhcare table so will not convert in this one to allow uniformity)

SELECT 
    MIN (anx_dep) AS min_anx_dep,
    MAX (anx_dep) AS max_anx_dep
FROM global_owid;

--Adds not null constraint to the column to ensure that all records have a valid year value for accurate analysis and comparison with the indicators_cdc table and mh_care table in the Mental Health Dashboard.

ALTER TABLE global_owid
ALTER COLUMN entity SET NOT NULL,
ALTER COLUMN year SET NOT NULL,
ALTER COLUMN anx_dep SET NOT NULL;

-- Final check of the global_owid table after all transformations and cleaning steps to ensure that the data is ready for analysis and visualization in the Mental Health Dashboard.

SELECT *
FROM global_owid
ORDER BY year DESC, anx_dep DESC;
