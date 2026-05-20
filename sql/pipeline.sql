-- Chipotle vs McDonalds: Financial Performance Analysis
-- Data Source: SEC 10-K filings (2016–2024)
-- Purpose: Clean and transform income statement data for Tableau visualization

-- Here we rename select columns so that they match across all tables.
-- Comment out after they are run exactly once.
/*
ALTER TABLE Chipotle_2016_2018 RENAME COLUMN "Consolidated Statement of Income - USD ($) shares in Thousands, $ in Thousands" TO Metric;
ALTER TABLE Chipotle_2019_2021 RENAME COLUMN field1 TO Metric;
ALTER TABLE Chipotle_2022_2024 RENAME COLUMN field1 TO Metric;
ALTER TABLE McDonalds_2016_2018 RENAME COLUMN "Consolidated Statement of Income - USD ($) shares in Millions, $ in Millions" TO Metric;
ALTER TABLE McDonalds_2019_2021 RENAME COLUMN "Consolidated Statement of Income - USD ($) shares in Millions, $ in Millions" TO Metric;
ALTER TABLE McDonalds_2022_2024 RENAME COLUMN "Consolidated Statement of Income - USD ($) $ in Millions" TO Metric;

*/

-- Create Chipotle Views
DROP VIEW IF EXISTS Chipotle_View_2016_2018;
DROP VIEW IF EXISTS Chipotle_View_2019_2021;
DROP VIEW IF EXISTS Chipotle_View_2022_2024;

CREATE VIEW Chipotle_View_2016_2018 AS
SELECT
	'Chipotle' AS Company,
	2016 AS Year,
	Metric,
	"Dec. 31, 2016" AS Value
FROM Chipotle_2016_2018

UNION ALL

SELECT
	'Chipotle' AS Company,
	2017 AS Year,
	Metric,
	"Dec. 31, 2017" AS Value
FROM Chipotle_2016_2018

UNION ALL

SELECT
	'Chipotle' AS Company,
	2018 AS Year,
	Metric,
	"Dec. 31, 2018" AS Value
FROM Chipotle_2016_2018;

CREATE VIEW Chipotle_View_2019_2021 AS
SELECT
	'Chipotle' AS Company,
	2019 AS Year,
	Metric,
	"Dec. 31, 2019" AS Value
FROM Chipotle_2019_2021

UNION ALL

SELECT
	'Chipotle' AS Company,
	2020 AS Year,
	Metric,
	"Dec. 31, 2020" AS Value
FROM Chipotle_2019_2021

UNION ALL

SELECT
	'Chipotle' AS Company,
	2021 AS Year,
	Metric,
	"Dec. 31, 2021" AS Value
FROM Chipotle_2019_2021;

CREATE VIEW Chipotle_View_2022_2024 AS
SELECT
	'Chipotle' AS Company,
	2022 AS Year,
	Metric,
	"Dec. 31, 2022" AS Value
FROM Chipotle_2022_2024

UNION ALL

SELECT
	'Chipotle' AS Company,
	2023 AS Year,
	Metric,
	"Dec. 31, 2023" AS Value
FROM Chipotle_2022_2024

UNION ALL

SELECT
	'Chipotle' AS Company,
	2024 AS Year,
	Metric,
	"Dec. 31, 2024" AS Value
FROM Chipotle_2022_2024;

-- Combine Chipotle Views
DROP VIEW IF EXISTS Chipotle_All;
CREATE VIEW Chipotle_All AS
SELECT * FROM Chipotle_View_2016_2018
UNION ALL
SELECT * FROM Chipotle_View_2019_2021
UNION ALL
SELECT * FROM Chipotle_View_2022_2024;

-- Create McDonald's Views
DROP VIEW IF EXISTS McDonalds_View_2016_2018;
DROP VIEW IF EXISTS McDonalds_View_2019_2021;
DROP VIEW IF EXISTS McDonalds_View_2022_2024;

CREATE VIEW McDonalds_View_2016_2018 AS
SELECT
	'McDonalds' AS Company,
	2016 AS Year,
	Metric,
	"Dec. 31, 2016" AS Value
FROM McDonalds_2016_2018

UNION ALL

SELECT
	'McDonalds' AS Company,
	2017 AS Year,
	Metric,
	"Dec. 31, 2017" AS Value
FROM McDonalds_2016_2018

UNION ALL

SELECT
	'McDonalds' AS Company,
	2018 AS Year,
	Metric,
	"Dec. 31, 2018" AS Value
FROM McDonalds_2016_2018;

CREATE VIEW McDonalds_View_2019_2021 AS
SELECT
	'McDonalds' AS Company,
	2019 AS Year,
	Metric,
	"Dec. 31, 2019" AS Value
FROM McDonalds_2019_2021

UNION ALL

SELECT
	'McDonalds' AS Company,
	2020 AS Year,
	Metric,
	"Dec. 31, 2020" AS Value
FROM McDonalds_2019_2021

UNION ALL

SELECT
	'McDonalds' AS Company,
	2021 AS Year,
	Metric,
	"Dec. 31, 2021" AS Value
FROM McDonalds_2019_2021;

CREATE VIEW McDonalds_View_2022_2024 AS
SELECT
	'McDonalds' AS Company,
	2022 AS Year,
	Metric,
	"Dec. 31, 2022" AS Value
FROM McDonalds_2022_2024

UNION ALL

SELECT
	'McDonalds' AS Company,
	2023 AS Year,
	Metric,
	"Dec. 31, 2023" AS Value
FROM McDonalds_2022_2024

UNION ALL

SELECT
	'McDonalds' AS Company,
	2024 AS Year,
	Metric,
	"Dec. 31, 2024" AS Value
FROM McDonalds_2022_2024;

-- Combine McDonald's Views
DROP VIEW IF EXISTS McDonalds_All;
CREATE VIEW McDonalds_All AS
SELECT * FROM McDonalds_View_2016_2018
UNION ALL
SELECT * FROM McDonalds_View_2019_2021
UNION ALL
SELECT * FROM McDonalds_View_2022_2024;

-- Combine Both Companies
DROP VIEW IF EXISTS Income_Raw;
CREATE VIEW Income_Raw AS
SELECT * FROM Chipotle_ALL
UNION ALL
SELECT * FROM McDonalds_All;

-- Clean the Combined Data
DROP VIEW IF EXISTS Income_Clean;
CREATE VIEW Income_Clean AS
SELECT
	Company,
	Year,
	Metric,
	CASE
		WHEN Value LIKE '(%' THEN
			-1 *

CAST(REPLACE(REPLACE(REPLACE(REPLACE(Value,'$',''),'(',''),')',''),',','') AS REAL)
    ELSE
      CAST(REPLACE(REPLACE(REPLACE(Value,'$',''),',',''),' ','') AS REAL)
  END AS Value_Num
FROM Income_Raw
WHERE Value IS NOT NULL
	AND Metric NOT LIKE 'Earnings per share%'
	AND Metric NOT LIKE 'Weighted0average%';

-- Create the Final Dataset that will be imported to Tableau
DROP VIEW IF EXISTS Income_All;
CREATE VIEW Income_All AS
SELECT
	Company,
	Year,
	CASE
		WHEN Metric IN ('Revenue','Total revenues','Total revenue')
		THEN 'Total revenue'
		ELSE Metric
	END AS Metric,
	CASE
		WHEN Company = 'Chipotle' THEN Value_Num / 1000.0
		ELSE Value_Num
	END AS Value
FROM Income_Clean;

-- To view the Final Dataset
SELECT *
FROM Income_All;