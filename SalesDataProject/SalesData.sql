/*
Sales Data Exploration and Analysis
Skills used: aggregate functions, window functions, sub-queries, CTEs, XML path functions
 */

-- Inspect Data
SELECT *
FROM Sales.SalesData;

-- Checking Unique Values
SELECT DISTINCT STATUS FROM Sales.SalesData;
SELECT DISTINCT YEAR_ID FROM Sales.SalesData;
SELECT DISTINCT PRODUCTLINE FROM Sales.SalesData;
SELECT DISTINCT COUNTRY FROM Sales.SalesData;
SELECT DISTINCT DEALSIZE FROM Sales.SalesData;
SELECT DISTINCT TERRITORY FROM Sales.SalesData;

-- Analysis
-- Group Sales by Product Line
SELECT PRODUCTLINE, sum(SALES) as Revenue
FROM Sales.SalesData
GROUP BY PRODUCTLINE
ORDER BY 2 DESC;

SELECT YEAR_ID, sum(SALES) as Revenue
FROM Sales.SalesData
GROUP BY YEAR_ID
ORDER BY 2 DESC;

SELECT DEALSIZE, sum(SALES) as Revenue
FROM Sales.SalesData
GROUP BY DEALSIZE
ORDER BY 2 DESC;

-- Exploring the best month for sales in a given year (November)
SELECT MONTH_ID, ROUND(sum(sales),2) as Revenue, count(ORDERNUMBER) as Frequency
FROM Sales.SalesData
WHERE YEAR_ID = 2003
GROUP BY MONTH_ID
ORDER BY 2 DESC;

-- Determining the highest-selling product during the best month (November)
SELECT MONTH_ID, PRODUCTLINE, ROUND(sum(sales),2) as Revenue, count(ORDERNUMBER) as Frequency
FROM Sales.SalesData
WHERE YEAR_ID = 2003 AND MONTH_ID = 11
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC;

-- RFM Analysis to find the best customer
-- Recency, Frequency, Monetary Value
DROP TABLE IF EXISTS temp_rfm;
CREATE TEMPORARY TABLE temp_rfm
WITH rfm as
    (
    SELECT CUSTOMERNAME,
           ROUND(sum(sales),2) as MonetaryValue,
           ROUND(avg(sales),2) as AvgMonetaryValue,
           count(ORDERNUMBER) as Frequency,
           MAX(ORDERDATE) as LastOrderDate,
           (SELECT MAX(ORDERDATE) FROM Sales.SalesData) as MaxOrderDate,
           abs(DATEDIFF(MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM Sales.SalesData))) as Recency
    FROM Sales.SalesData
    GROUP BY CUSTOMERNAME
    ),
rfm_calc as
(
    SELECT r.*,
        NTILE (4) OVER (ORDER BY Recency DESC) rfm_recency,
        NTILE (4) OVER (ORDER BY Frequency) rfm_frequency,
        NTILE (4) OVER (ORDER BY AvgMonetaryValue) rfm_monetary
    from rfm as r
)
SELECT c.*, (rfm_recency + rfm_frequency + rfm_monetary) as rfm_cell,
       CONCAT( CAST(rfm_recency as char(50)), CAST(rfm_frequency as char(50)), CAST(rfm_monetary as char(50))) as rfm_cell_string
from rfm_calc as c;

SELECT CUSTOMERNAME, rfm_recency, rfm_frequency, rfm_monetary,
       CASE
           WHEN rfm_cell >= 9 THEN 'High-Value Customer'
           WHEN rfm_cell < 9 AND rfm_cell > 4 THEN 'Mid-Value Customer'
           WHEN rfm_cell <= 4 THEN 'Low-Value Customer'
           END rfm_segment
FROM temp_rfm

-- Determine what products are most often sold together TODO
SELECT CONCAT(',', PRODUCTCODE)
    FROM Sales.SalesData
WHERE ORDERNUMBER in (SELECT ORDERNUMBER
                      FROM (SELECT ORDERNUMBER, COUNT(*) rn
                            FROM Sales.SalesData
                            WHERE STATUS = 'Shipped'
                            GROUP BY ORDERNUMBER) m
                      WHERE rn = 2)
