-- 1. Basic Data Exploration

USE indian_startup_funding


-- Total number of records

SELECT COUNT(*) AS Total_Records
FROM startup_funding;



-- Total number of startups

SELECT COUNT(DISTINCT Startup_Name) AS Total_Startups
FROM startup_funding;


-- Total funding

SELECT 
    SUM(Funding_USD) AS Total_Funding
FROM startup_funding
WHERE Funding_USD IS NOT NULL;


-- Average funding

SELECT 
    AVG(Funding_USD) AS Average_Funding
FROM startup_funding
WHERE Funding_USD IS NOT NULL;


-- Median funding


SELECT 
    AVG(Funding_USD) AS Median_Funding
FROM (
    SELECT 
        Funding_USD,
        ROW_NUMBER() OVER (ORDER BY Funding_USD) AS rn,
        COUNT(*) OVER () AS total_rows
    FROM startup_funding
    WHERE Funding_USD IS NOT NULL
) AS x
WHERE rn IN (
    FLOOR((total_rows + 1) / 2),
    FLOOR((total_rows + 2) / 2)
);



-- 2. Top Funded Sectors

SELECT
    Industry_Vertical,
    SUM(Funding_USD) AS Total_Funding
FROM startup_funding
WHERE Funding_USD IS NOT NULL
GROUP BY Industry_Vertical
ORDER BY Total_Funding DESC;



-- Top 10 sectors

SELECT
    TOP 10
    Industry_Vertical,
    SUM(Funding_USD) AS Total_Funding
FROM startup_funding
WHERE Funding_USD IS NOT NULL
GROUP BY Industry_Vertical
ORDER BY Total_Funding DESC




-- 3. Sector-wise Deal Count

SELECT
    Industry_Vertical,
    COUNT(*) AS Number_of_Deals
FROM startup_funding
GROUP BY Industry_Vertical
ORDER BY Number_of_Deals DESC;




-- Sector funding + deal count + average funding

SELECT
    Industry_Vertical,
    COUNT(*) AS Number_of_Deals,
    SUM(Funding_USD) AS Total_Funding,
    AVG(Funding_USD) AS Average_Funding,
    MAX(Funding_USD) AS Largest_Deal
FROM startup_funding
WHERE Funding_USD IS NOT NULL
GROUP BY Industry_Vertical
ORDER BY Total_Funding DESC;



-- 4. City-wise Funding


SELECT
    City,
    SUM(Funding_USD) AS Total_Funding
FROM startup_funding
WHERE Funding_USD IS NOT NULL
GROUP BY City
ORDER BY Total_Funding DESC;


-- Top 10 startup cities

SELECT
    TOP 10
    City,
    SUM(Funding_USD) AS Total_Funding,
    COUNT(*) AS Number_of_Deals
FROM startup_funding
WHERE Funding_USD IS NOT NULL
GROUP BY City
ORDER BY Total_Funding DESC



-- 5. Investment Type Analysis

SELECT
    Investment_Type,
    COUNT(*) AS Number_of_Deals,
    SUM(Funding_USD) AS Total_Funding,
    AVG(Funding_USD) AS Average_Funding
FROM startup_funding
WHERE Funding_USD IS NOT NULL
GROUP BY Investment_Type
ORDER BY Total_Funding DESC;


-- Most common investment types

SELECT
    Investment_Type,
    COUNT(*) AS Deal_Count
FROM startup_funding
GROUP BY Investment_Type
ORDER BY Deal_Count DESC;




-- 6. Year-wise Funding Trend

SELECT
    YEAR(Date) AS Year,
    COUNT(*) AS Number_of_Deals,
    SUM(Funding_USD) AS Total_Funding,
    AVG(Funding_USD) AS Average_Deal,
    MAX(Funding_USD) AS Largest_Deal
FROM startup_funding
WHERE Funding_USD IS NOT NULL
GROUP BY YEAR(Date)
ORDER BY Year;





-- 7. Year-over-Year Funding Growth

WITH yearly_funding AS (
    SELECT
        YEAR(Date) AS Year,
        SUM(Funding_USD) AS Total_Funding
    FROM startup_funding
    WHERE Funding_USD IS NOT NULL
    GROUP BY YEAR(Date)
),

