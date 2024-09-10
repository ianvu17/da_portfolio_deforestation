Select * from forest_area

Select * from land_area

Select * from regions
------------------------------

-- Create view table and name forestation based on 3 table
CREATE VIEW forestation AS
SELECT
    fa.country_code AS CountryCode,
    fa.country_name AS CountryName,
    fa.year AS Year,
    fa.forest_area_sqkm AS ForestAreaSqKm,
    la.total_area_sq_mi AS TotalAreaSqMi,
    r.region AS Region,
    r.income_group AS IncomeGroup,
	-- Convert measure and calculate precentage
    round((fa.forest_area_sqkm / (la.total_area_sq_mi * 2.59)) * 100, 2) AS ForestAreaPercentage
FROM 
    forest_area fa
	join land_area la on fa.country_code = la.country_code and fa.year = la.year
    join regions r on fa.country_code = r.country_code;

SELECT * FROM forestation
--------------

-- 1. Fill in the blank: GLOBAL SITUATION
-- 1.1. According to the World Bank, the total forest area of the world was__in 1990.
SELECT ROUND(SUM(ForestAreaSqKm), 2) FROM forestation
WHERE year = 1990
AND CountryName = 'World'
-- 1.2 - 1.4. the most recent year for which data was available, 
--            that number had fallen to __, a loss of __, or __%.
-- 1.2.
SELECT ROUND(SUM(ForestAreaSqKm), 2) FROM forestation
WHERE year = 2016
AND CountryName = 'World'
--1.3. 
SELECT (SELECT forest_area_sqkm
          FROM forest_area
         WHERE country_name = 'World' AND year = 1990) -
       (SELECT forest_area_sqkm
          FROM forest_area
         WHERE country_name = 'World' AND year = 2016) AS forest_loss;
-- 1.4.
SELECT ROUND(((SELECT forest_area_sqkm
          FROM forest_area
         WHERE country_name = 'World' AND year = 1990) -
       (SELECT forest_area_sqkm
          FROM forest_area
         WHERE country_name = 'World' AND year = 2016)) /
        (SELECT forest_area_sqkm
          FROM forest_area
         WHERE country_name = 'World' AND year = 1990) * 100, 2) AS percent_loss

-- 1.5 - 1.6: The forest area lost over this time period is slightly 
--            more than the entire land area of _ listed for the year 2016 (which is _).
SELECT CountryCode, CountryName, TotalAreaSqMi
 FROM forestation
 WHERE TotalAreaSqMi * 2.59 <
       (SELECT (SELECT forest_area_sqkm
                  FROM forest_area
                 WHERE country_name = 'World' AND year = 1990) -
               (SELECT forest_area_sqkm
                  FROM forest_area
                 WHERE country_name = 'World' AND year = 2016))
   AND year = '2016'
 ORDER BY TotalAreaSqMi DESC 

 -- 2. REGIONAL OUTLOOK
 -- 2.1 - 2.5
-- In 2016, the percent of the total land area of the world designated as forest was _. 
-- The region with the highest relative forestation was_, with _%, 
-- and the region with the lowest relative forestation was _, with _% forestation.

-- 2.1.
SELECT CountryName, ROUND((((SUM(ForestAreaSqKm)/2.59)/SUM(TotalAreaSqMi))*100), 2) 
AS pct_forest_area
FROM forestation
WHERE year = 2016
AND CountryName = 'World' GROUP BY CountryName

-- 2.2 -2.3
SELECT Top 1 region, ROUND((((SUM(ForestAreaSqKm)/2.59)/SUM(TotalAreaSqMi))*100), 2) 
AS pct_forest_area FROM forestation
WHERE year = 2016
GROUP BY region
ORDER BY pct_forest_area DESC

-- 2.4 - 2.5
SELECT Top 1 region, 
ROUND((((SUM(ForestAreaSqKm)/2.59)/SUM(TotalAreaSqMi))*100), 2) AS pct_forest_area 
FROM forestation
WHERE year = 2016
GROUP BY region
ORDER BY pct_forest_area ASC


-- 2.6 - 2.10
-- In 1990, the percent of the total land area of the world designated as forest was _. 
-- The region with the highest relative forestation was _, with _%, 
-- and the region with the lowest relative forestation was __, with _% forestation.
-- 2.6
SELECT CountryName, 
ROUND((((SUM(ForestAreaSqKm)/2.59)/SUM(TotalAreaSqMi))*100), 2) AS pct_forest_area
FROM forestation
WHERE year = 1990
AND CountryName = 'World' GROUP BY CountryName

