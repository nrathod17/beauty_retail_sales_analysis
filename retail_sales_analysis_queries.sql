-- SQLite
-- Top 10 Selling Products
SELECT      dt.Product_Name AS [Product_Name],
            ROUND(SUM(ft.Sales_Amount),2) AS [Total_Sales]
FROM        Retail_Fact_Table AS ft
INNER JOIN  Retail_Dim_Table AS dt
        ON  ft.Product_ID = dt.Product_ID
GROUP BY    dt.Product_Name
ORDER BY    Total_Sales DESC
LIMIT       10;

-- Best Performing Brands
SELECT      dt.Brand AS [Brand],
            ROUND(SUM(ft.Sales_Amount),2) AS [Total_Sales]
FROM        Retail_Fact_Table AS ft
INNER JOIN  Retail_Dim_Table AS dt
        ON  ft.Product_ID = dt.Product_ID
GROUP BY    dt.Brand
ORDER BY    Total_Sales DESC;

-- Regional Sales Performance
SELECT      Region,
            ROUND(SUM(Sales_Amount),2) AS [Total_Sales]
FROM        Retail_Fact_Table
GROUP BY    Region
ORDER BY    Total_Sales DESC;

-- Profitability Analysis
SELECT      dt.Category AS [Category],
            ROUND(SUM(ft.Sales_Amount - (ft.Unit_Cost * ft.Quantity_Sold)),2) 
            AS [Profit]
FROM        Retail_Fact_Table AS ft
INNER JOIN  Retail_Dim_Table AS dt
        ON  dt.Product_ID = ft.Product_ID
GROUP BY    dt.Category
ORDER BY    Profit DESC;

-- Discount Impact
SELECT      dt.Product_Name AS [Product_Name],
            ROUND(AVG(ft.Discount),2) AS [AVG_Discount],
            ROUND(SUM(ft.Sales_Amount),2) AS [Sales_Amount]
FROM        Retail_Fact_Table AS ft
INNER JOIN  Retail_Dim_Table AS dt
        ON  dt.Product_ID = ft.Product_ID
GROUP BY    dt.Product_Name
ORDER BY    AVG_Discount DESC;

-- Customer Type Analysis
SELECT      Customer_Type,
            ROUND(SUM(Sales_Amount),2) AS [Total_Sales]
FROM        Retail_Fact_Table
GROUP BY    Customer_Type
ORDER BY    Total_Sales DESC;

-- Monthly Sales Trend
SELECT      strftime('%m',Sale_Date) AS [Month],
            ROUND(SUM(Sales_Amount),2) AS [Monthly_Sales]
FROM        Retail_Fact_Table
GROUP BY    strftime('%m',Sale_Date)
ORDER BY    Month ASC;

-- Profit Margin by Category
SELECT      dt.Category,
            ROUND(
            (SUM(ft.Sales_Amount - (ft.Unit_Cost * ft.Quantity_Sold)) 
            / SUM(ft.Sales_Amount) * 100),2) 
            AS [Profit_Margin]
FROM        Retail_Fact_Table AS ft
INNER JOIN  Retail_Dim_Table AS dt
        ON  dt.Product_ID = ft.Product_ID
GROUP BY    dt.Category
ORDER BY    Profit_Margin DESC;

-- Top 5 Products per Brand
WITH Ranked_Products AS
(
SELECT      dt.Brand AS [Brand],
            dt.Product_Name AS [Product_Name],
            ROUND(SUM(ft.Sales_Amount),2) AS [Total_Sales],
            RANK() OVER
            (   
            PARTITION BY    dt.Brand
            ORDER BY        SUM(ft.Sales_Amount) DESC
            )
            AS [Sales_Rank]
FROM        Retail_Fact_Table AS ft
INNER JOIN  Retail_Dim_Table AS dt
        ON  dt.Product_ID = ft.Product_ID
GROUP BY    dt.Brand,
            dt.Product_Name
)
SELECT      *
FROM        Ranked_Products
WHERE       Sales_Rank <= 5
ORDER BY    Brand,
            Sales_Rank ASC;

-- Customer Segmentation
SELECT      Customer_Type,
            CASE
                WHEN SUM(Sales_Amount) > 1000000 THEN 'High Value'
                ELSE 'Low Value'    
            END AS [Customer_Segment],
            ROUND(SUM(Sales_Amount),2) AS [Total_Sales]
FROM        Retail_Fact_Table
GROUP BY    Customer_Type;

-- Most Efficient Products
SELECT      dt.Product_Name AS [Product_Name],
            ROUND(SUM(ft.Sales_Amount),2) AS [Total_Sales],
            ROUND(AVG(ft.Discount),2) AS [AVG_Discount],
            ROUND(SUM(ft.Sales_Amount)
            / AVG(ft.Discount),2) AS [Efficiency_Score]
FROM        Retail_Fact_Table AS ft
INNER JOIN  Retail_Dim_Table AS dt
        ON  dt.Product_ID = ft.Product_ID
GROUP BY    dt.Product_Name
ORDER BY    Efficiency_Score DESC
LIMIT       10;

-- Running Monthly Sales
SELECT      strftime('%m', Sale_Date) AS [Sales_Month],
            ROUND(SUM(Sales_Amount),2) AS [Monthly_Sales],
            ROUND(
            SUM(SUM(Sales_Amount))
            OVER
            (ORDER BY strftime('%m', Sale_Date)), 2) AS [Running_Total]
FROM        Retail_Fact_Table
GROUP BY    strftime('%m', Sale_Date)
ORDER BY    Sales_Month;