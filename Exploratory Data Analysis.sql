CREATE TABLE Employee (
    EmployeeID VARCHAR PRIMARY KEY,
    FirstName VARCHAR,
    LastName VARCHAR,
    Gender VARCHAR,
    Age INT,
    BusinessTravel VARCHAR,
    Department VARCHAR,
    DistanceFromHome_KM INT,
    State VARCHAR,
    Ethnicity VARCHAR,
    EducationLevelID INT,
    JobLevel TEXT,
    JobRole VARCHAR,
    MaritalStatus VARCHAR,
    Salary INT,
    StockOptionLevel INT,
    OverTime VARCHAR,
    HireDate DATE,
    Attrition VARCHAR,
    YearsAtCompany INT,
    YearsInMostRecentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT
);

CREATE TABLE Education (
    EducationLevelID INT PRIMARY KEY,
    EducationLevel VARCHAR
);

CREATE TABLE PerformanceRating (
    PerformanceID VARCHAR PRIMARY KEY,
    EmployeeID VARCHAR,
    ReviewDate DATE,
    EnvironmentSatisfaction INT,
    JobSatisfaction INT,
    RelationshipSatisfaction INT,
    TrainingOpportunitiesWithinYear INT,
    TrainingOpportunitiesTaken INT,
    WorkLifeBalance INT,
    SelfRating INT,
    ManagerRating INT,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

CREATE TABLE Rating (
    RatingID INT PRIMARY KEY,
    RatingLevel VARCHAR
);

CREATE TABLE SatisfactionLevel (
    SatisfactionID INT PRIMARY KEY,
    SatisfactionLevel VARCHAR
);

/*==================================================================
                   Exploratory Data Analysis (EDA)
==================================================================*/

-- 1. Total number of employees.

SELECT COUNT(*) 
FROM Employee;

-- 2. Count of employees by gender.

SELECT 
	Gender, 
	COUNT(*) 
FROM Employee 
GROUP BY Gender;

-- 3. Count of employees by department.

SELECT 
	Department, 
	COUNT(*)
FROM Employee 
GROUP BY Department;

-- 4. Average salary by department.

SELECT 
	Department, 
	ROUND(AVG(Salary), 2) AS Avg_Salary
FROM Employee 
GROUP BY Department;

-- 5. Count of employees who left.

SELECT COUNT(*) 
FROM Employee 
WHERE Attrition = 'Yes';

-- 6. Percentage of attrition overall.

SELECT 
  ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Attrition_Percent
FROM Employee;

-- 7. Average years at company.

SELECT 
	ROUND(AVG(YearsAtCompany), 2) AS Avg_Years_At_Company 
FROM Employee;

-- 8. Minimum and maximum age.

SELECT 
	MIN(Age) AS Min_Age, 
	MAX(Age) AS Max_Age 
FROM Employee;

-- 9. Distribution of business travel types.

SELECT 
	BusinessTravel, 
	COUNT(*) 
FROM Employee 
GROUP BY BusinessTravel;

-- 10. Most common job role.

SELECT 
	JobRole, 
	COUNT(*) AS Count
FROM Employee 
GROUP BY JobRole 
ORDER BY Count DESC LIMIT 1;

-- 11. Attrition rate by department.

SELECT 
	Department,
  	ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Attrition_Rate
FROM Employee
GROUP BY Department;

-- 12. Average satisfaction score by department. 

SELECT e.Department, 
       ROUND(AVG(p.JobSatisfaction), 2) AS Avg_JobSatisfaction
FROM Employee e
JOIN PerformanceRating p 
	ON e.EmployeeID = p.EmployeeID
GROUP BY e.Department;

-- 13. Count of employees by marital status and gender.

SELECT 
	MaritalStatus, 
	Gender, 
	COUNT(*) 
FROM Employee
GROUP BY 
	MaritalStatus, 
	Gender;

-- 14. Top 5 job roles with highest attrition.

SELECT 
	JobRole, 
	COUNT(*) AS Attrition_Count
FROM Employee
WHERE Attrition = 'Yes'
GROUP BY JobRole
ORDER BY Attrition_Count DESC
LIMIT 5;

-- 15. Average number of training opportunities taken by attrition status.

SELECT 
	Attrition, 
	ROUND(AVG(TrainingOpportunitiesTaken), 2) AS Avg_Trainings
FROM Employee e
JOIN PerformanceRating p 
	ON e.EmployeeID = p.EmployeeID
GROUP BY Attrition;

-- 16. Average work-life balance score by job role.

SELECT 
	e.JobRole, 
	ROUND(AVG(p.WorkLifeBalance), 2) AS Avg_WorkLifeBalance
FROM Employee e
JOIN PerformanceRating p 
	ON e.EmployeeID = p.EmployeeID
GROUP BY e.JobRole;

-- 17. Distribution of stock option levels across departments.

SELECT 
	Department, 
	StockOptionLevel, 
	COUNT(*) 
FROM Employee
GROUP BY 
	Department, 
	StockOptionLevel
ORDER BY Department;

-- 18. Do younger employees leave more?

SELECT 
	Age,
  	ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Attrition_Rate
FROM Employee
GROUP BY Age
ORDER BY Age;

-- 19. Rank employees by salary within department.

SELECT 
	EmployeeID, 
	Department, 
	Salary,
    RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS Salary_Rank
FROM Employee;

-- 20. Year-wise attrition trend.

WITH Attrition_By_Year AS (
  SELECT 
  	  EXTRACT(YEAR FROM HireDate) AS Hire_Year,
      COUNT(*) FILTER (WHERE Attrition = 'Yes') AS Attrition_Count,
      COUNT(*) AS Total
  FROM Employee
  GROUP BY Hire_Year
)
SELECT 
	Hire_Year,
    Attrition_Count,
    Total,
    ROUND(100.0 * Attrition_Count / Total, 2) AS Attrition_Percentage
FROM Attrition_By_Year
ORDER BY Hire_Year;

-- 21. Avg Manager vs Self Rating by Attrition.

SELECT 
	e.Attrition,
    ROUND(AVG(p.ManagerRating), 2) AS Avg_ManagerRating,
    ROUND(AVG(p.SelfRating), 2) AS Avg_SelfRating
FROM Employee e
JOIN PerformanceRating p 
	ON e.EmployeeID = p.EmployeeID
GROUP BY e.Attrition;

-- 22. Time in role vs attrition.

SELECT 
	Attrition, 
	ROUND(AVG(YearsInMostRecentRole), 2) AS Avg_YearsInRole
FROM Employee
GROUP BY Attrition;

-- 23. Bucket employees by age and analyze attrition.

SELECT 
  	CASE 
    	WHEN Age < 30 THEN 'Under 30'
    	WHEN Age BETWEEN 30 AND 40 THEN '30-40'
   	 	WHEN Age BETWEEN 41 AND 50 THEN '41-50'
    	ELSE '51+' 
	END AS Age_Group,
  	ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Attrition_Rate
FROM Employee
GROUP BY Age_Group;

-- 24. Employees with >1 training but low performance.

SELECT 
	e.EmployeeID, 
	p.TrainingOpportunitiesTaken, 
	p.ManagerRating
FROM Employee e
JOIN PerformanceRating p 
	ON e.EmployeeID = p.EmployeeID
WHERE p.TrainingOpportunitiesTaken > 1 
	AND p.ManagerRating < 3;

-- 25. Department-wise avg satisfaction (all types).

SELECT 
	e.Department,
    ROUND(AVG(p.EnvironmentSatisfaction), 2) AS Env_Satisfaction,
    ROUND(AVG(p.JobSatisfaction), 2) AS Job_Satisfaction,
    ROUND(AVG(p.RelationshipSatisfaction), 2) AS Rel_Satisfaction
FROM Employee e
JOIN PerformanceRating p 
	ON e.EmployeeID = p.EmployeeID
GROUP BY e.Department
ORDER BY e.Department;