previous_year AS (
    SELECT
        Year,
        Total_Funding,
        LAG(Total_Funding) OVER (ORDER BY Year) AS Previous_Year_Funding
    FROM yearly_funding
)

SELECT
    Year,
    Total_Funding,
    Previous_Year_Funding,
    ROUND(
        (Total_Funding - Previous_Year_Funding)
        / NULLIF(Previous_Year_Funding, 0) * 100,
        2
    ) AS YoY_Growth_Percentage
FROM previous_year
ORDER BY Year;



-- 8. Monthly Funding Trend


SELECT
    FORMAT(Date, '%Y-%m') AS Year_Month,
    COUNT(*) AS Number_of_Deals,
    SUM(Funding_USD) AS Total_Funding,
    AVG(Funding_USD) AS Average_Funding
FROM startup_funding
WHERE Funding_USD IS NOT NULL
GROUP BY FORMAT(Date, '%Y-%m')
ORDER BY Year_Month;



-- 9. Quarterly Funding Analysis

SELECT
    YEAR(Date) AS Year,
    DATEPART(QUARTER,DATE) AS Quarter,
    COUNT(*) AS Number_of_Deals,
    SUM(Funding_USD) AS Total_Funding
FROM startup_funding
WHERE Funding_USD IS NOT NULL
GROUP BY YEAR(Date), DATEPART(QUARTER,Date)
ORDER BY Year, Quarter;




-- 10. Top Funded Startups

SELECT
    TOP 20
    Startup_Name,
    SUM(Funding_USD) AS Total_Funding,
    COUNT(*) AS Number_of_Deals,
    AVG(Funding_USD) AS Average_Deal
FROM startup_funding
WHERE Funding_USD IS NOT NULL
GROUP BY Startup_Name
ORDER BY Total_Funding DESC




-- 11. Startups with Multiple Funding Rounds

SELECT
    Startup_Name,
    COUNT(*) AS Number_of_Funding_Rounds,
    SUM(Funding_USD) AS Total_Funding
FROM startup_funding
WHERE Funding_USD IS NOT NULL
GROUP BY Startup_Name
HAVING COUNT(*) > 1
ORDER BY Number_of_Funding_Rounds DESC;



-- 12. Largest Individual Funding Deals


SELECT
    TOP 20
    Startup_Name,
    Industry_Vertical,
    City,
    Investment_Type,
    Funding_USD,
    Date
FROM startup_funding
WHERE Funding_USD IS NOT NULL
ORDER BY Funding_USD DESC




-- 13. Top Investors by Deal Count


SELECT
    TOP 20
    Investors,
    COUNT(*) AS Deal_Count
FROM startup_funding
WHERE Investors IS NOT NULL
GROUP BY Investors
ORDER BY Deal_Count DESC




-- 14. Investor Normalization

CREATE TABLE funding_investors (
    Sr_No INT,
    Investor_Name VARCHAR(255)
);


SELECT
    TOP 20
    Investor_Name,
    COUNT(*) AS Deal_Count
FROM funding_investors
GROUP BY Investor_Name
ORDER BY Deal_Count DESC





-- 15. Top Investors by Associated Deal Funding

SELECT
    fi.Investor_Name,
    COUNT(DISTINCT fi.Sr_No) AS Deal_Count,
    SUM(sf.Funding_USD) AS Associated_Funding
FROM funding_investors fi
JOIN startup_funding sf
    ON fi.Sr_No = sf.Sr_No
WHERE sf.Funding_USD IS NOT NULL
GROUP BY fi.Investor_Name
ORDER BY Deal_Count DESC;




-- 16. Top City + Sector Combinations

SELECT
    City,
    Industry_Vertical,
    COUNT(*) AS Deal_Count,
    SUM(Funding_USD) AS Total_Funding
FROM startup_funding
WHERE Funding_USD IS NOT NULL
GROUP BY City, Industry_Vertical
ORDER BY Total_Funding DESC;





-- 17. Highest Funding Sector in Each City


WITH city_sector AS (
    SELECT
        City,
        Industry_Vertical,
        SUM(Funding_USD) AS Total_Funding
    FROM startup_funding
    WHERE Funding_USD IS NOT NULL
    GROUP BY City, Industry_Vertical
),