-- 2.7 - 2.8
SELECT Top 1 region, 
ROUND((((SUM(ForestAreaSqKm)/2.59)/SUM(TotalAreaSqMi))*100), 2) AS pct_forest_area 
FROM forestation
WHERE year = 1990
GROUP BY region
ORDER BY pct_forest_area DESC

-- 2.9 - 2.10
SELECT Top 1 region, 
ROUND((((SUM(ForestAreaSqKm)/2.59)/SUM(TotalAreaSqMi))*100), 2) AS pct_forest_area 
FROM forestation
WHERE year = 1990
GROUP BY region
ORDER BY pct_forest_area ASC

-- Table 2.1
-- 2.11
SELECT region,
ROUND((region_forest_1990/region_area_1990)*100, 2)
AS [1990 Forest Percentage],
ROUND((region_forest_2016/region_area_2016)*100, 2)
AS [2016 Forest Percentage]
FROM (SELECT SUM(t0.ForestAreaSqKm) AS region_forest_1990,
      SUM (t0.TotalAreaSqMi*2.59) AS region_area_1990, t0.region,
      SUM (t1.ForestAreaSqKm) AS region_forest_2016,
      SUM (t1.TotalAreaSqMi*2.59) AS region_area_2016
FROM forestation t0, forestation t1
      WHERE t0.year ='1990'
      AND t1.year ='2016'
      AND t0.region = t1.region
GROUP BY t0.region) region_percent
ORDER BY [1990 Forest Percentage] DESC;

-- 3. COUNTRY-LEVEL DETAIL
-- A. SUCCESS STORIES
-- There is one particularly bright spot in the data at the country level, _. 
--    This country actually increased in forest area from 1990 to 2016 by _. 
--    It would be interesting to study what has changed in this country
--       over this time to drive this figure in the data higher. 
--    The country with the next largest increase in forest area from 1990 to 2016 was the_
--      ,but it only saw an increase of _, much lower than the figure for _.
--      _ and _ are of course very large countries in total land area,
--      so when we look at the largest percent change in forest area from 1990 to 2016,
--      we aren’t surprised to find a much smaller country listed at the top. 
--   __ increased in forest area by __% from 1990 to 2016. 


SELECT TOP 5 WITH TIES f1.CountryCode, f1.CountryName, f1.region,
ROUND((f1.ForestAreaSqKm - f0.ForestAreaSqKm), 2)
AS [Change in Forest Area in SqKm]
FROM forestation AS f1
JOIN forestation AS f0
ON (f1.year='2016' AND f0.year='1990')
AND f1.CountryCode = f0.CountryCode
WHERE f1.CountryCode !='WLD'
AND f1.ForestAreaSqKm !=0 AND f0.ForestAreaSqKm !=0
ORDER BY [Change in Forest Area in SqKm] DESC

-- __ increased in forest area by __% from 1990 to 2016. 
SELECT TOP 5 WITH TIES f1.CountryCode, f1.CountryName, f1.region, 
ROUND(((f1.ForestAreaSqKm/(f0.ForestAreaSqKm)-1)*100), 2)
AS [PCT change in Forest Area]
FROM forestation AS f1
JOIN forestation AS f0
ON (f1.year='2016' AND f0.year='1990')
AND f1.CountryCode = f0.CountryCode
WHERE f0.CountryCode !='WLD'
AND f1.ForestAreaSqKm !=0 AND f0.ForestAreaSqKm !=0
ORDER BY [PCT change in Forest Area] DESC

--3.B.	LARGEST CONCERNS
-- Table 3.1: Top 5 Amount Decrease in Forest Area by Country, 1990 & 2016

SELECT TOP 5 WITH TIES f1.CountryCode, f1.CountryName, f1.region, 
ROUND((f1.ForestAreaSqKm - f0.ForestAreaSqKm), 2)
AS [Change in Forest Area in SqKm]
FROM forestation AS f1
JOIN forestation AS f0
ON (f1.year='2016' AND f0.year='1990')
AND f1.CountryCode = f0.CountryCode
WHERE f0.CountryCode !='WLD'
AND f1.ForestAreaSqKm !=0 AND f0.ForestAreaSqKm !=0
ORDER BY [Change in Forest Area in SqKm] ASC

