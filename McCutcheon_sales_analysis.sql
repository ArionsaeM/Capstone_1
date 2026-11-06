USE sample_sales;

-- Sales State Territoty (FL) 
-- Select * FROM management;
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

-- 1 -- Store sales only are  calculated here because online sales are not FROM flush
SELECT 
	(SELECT SUM(sale_amount)
    FROM store_sales
    WHERE Store_ID BETWEEN 719 AND 729)
    AS FL_SalesAmount, 
    
    (SELECT MIN(Transaction_Date)
     FROM store_sales
     WHERE Store_ID BETWEEN 719 AND 729)
    AS Start_Date, 

    (SELECT MAX(Transaction_Date)
     FROM store_sales
     WHERE Store_ID BETWEEN 719 AND 729)
    AS End_Date; -- $3930187.55



/*
2 What is the revenue breakdown by year and month for the sales territory?


*/
SELECT YEAR(Transaction_Date), Month(Transaction_Date), SUM(sale_amount)
FROM store_sales
WHERE Store_ID BETWEEN 719 AND 729
GROUP BY YEAR(Transaction_Date), Month(Transaction_Date)
;


-- 3 Provide a comparison of total revenue for the specific sales territory and the region it belongs to.
			-- Calculate the revunue of entire south region , then each individual state in the region (FL, TX, SC)
		 -- SELECT id, region, state FROM management; -- How I know what states are in what region. (ID, 7,8,9,)
         
   SELECT
    South_Sales.State,
    SUM(South_Sales.Revenue) AS Total_Revenue      
FROM (
    SELECT
        sl.State,
        ss.sale_amount AS Revenue
    FROM store_sales AS ss
    JOIN store_locations AS sl
        ON ss.Store_ID = sl.StoreID
    WHERE sl.State IN ('Florida', 'Texas', 'South Carolina')
) AS South_Sales
GROUP BY South_Sales.State
ORDER BY Total_Revenue DESC;
/*
South Region Rev - $7,996,850.12
*/


/*
4 What is the number of transactions per month and average transaction amount by product
category for the sales territory?
*/


SELECT ID, COUNT(*)
FROM store_sales
WHERE Store_ID BETWEEN 719 AND 729
GROUP BY ID
ORDER BY COUNT(*) DESC;

SELECT Category, YEAR(Transaction_Date) AS Sales_Year, MONTH(Transaction_Date) AS Sales_Month,
COUNT(*) AS Transaction_Count, AVG(sale_amount) AS Average_Transaction

FROM store_sales AS ss
JOIN products AS p
 ON ss.Prod_Num = p.ProdNum
JOIN inventory_categories AS I_C ON I_C.CategoryId = p.CategoryID
WHERE Store_ID BETWEEN 719 and 729

GROUP BY Category, YEAR(Transaction_Date), MONTH(Transaction_Date) ;



/*
5 Can you provide a ranking of in-store sales performance by each store in the sales territory, or a
ranking of online sales performance by state within an online sales territory?
*/

SELECT
    SUM(sale_amount) AS Total_Revenue, Store_ID
    
FROM store_sales 
WHERE Store_ID BETWEEN 719 AND 729
GROUP BY Store_ID
ORDER BY Total_Revenue DESC; -- Store 724 has the highest revenue in the state. @ $618,846.25
/*
SELECT
    SUM(sale_amount) AS Total_Revenue, Store_ID, YEAR(Transaction_Date), MONTH(Transaction_Date)
    
FROM store_sales 
WHERE Store_ID BETWEEN 719 AND 729
GROUP BY Store_ID, YEAR(Transaction_Date), MONTH(Transaction_Date)
ORDER BY YEAR(Transaction_Date), MONTH(Transaction_Date); -- Store 724 has the highest revenue in the state. @ $618,846.25
*/

SELECT
    SUM(sale_amount) AS Total_Revenue, Store_ID, YEAR(Transaction_Date), MONTH(Transaction_Date), StoreLocation
    
FROM store_sales ss
JOIN store_locations as sl
ON Sl.StoreID = ss.Store_ID
WHERE Store_ID BETWEEN 719 AND 729
GROUP BY Store_ID, YEAR(Transaction_Date), MONTH(Transaction_Date)
ORDER BY YEAR(Transaction_Date), MONTH(Transaction_Date); -- Store 724 has the highest revenue in the state. @ $618,846.25


--  What is arecommendation for where to focus sales attention in the next quarter?


/*
(VISUALIZATION) Pick one or more of the questions that you analyzed above to render as a chart in Excel. Export the
results of the query you used to answer the question as a .csv file, then open that file in Excel. Use
“Save as” to re-save the file as lastname_territory_chart.xlsx (remember to change the file
extension to .xlsx!). Use the PivotChart options to visualize the query results.
*/

/*
SELECT m.SalesManager, m.id , m.state, COUNT(m.id) AS online_orders, SUM(os.SalesTotal) AS online_revenue
FROM online_sales AS os
JOIN management as m
ON m.id =  os.id
WHERE m.SalesManager = 'Lana Ilana' 
GROUP BY m.id; -- $2130043.05

SELECT 
    SUM(os.SalesTotal) AS Revenue 
FROM online_sales AS os
JOIN products AS p ON os.ProdNum = p.ProdNum
JOIN inventory_categories AS I_C ON I_C.CategoryId = p.CategoryID
WHERE os.ShipToState = 'Florida'; -- $2130043.05

SELECT * FROM management;
 /* 
 WEST being the only region where online orders come FROM is the reason why even though FL
 has orders shipped to the state (ShipToState) so the revenue goes to Colorado 
 with the RegionalDirector (CassieChambers).
 */
 