ranked AS (
    SELECT
        City,
        Industry_Vertical,
        Total_Funding,
        RANK() OVER (
            PARTITION BY City
            ORDER BY Total_Funding DESC
        ) AS Sector_Rank
    FROM city_sector
)

SELECT
    City,
    Industry_Vertical,
    Total_Funding
FROM ranked
WHERE Sector_Rank = 1
ORDER BY Total_Funding DESC;





-- 18. Rank Startups by Total Funding

WITH startup_funding_summary AS (
    SELECT
        Startup_Name,
        SUM(Funding_USD) AS Total_Funding
    FROM startup_funding
    WHERE Funding_USD IS NOT NULL
    GROUP BY Startup_Name
)

SELECT
    Startup_Name,
    Total_Funding,
    RANK() OVER (
        ORDER BY Total_Funding DESC
    ) AS Funding_Rank
FROM startup_funding_summary
ORDER BY Funding_Rank;





-- 19. Top 10% Funded Startups

WITH startup_summary AS (
    SELECT
        Startup_Name,
        SUM(Funding_USD) AS Total_Funding
    FROM startup_funding
    WHERE Funding_USD IS NOT NULL
    GROUP BY Startup_Name
),

ranked AS (
    SELECT
        Startup_Name,
        Total_Funding,
        NTILE(10) OVER (
            ORDER BY Total_Funding DESC
        ) AS Funding_Decile
    FROM startup_summary
)

SELECT
    Startup_Name,
    Total_Funding
FROM ranked
WHERE Funding_Decile = 1
ORDER BY Total_Funding DESC;





-- 20. Running Total of Funding

SELECT
    Date,
    Startup_Name,
    Funding_USD,
    SUM(Funding_USD) OVER (
        ORDER BY Date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Running_Total_Funding
FROM startup_funding
WHERE Funding_USD IS NOT NULL
ORDER BY Date;






-- 21. Top 10 Funding Deals and Their Share of Total Funding

WITH ranked_deals AS (
    SELECT
        Startup_Name,
        Funding_USD,
        ROW_NUMBER() OVER (
            ORDER BY Funding_USD DESC
        ) AS Deal_Rank
    FROM startup_funding
    WHERE Funding_USD IS NOT NULL
),

total AS (
    SELECT
        SUM(Funding_USD) AS Total_Funding
    FROM startup_funding
    WHERE Funding_USD IS NOT NULL
)

SELECT
    SUM(r.Funding_USD) AS Top_10_Funding,
    t.Total_Funding,
    ROUND(
        SUM(r.Funding_USD) / t.Total_Funding * 100,
        2
    ) AS Top_10_Funding_Share_Percentage
FROM ranked_deals r
CROSS JOIN total t
WHERE r.Deal_Rank <= 10
GROUP BY t.Total_Funding;





-- 22. Find Missing Values

-- Missing funding

SELECT COUNT(*) AS Missing_Funding
FROM startup_funding
WHERE Funding_USD IS NULL;



-- Missing city
SELECT COUNT(*) AS Missing_City
FROM startup_funding
WHERE City IS NULL
   OR City = 'Unknown';



-- Missing industry

SELECT COUNT(*) AS Missing_Industry
FROM startup_funding
WHERE Industry_Vertical IS NULL
   OR Industry_Vertical = 'Unknown';



-- 23. Data Quality Check

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Startup_Name) AS Unique_Startups,
    COUNT(DISTINCT City) AS Unique_Cities,
    COUNT(DISTINCT Industry_Vertical) AS Unique_Industries,
    COUNT(DISTINCT Investment_Type) AS Unique_Investment_Types,
    COUNT(Funding_USD) AS Valid_Funding_Records
FROM startup_funding;






-- 24. Complete Business Summary Query


SELECT
    YEAR(Date) AS Year,
    Industry_Vertical,
    City,
    Investment_Type,
    COUNT(*) AS Number_of_Deals,
    COUNT(DISTINCT Startup_Name) AS Unique_Startups,
    SUM(Funding_USD) AS Total_Funding,
    AVG(Funding_USD) AS Average_Funding,
    MAX(Funding_USD) AS Largest_Deal
FROM startup_funding
WHERE Funding_USD IS NOT NULL
GROUP BY
    YEAR(Date),
    Industry_Vertical,
    City,
    Investment_Type
ORDER BY
    Year,
    Total_Funding DESC;