-- Table 3.2: Top 5 Percent Decrease in Forest Area by Country, 1990 & 2016

SELECT TOP 5 WITH TIES f1.CountryCode, f1.CountryName, f1.region, 
ROUND(((f1.ForestAreaSqKm / f0.ForestAreaSqKm-1)*100), 2)
AS [PCT change in Forest Area]
FROM forestation AS f1
JOIN forestation AS f0
ON (f1.year='2016' AND f0.year='1990')
AND f1.CountryCode = f0.CountryCode
WHERE f0.CountryCode !='WLD'
AND f1.ForestAreaSqKm !=0 AND f0.ForestAreaSqKm !=0
ORDER BY [PCT change in Forest Area] ASC

-- 3.C.	QUARTILES
-- Table 3.3: Count of Countries Grouped by Forestation Percent Quartiles, 2016:
WITH [3C_CTE_1] AS
(SELECT CountryName, year,ForestAreaSqKm, TotalAreaSqMi*2.59 AS total_area_sqkm, ForestAreaPercentage
FROM forestation
WHERE  year='2016' AND CountryName!='World'
        AND ForestAreaSqKm !=0 AND TotalAreaSqMi!=0),

[3C_CTE_2] AS
(SELECT [3C_CTE_1].CountryName, [3C_CTE_1].year, [3C_CTE_1].ForestAreaPercentage,
  --CASE WHEN [3C_CTE_1].ForestAreaPercentage > 75 THEN 4
  --WHEN [3C_CTE_1].ForestAreaPercentage <= 75 AND [3C_CTE_1].ForestAreaPercentage > 50 THEN 3
  --WHEN [3C_CTE_1].ForestAreaPercentage <= 50 AND [3C_CTE_1].ForestAreaPercentage > 25 THEN 2
  --ELSE 1
  CASE 
	  WHEN [3C_CTE_1].ForestAreaPercentage <= 25 THEN 1
	  WHEN [3C_CTE_1].ForestAreaPercentage <= 50 THEN 2
	  WHEN [3C_CTE_1].ForestAreaPercentage <= 75 THEN 3
	  ELSE 4
  END AS quartile
  FROM [3C_CTE_1])

SELECT quartile, COUNT(quartile) AS [Number Country]
FROM [3C_CTE_2]
GROUP BY quartile
ORDER BY COUNT([3C_CTE_2].quartile) DESC;

-- Table 3.4: List of 4th Quartile Countries, 2016:

SELECT CountryName, region, ForestAreaPercentage
FROM forestation
WHERE 
	Year = 2016 
	AND ForestAreaPercentage > 75
	AND CountryCode !='WLD'
	AND ForestAreaSqKm !=0 AND ForestAreaSqKm !=0
ORDER BY ForestAreaPercentage DESC;

-- 4. EXTRA QUERY
WITH CTE_1 AS (
SELECT
    CountryCode,
    CountryName,
    Year,
    ForestAreaSqKm,
    TotalAreaSqMi,
    Region,
    IncomeGroup,
    ForestAreaPercentage,
    CASE
        WHEN ForestAreaPercentage >= 50 THEN 'High'
        WHEN ForestAreaPercentage >= 20 AND ForestAreaPercentage < 50 THEN 'Medium'
        ELSE 'Low'
    END AS Forestation_Level,
    -- 4.1
	RANK() OVER (PARTITION BY Region, Year ORDER BY ForestAreaPercentage DESC) AS Regional_Forestation_Rank
	-- 4.2
	-- RANK() OVER (PARTITION BY IncomeGroup, Region ORDER BY ForestAreaPercentage DESC) AS Regional_Forestation_Rank
FROM forestation
WHERE 
	CountryCode !='WLD'
	AND ForestAreaSqKm !=0 AND ForestAreaSqKm !=0
)

-- 4.1
--/*
select Year, Forestation_Level, count(*) [Count Country] from CTE_1
where Year = 1990 or Year = 2016
group by Forestation_Level,Year order by Year
--*/

-- 4.2
/*
SELECT CountryName, Year, Region, IncomeGroup
FROM CTE_1 WHERE Regional_Forestation_Rank = 1 AND Year = 2016 
OR Regional_Forestation_Rank = 1 AND Year = 1990 ORDER BY Region, IncomeGroup
*/

