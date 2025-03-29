-- Objective 2
SELECT CustomerId, Surname, EstimatedSalary as maxsalary,
	YEAR(`Bank DOJ`) as year,
    QUARTER(`Bank DOJ`) as quarter
FROM
	customerinfo
WHERE
	QUARTER(`Bank DOJ`) = 4
ORDER BY
	EstimatedSalary DESC
LIMIT 5;


-- Objective 3
SELECT 
    AVG(bc.NumOfProducts) AS AvgProductsWithCreditCard
FROM 
    bank_churn bc
JOIN 
    creditcard cc ON bc.HasCrCard = cc.CreditID
WHERE 
    cc.CreditID = 1;
    
    
-- Objective 5
SELECT 
    ec.ExitCategory,
    AVG(bc.CreditScore) AS AverageCreditScore
FROM 
    bank_churn bc
JOIN 
    exitcustomer ec ON bc.Exited = ec.ExitID
GROUP BY 
    ec.ExitCategory;
    

-- Objective 6
SELECT 
    g.GenderCategory,
    ROUND(AVG(ci.EstimatedSalary),2) AS AverageSalary,
    COUNT(bc.IsActiveMember) AS ActiveAccounts
FROM 
    customerinfo ci
JOIN 
    gender g ON ci.GenderID = g.GenderID
JOIN 
    bank_churn bc ON ci.CustomerId = bc.CustomerIdD
JOIN 
    activecustomer ac ON bc.IsActiveMember = ac.ActiveID
WHERE ac.ActiveID = 1
GROUP BY 
    g.GenderCategory;
    

-- Objective 7
SELECT 
    CASE 
        WHEN bc.CreditScore between 800 and 850 then 'Excellent'
        WHEN bc.CreditScore between 740 and 799 then 'Very Good'
        WHEN bc.CreditScore between 670 and 739 then 'Good'
        WHEN bc.CreditScore between 580 and 669 then 'Fair'
        WHEN bc.CreditScore between 300 and 579 then 'Poor'
    END AS CreditScoreSegment,
    COUNT(*) AS TotalCustomers,
    SUM(bc.Exited) AS ExitedCustomers,
    SUM(bc.Exited) / COUNT(*) AS ExitRate
FROM 
    bank_churn bc
GROUP BY 
    CreditScoreSegment
ORDER BY 
    ExitRate DESC
LIMIT 1;


-- Objective 8
SELECT 
    geo.GeographyLocation,
    COUNT(*) AS ActiveCustomers
FROM 
    customerinfo ci
JOIN 
    geography geo ON ci.GeographyID = geo.GeographyID
JOIN 
    bank_churn bc ON ci.CustomerId = bc.CustomerIdD
WHERE 
    bc.IsActiveMember = 1
    AND bc.Tenure > 5
GROUP BY 
    geo.GeographyLocation
ORDER BY 
    ActiveCustomers DESC
LIMIT 1;


-- Objective 10
SELECT 
    NumOfProducts,
    COUNT(*) AS NumOfCustomers
FROM 
    Bank_Churn
WHERE 
    Exited = 1
GROUP BY 
    NumOfProducts
ORDER BY 
    NumOfCustomers DESC;


-- Objective 15
SELECT 
	RANK() OVER (PARTITION BY geo.GeographyLocation ORDER BY AVG(EstimatedSalary) DESC) AS GenderRank,
    geo.GeographyLocation,
    GenderCategory,
    ROUND(AVG(EstimatedSalary),2) AS AverageIncome
    
FROM 
    customerinfo ci
JOIN 
    gender g ON ci.GenderID = g.GenderID
JOIN
	geography geo ON ci.GeographyID = geo.GeographyID
GROUP BY 
    geo.GeographyLocation, GenderCategory;
    
    
-- Objective 16
SELECT 
    CASE 
        WHEN ci.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN ci.Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '50+'
    END AS AgeBracket,
    AVG(Tenure) AS AverageTenure
FROM 
    bank_churn bc
JOIN 
	customerinfo ci ON bc.CustomerIdD = ci.CustomerId
WHERE 
    Exited = 1
GROUP BY 
    AgeBracket;
    
    
-- Objective 17
-- Correlation coefficient for all customers
SELECT 
    CORREL(ci.EstimatedSalary, bc.Balance) AS Correlation_AllCustomers
FROM 
    CustomerInfo ci
JOIN 
    Bank_Churn bc ON ci.CustomerID = bc.CustomerID;

    
    
-- Objective 19
SELECT 
    CreditScoreBucket,
    COUNT(*) AS ChurnedCustomers,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS CreditScoreRank
