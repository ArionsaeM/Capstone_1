USE sample_sales;

-- Sales State Territoty (FL) 
-- SELect * FROM management;
/*
Analysis Questions
∗ What is total revenue overall for sales in the assigned territory, plus the start date and end date
that tell you what period the data covers?


SELECT *
FROM store_locations
WHERE state = "Florida" ; -- Showing me what im working with for my state -- 11 rows(stores) returned 

SELECT SUM(SalesTotal) as FL_Online_revenue
FROM online_sales
WHERE ShiptoState = "Florida" ; -- $2,130,043.05

SELECT SUM(sale_amount) AS florida_store_revenue
FROM store_sales
WHERE Store_ID BETWEEN 719 AND 729;  -- $3,930,187.55

SELECT MIN(Date), MAX(Date)
FROM online_sales
WHERE ShiptoState = 'Florida'; -- MIN & MAX sales date for online sales in FL  -- 1/1/2022- 12/31/2025

SELECT MIN(Transaction_Date), MAX(Transaction_Date)
FROM store_sales
WHERE Store_ID BETWEEN 719 AND 729; -- MIN & MAX sales dates for instore sales in FL -- 1/1/2022- 12/31/2025

*/

-- 1 
SELECT (SELECT SUM(SalesTotal)
     FROM online_sales
     WHERE ShiptoState = 'Florida') -- subquery1 
    + 
    (SELECT SUM(sale_amount)
     FROM store_sales
     WHERE Store_ID BETWEEN 719 AND 729)
    AS FL_Total_Revenue, -- subquery2
    -- 2 subqueries added together to make one column 
    (SELECT MIN(Date)
     FROM online_sales
     WHERE ShiptoState = 'Florida')
    AS Start_Date, 

    (SELECT MAX(Date)
     FROM online_sales
     WHERE ShiptoState = 'Florida')
    AS End_Date; -- $6,060,230.60 



/*
2 What is the revenue breakdown by year and month for the sales territory?

SELECT >> FROM >> WHERE > UNION ALL >> GROUP BY 
*/

SELECT
    YEAR(Sales_Date) AS Sales_Year,
    MONTH(Sales_Date) AS Sales_Month,
    SUM(Revenue) AS Total_Revenue
FROM ( -- UNION ALL inside from because "Sales_Date" is a created colum from this query.
    SELECT SalesTotal AS Revenue, Date AS Sales_Date
    FROM online_sales
    WHERE ShiptoState = 'Florida'

    UNION ALL

    SELECT sale_amount AS Revenue, Transaction_Date AS Sales_Date
    FROM store_sales
    WHERE Store_ID BETWEEN 719 AND 729
) AS Florida_Sales

GROUP BY YEAR(Sales_Date), MONTH(Sales_Date)
ORDER BY Sales_Year, Sales_Month;




-- 3 Provide a comparison of total revenue for the specific sales territory and the region it belongs to.
			-- Calculate the revunue of entire south region , then each individual state in the region (FL, TX, SC)
		 -- SELECT id, region, state FROM management; -- How I know what states are in what region. (ID, 7,8,9,)
    SELECT
    South_Sales.State,
    SUM(South_Sales.Revenue) AS Total_Revenue
FROM (
    SELECT ShipToState AS State, SalesTotal AS Revenue
    FROM online_sales
    WHERE ShipToState IN ('Florida', 'Texas', 'South Carolina')

    UNION ALL

    SELECT sl.State, ss.sale_amount AS Revenue
    FROM store_sales AS ss
    JOIN store_locations AS sl
        ON ss.Store_ID = sl.StoreID
    WHERE sl.State IN ('Florida', 'Texas', 'South Carolina')
) AS South_Sales

GROUP BY South_Sales.State WITH Rollup -- ROLLUP providing the total of the total_rev column with no state but reading the code will provide knowledge that it's the south.
ORDER BY Total_Revenue DESC;
/*
South Region Rev - 15,637,343.20
FL - 6,060,230.60
*/




/*
4 What is the number of transactions per month and average transaction amount by product
category for the sales territory?
*/

SELECT ID, COUNT(*)
FROM online_sales
WHERE ShipToState = 'Florida'
GROUP BY ID
ORDER BY COUNT(*) DESC; -- checking to see if each transaction is to one product or multiple.

SELECT ID, COUNT(*)
FROM store_sales
WHERE Store_ID BETWEEN 719 AND 729
GROUP BY ID
ORDER BY COUNT(*) DESC;

SELECT Category, YEAR(Sales_Date) AS Sales_Year, MONTH(Sales_Date) AS Sales_Month,
COUNT(*) AS Transaction_Count, AVG(Revenue) AS Average_Transaction

FROM (
SELECT os.ProdNum, I_C.Category, os.Date AS Sales_Date,
    os.SalesTotal AS Revenue
FROM online_sales AS os
JOIN products AS p ON os.ProdNum = p.ProdNum
JOIN inventory_categories AS I_C ON I_C.CategoryId = p.CategoryID
WHERE os.ShipToState = 'Florida'

UNION ALL 

SELECT ss.Prod_Num,
    I_C.Category,
    ss.Transaction_Date AS Sales_Date,
    ss.sale_amount AS Revenue
FROM store_sales AS ss
JOIN products AS p ON ss.Prod_Num = p.ProdNum
JOIN inventory_categories AS I_C ON I_C.CategoryId = p.CategoryID

WHERE ss.Store_ID BETWEEN 719 AND 729 ) 
	AS Florida_Sales

GROUP BY Category, YEAR(Sales_Date), MONTH(Sales_Date) ;



/*
5 Can you provide a ranking of in-store sales performance by each store in the sales territory, or a
ranking of online sales performance by state within an online sales territory?
*/

SELECT
    Store_ID,
    SUM(sale_amount) AS Total_Revenue
FROM store_sales
WHERE Store_ID BETWEEN 719 AND 729
GROUP BY Store_ID
ORDER BY (Total_Revenue) DESC; -- Store 724 has the highest revenue in the state. @ $618,846.25




--  What is arecommendation for where to focus sales attention in the next quarter?



/*
(VISUALIZATION) Pick one or more of the questions that you analyzed above to render as a chart in Excel. Export the
results of the query you used to answer the question as a .csv file, then open that file in Excel. Use
“Save as” to re-save the file as lastname_territory_chart.xlsx (remember to change the file
extension to .xlsx!). Use the PivotChart options to visualize the query results.
*/

