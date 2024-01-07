CREATE DATABASE SHOPPING;
USE SHOPPING;
#DROP TABLE SHOPPING;

SELECT * FROM SHOPPING;
SELECT * FROM SHOPPING1;

# TOTAL SPENDING OF CUSTOMER 

ALTER TABLE SHOPPING ADD COLUMN TT_SPENDING DECIMAL(10,1);
ALTER TABLE SHOPPING1 ADD COLUMN TT_SPENDING DECIMAL(10,1);
##
UPDATE SHOPPING SET TT_SPENDING = ONLINE_SPEND+OFFLINE_SPEND;
UPDATE SHOPPING1 SET TT_SPENDING = ONLINE_SPEND+OFFLINE_SPEND;

select sum(tt_spending) from shopping where customerid=12748;

##1 top 5 customer - find avg_spending customer and month-wise WHOSE AVG_SPENDING IS MORE THAN AVG_SPENDING IN THAT MONTH;
select * from (select CUSTOMERID,MONTH_TR,round(avg_sp,2) average_selling_Price,row_number() over(partition by MONTH_TR) rank_no 
from (SELECT S1.CUSTOMERID,S1.MONTH_TR,AVG(S1.TT_SPENDING) AVG_SP FROM SHOPPING S1 GROUP BY CUSTOMERID,MONTH_TR 
HAVING AVG_SP>(SELECT AVG(S2.TT_SPENDING) AVGS FROM SHOPPING S2 WHERE S1.MONTH_TR=S2.MONTH_TR) ORDER BY S1. CUSTOMERID) dt) dt1 where rank_no<=5;

##2 customers who have transactions in all four quarters

SELECT CustomerID,Product_Category,SUM(TT_SPENDING) AS TotalSpending
FROM shopping 
GROUP BY CustomerID,Product_Category HAVING COUNT(DISTINCT quarter_tr) = 4;   #distict quarter for customer have transactions in all four quarters 

##3 Top 3 customer based on each quarter
WITH RankedCustomers AS (
SELECT CustomerID,Product_Category,quarter_tr,tt_spending,row_number() OVER (PARTITION BY quarter_tr ORDER BY TT_SPENDING DESC) AS SpendingRank
FROM shopping)SELECT distinct CustomerID,Product_Category,quarter_tr,TT_SPENDING AS TotalSpending,spendingrank FROM RankedCustomers
WHERE SpendingRank <= 3 order by quarter_tr,customerid;

##4 Top 3 selling products quarter-wise
WITH RankedProduct AS (select quarter_tr,product_category,sp_prod,
row_number () over(partition by quarter_tr order by sp_prod desc) rank_prod from (select product_category,quarter_tr,sum(tt_spending) sp_prod 
from shopping group by quarter_tr,product_category) dt)select * from RankedProduct where rank_prod<=3;

##5 we'll find the total spending and average discount percentage for each product category, along with the highest and 
## lowest discount percentage. Additionally, we'll include only those categories where the average discount percentage 
## is above a certain threshold.

WITH DiscountStats AS (
SELECT Product_Category,SUM(TT_SPENDING) AS TotalSpending,AVG(Discount_pct) AS AvgDiscount,
MAX(Discount_pct) AS MaxDiscount,MIN(Discount_pct) AS MinDiscount FROM shopping 
GROUP BY Product_Category HAVING AVG(Discount_pct) > 19 )
SELECT ds.Product_Category,ds.TotalSpending,ds.AvgDiscount,ds.MaxDiscount,ds.MinDiscount FROM DiscountStats ds;

-- drop procedure gender_wise

##6 Gender and CustomerId wise transaction count, TotalSpending and Avg_Spending.

delimiter //
create procedure gender_wise(in thresh int)
begin 
select  Gender,customerid,COUNT(Transaction_ID) AS TransactionCount,SUM(TT_SPENDING) AS TotalSpending,AVG(TT_SPENDING) AS AvgSpendingPerTransaction 
from shopping s2 group by Gender,customerid having (customerid,AVG(TT_SPENDING)) in 
(SELECT customerid,AVG(TT_SPENDING) AS AvgSpendingPerTransaction 
FROM shopping s1 where s1.customerid=s2.customerid
GROUP BY customerid HAVING AvgSpendingPerTransaction > thresh ) order by customerid;
end;
delimiter //

call gender_wise(5100);


select transaction_date from shopping;