FROM (
    SELECT 
        CASE 
            WHEN CreditScore between 800 and 850 then 'Excellent'
			WHEN CreditScore between 740 and 799 then 'Very Good'
			WHEN CreditScore between 670 and 739 then 'Good'
			WHEN CreditScore between 580 and 669 then 'Fair'
			WHEN CreditScore between 300 and 579 then 'Poor'
        END AS CreditScoreBucket
    FROM 
        bank_churn
    WHERE 
        Exited = 1
) AS ChurnedData
GROUP BY 
    CreditScoreBucket;
    

-- Objective 20
-- Calculate the number of customers with a credit card for each age bucket
SELECT 
    CASE 
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '50+'
    END AS AgeBucket,
    COUNT(CASE WHEN HasCrCard = 1 THEN CustomerId END) AS CreditCardCustomers
FROM 
    customerinfo ci
JOIN 
    bank_churn bc ON ci.CustomerId = bc.CustomerIdD
GROUP BY 
    AgeBucket;
    
-- ------------------------------------------------------------------------
SELECT 
    AgeBucket,
    CreditCardCustomers
FROM (
    SELECT 
        CASE 
            WHEN Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN Age BETWEEN 31 AND 50 THEN '31-50'
            ELSE '50+'
        END AS AgeBucket,
        COUNT(CASE WHEN HasCrCard = 1 THEN CustomerId END) AS CreditCardCustomers,
        AVG(COUNT(CASE WHEN HasCrCard = 1 THEN CustomerId END)) OVER () AS AvgCreditCardCount
    FROM 
        customerinfo ci
    JOIN 
        bank_churn bc ON ci.CustomerId = bc.CustomerIdD
    GROUP BY 
        AgeBucket
) AS CreditCardCounts
WHERE 
    CreditCardCustomers < AvgCreditCardCount;
    
    
-- Objective 21
SELECT 
    GeographyLocation,
    TotalChurnedCustomers,
    AvgBalance,
    RANK() OVER (ORDER BY TotalChurnedCustomers DESC, AvgBalance DESC) AS LocationRank
FROM (
    SELECT 
        g.GeographyLocation,
        COUNT(bc.CustomerIdD) AS TotalChurnedCustomers,
        ROUND(AVG(bc.Balance),2) AS AvgBalance
    FROM 
        bank_churn bc
    JOIN 
        customerinfo ci ON bc.CustomerIdD = ci.CustomerId
    JOIN 
        geography g ON ci.GeographyID = g.GeographyID
	WHERE 
		bc.Exited = 1
    GROUP BY 
        g.GeographyLocation
) AS LocationStats;


-- Objective 22
SELECT 
    CONCAT(CustomerID, '_', Surname) AS CustomerID_Surname
FROM 
    CustomerInfo;



-- Objective 23
SELECT 
    bc.*,
    (SELECT ExitCategory FROM exitcustomer WHERE ExitID = bc.Exited) AS ExitCategory
FROM 
    bank_churn bc;
    
    
-- Objective 25
SELECT 
    ci.CustomerID,
    ci.Surname,
    ac.ActiveCategory
FROM 
    CustomerInfo ci
LEFT JOIN 
    Bank_Churn bc ON ci.CustomerId = bc.CustomerIdD
LEFT JOIN 
    ActiveCustomer ac ON bc.IsActiveMember = ac.ActiveID
WHERE 
    ci.Surname LIKE '%on';
    
    
-- Subjective 9
-- Segment customers by age bracket
SELECT
    CASE
        WHEN Age >= 18 AND Age <= 30 THEN '18-30'
        WHEN Age > 30 AND Age <= 50 THEN '30-50'
        ELSE '50+'
    END AS Age_Bracket,
    COUNT(*) AS Customer_Count
FROM
    customerinfo
GROUP BY
    Age_Bracket;
    
-- Segment customers by gender
SELECT
    g.GenderCategory,
    COUNT(*) AS Customer_Count
FROM
    customerinfo ci
JOIN
	gender g ON ci.GenderID = g.GenderID
GROUP BY
    g.GenderCategory;
    
-- Segemnt customer by account detail (Credit Score)
SELECT 
	CASE 
		WHEN CreditScore between 800 and 850 then 'Excellent'
		WHEN CreditScore between 740 and 799 then 'Very Good'
		WHEN CreditScore between 670 and 739 then 'Good'
		WHEN CreditScore between 580 and 669 then 'Fair'
		WHEN CreditScore between 300 and 579 then 'Poor'
	END AS CreditScoreBucket,
	COUNT(*) AS CustomersNum
FROM 
	bank_churn
GROUP BY 
	CreditScoreBucket;


-- Subjective 14
ALTER TABLE bank_churn
RENAME COLUMN HasCrCard TO Has_creditcard;














