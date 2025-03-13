

/*										Data Modeling
Join Performance Table And Satisfactionlevel And Rating Tables>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
SELECT P.PerformanceID,P.EmployeeID,P.ReviewDate ,P.EnvironmentSatisfaction, S_Env.SatisfactionLevel EnvironmentSatisfaction,
P.JobSatisfaction, S_Job.SatisfactionLevel JobSatisfaction , P.RelationshipSatisfaction , S_Rel.SatisfactionLevel RelationshipSatisfaction, 
p.WorkLifeBalance , S_Work.SatisfactionLevel WorkLifeBalance, p.SelfRating , R_Self.RatingLevel SelfRating , 
P.ManagerRating ,R_Mang.RatingLevel ManagerRating,
P.TrainingOpportunitiesWithinYear,P.TrainingOpportunitiesTaken
FROM  PerformanceRating P
 JOIN SatisfiedLevel S_Env
ON p.EnvironmentSatisfaction = S_Env.SatisfactionID
 JOIN SatisfiedLevel S_Job
ON P.JobSatisfaction  =  S_Job.SatisfactionID
 JOIN SatisfiedLevel S_Rel
ON P.RelationshipSatisfaction = S_Rel.SatisfactionID
 JOIN SatisfiedLevel S_Work
ON P.WorkLifeBalance  =  S_Work.SatisfactionID
 JOIN RatingLevel R_Self
ON p.SelfRating = R_Self.RatingID
 JOIN RatingLevel R_Mang
ON p.ManagerRating = R_Mang.RatingID


--Join Employee Table And EducationLevel Table>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT  * 
FROM Employee E
join EducationLevel ED
ON E.Education = ED.EducationLevelID

 
--Get Employees Not Rated Yet FROM Employee Table>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT DISTINCT EmployeeID FROM PerformanceRating

--Get Employees Not Rated Yet FROM Employee Table>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT COUNT (E.EmployeeID)
FROM Employee E 
where E.EmployeeID not in (SELECT DISTINCT P.EmployeeID FROM PerformanceRating P)


SELECT Distinct(EmployeeID) AS UnratedEmployees , YearsAtCompany
FROM Employee
WHERE EmployeeID NOT IN (SELECT DISTINCT EmployeeID FROM PerformanceRating);

--Years At Company For Employees Not Rated>>>>>>>>>>>>(0-1)>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT EmployeeID , YearsAtCompany
FROM Employee 
WHERE EmployeeID NOT IN (SELECT DISTINCT EmployeeID FROM PerformanceRating);


/*					OverView DashBoard
Total Employees >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
SELECT COUNT(*) AS 'Total Employees'
FROM Employee

SELECT COUNT(DISTINCT EmployeeID) TotalEmployees
FROM Employee;


--Get ttrition Count>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT 
    COUNT(CASE WHEN Attrition = 1 THEN 1 END) AS 'Attrition Count'
FROM Employee;


--Get ttrition Rate>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT 
    CAST(ROUND(SUM(CASE WHEN Attrition = 1 THEN 1 END) * 100.0 / COUNT(EmployeeID),2) AS DECIMAL(10,2)) AS 'Attrition Rate'
FROM Employee;


--Average Salary>>>>>>>>>>>>>>>>>>>>>(112956 k)>>>>>>>>>>>>>>>>
SELECT AVG(Salary)
FROM Employee


--Average Age>>>>>>>>>>>>>>>>>>>>>(29.0)>>>>>>>>>>>>>>>>
SELECT CAST(AVG(CAST(Age AS FLOAT)) AS DECIMAL(10,1))
FROM Employee


--Average YearsAtCompany>>>>>>>>>>>>>>>>>>>>>(5.0)>>>>>>>>>>>>>>>>
SELECT CAST(AVG(CAST(YearsAtCompany AS FLOAT)) AS DECIMAL(10,0))
FROM Employee


-- OverTime >>>>>>>>>>>>>>>>>>(NO)>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT 
	SUM(CASE WHEN OverTime = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS YES,
	SUM(CASE WHEN OverTime = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS NO,
	Count (*) AS Total
FROM Employee  

-- Percentage Of Gender Distribution>>>>>>>>>>>>>>>>>>(NO)>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT 
	CAST(ROUND(SUM(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmployeeID),2) AS DECIMAL(10,2)) AS Male,
	CAST(ROUND(SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmployeeID),2) AS DECIMAL(10,2)) AS Female,
	CAST(ROUND(SUM(CASE WHEN Gender = 'Other' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmployeeID),2)AS DECIMAL(10,2)) AS Other,
	Count (*) AS Total
FROM Employee 


-- Percentage Of AgeRange&Gender Distribution>>>>>>>>>>>>>>>>>>(NO)>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT AgeRange,
	CAST(ROUND(SUM(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmployeeID),2) AS DECIMAL(10,2)) AS Male,
	CAST(ROUND(SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmployeeID),2) AS DECIMAL(10,2)) AS Female,
	CAST(ROUND(SUM(CASE WHEN Gender = 'Other' THEN 1 ELSE 0 END) * 100.0 / COUNT(EmployeeID),2)AS DECIMAL(10,2)) AS Other,
	Count (*) AS Total
FROM Employee 
GROUP BY AgeRange
ORDER BY Total DESC

/*				Employee DashBoard
Employees will be promoted due to (AVG Rating > 4.0  and YearsSinceLastPromotion > 4 years )*/
SELECT COUNT(E.EmployeeID) AS EmployeeCount, E.JobRole , 
AVG(AP.Avg_ManagerRating) AS Avg_ManagerRating,
MIN(E.YearsSinceLastPromotion) AS YearsSinceLastPromotion
FROM Employee E
JOIN (
SELECT P.EmployeeID,AVG(CAST(P.ManagerRating AS FLOAT)) AS Avg_ManagerRating
FROM PerformanceRating P
GROUP BY P.EmployeeID) AS AP 
ON E.EmployeeID = AP.EmployeeID
WHERE AP.Avg_ManagerRating > 4.0  
AND E.YearsSinceLastPromotion > 4  
GROUP BY E.JobRole
ORDER BY AVG(AP.Avg_ManagerRating) DESC;


--Employees will be Retrenched Due To (AVG Rating <3.5   and YearsInMostRecentRole > 5 years )
SELECT COUNT(E.EmployeeID) AS EmployeeCount, E.JobRole , 
AVG(AP.Avg_ManagerRating) AS Avg_ManagerRating,
MIN(E.YearsInMostRecentRole) AS YearsInMostRecentRole
FROM Employee E
JOIN (
SELECT P.EmployeeID,AVG(CAST(P.ManagerRating AS FLOAT)) AS Avg_ManagerRating
FROM PerformanceRating P
GROUP BY P.EmployeeID) AS AP 
ON E.EmployeeID = AP.EmployeeID
WHERE AP.Avg_ManagerRating < 3.5 
AND E.YearsInMostRecentRole > 5  
GROUP BY E.JobRole
ORDER BY AVG(AP.Avg_ManagerRating) DESC;



--Identify Last Year In Data
select Max(P.ReviewDate) as 'last ReviewDate' , Max(E.HireDate) as 'last HireDate'
FROM Employee E
JOIN PerformanceRating P
ON E.EmployeeID = p.EmployeeID




--Identify Employees who will be Retired (Whose Age 65 Years) Per each Year Based on Last Year In Data>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT 2023 + (65 - Age) AS RetirementYear, 
    COUNT(EmployeeID) AS EmployeesCount
FROM Employee
GROUP BY 2023 + (65 - Age)
ORDER BY RetirementYear;



--JobSatisfactiON Per JobRole >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT E.JobRole,
    SUM(CASE WHEN S.SatisfactiONID = 5 THEN 1 ELSE 0 end) AS Very_Satisfied,
    SUM(CASE WHEN S.SatisfactiONID = 4 THEN 1 ELSE 0 end) AS Satisfied,
    SUM(CASE WHEN S.SatisfactiONID = 3 THEN 1 ELSE 0 end) AS Neutral,
    SUM(CASE WHEN S.SatisfactiONID = 2 THEN 1 ELSE 0 end) AS Dissatisfied,
	SUM(CASE WHEN S.SatisfactiONID = 1 THEN 1 ELSE 0 end) AS Very_Dissatisfied,
    COUNT(*) AS Total
FROM Employee E
JOIN PerformanceRating P
ON E.EmployeeID = p.EmployeeID
JOIN SatisfiedLevel S
ON p.JobSatisfactiON = S.SatisfactiONID
GROUP BY E.JobRole
ORDER BY Total DESC


/*						Salary DashBoard
--MAXIMUM And Min And AVG Salary  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
SELECT min(Salary) MINIMUM,max(Salary)MAXIMUM ,AVG(Salary) Average
FROM Employee

--Lowest Salary Per AgeRange,Gender >>>>>>>>>>>>>>>>Male(18-30) >>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT  AgeRange , Gender , AVG(Salary) 'Average Salary'
FROM Employee
GROUP BY AgeRange , Gender
ORDER BY AVG(Salary) ASc

--Highest Salary Per AgeRange,Gender >>>>>>>>>>>>>>>>Male(> 50) >>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT  AgeRange , Gender , AVG(Salary) 'Average Salary'
FROM Employee
GROUP BY AgeRange , Gender
ORDER BY AVG(Salary) DESC

--Highest Salary Per AgeRange>>>>>>>>>>>>>>>>( > 50)>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT  AgeRange , AVG(Salary) 'Average Salary'
FROM Employee
GROUP BY AgeRange
ORDER BY AVG(Salary) DESC

--Highest Salary Per Gender>>>>>>>>>>>>>>>>Female >>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT  Gender , AVG(Salary) 'Average Salary'
FROM Employee
GROUP BY Gender
ORDER BY AVG(Salary) DESC


--Highest Salary Per Department >>>>>>>>>>>>>HR>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT Department , AVG(salary) 'Average Salary'
FROM Employee	
GROUP BY Department
ORDER BY AVG(salary) DESC

--Highest Salary Per JobRole >>>>>>>>>>>>>>>>>>HR Manager>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT JobRole , AVG(salary) 'Average Salary'
FROM Employee	
GROUP BY JobRole
ORDER BY AVG(salary) DESC

--Salary Per OverTime >>>>>>>>>>>>>>>>>>No>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT OverTime , AVG(salary) 'Average Salary',
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS YES,
	SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS NO,
	Count (*) AS Total
FROM Employee	
GROUP BY OverTime
ORDER BY AVG(salary) DESC



--Performance DashBoard

/*Top5 Employees Due To Performance>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
WITH AvgRating AS (
    SELECT 
        PR.EmployeeID,
        AVG(PR.ManagerRating) AS AvgManagerRating
    FROM PerformanceRating PR
    GROUP BY PR.EmployeeID
)
SELECT TOP 5
    E.EmployeeID,
    A.AvgManagerRating
FROM AvgRating A
INNER JOIN Employee E ON A.EmployeeID = E.EmployeeID
ORDER BY A.AvgManagerRating DESC;








/*				Attrition DashBoard
 Attrition per Marital Status >>>>>>>>>>>>>>>>>>>>(Single)>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
SELECT MaritalStatus,
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS YES,
	SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS NO,
	Count (*) AS Total
FROM Employee  
GROUP BY MaritalStatus
ORDER BY YES DESC

--AttritiON Per AgeRange,Gender >>>>>>>>>>>>>>>>male(18-30) >>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT AgeRange , Gender,
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS YES,
	SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS NO,
	Count (*) AS Total
FROM Employee  
GROUP BY AgeRange , Gender
ORDER BY YES DESC



--AttritiON Per Gender>>>>>>>>>>>>>>>>Female >>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT  COALESCE(Gender,'Total') AS Attrition,
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS YES,
	SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS NO,
	Count (*) AS Total
FROM Employee
GROUP BY Gender
WITH ROLLUP

--AttritiON Per AgeRange>>>>>>>>>>>>>>>>(18-30) >>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT AgeRange ,
SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS YES,
	SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS NO,
	Count (*) AS Total
FROM Employee  
GROUP BY AgeRange
ORDER BY AgeRange


--Attrition per salary >>>>>>>>>>>>>>>>>>>>>>>>>>>>>(YES)>>>>>>>>>>>>>>>>>>>>>>
WITH SalaryGroups AS (
    SELECT 
        EmployeeID,
        Attrition,
        CASE 
            WHEN TRY_CAST(Salary AS INT) < 50000 THEN 'Below 50K'
            WHEN TRY_CAST(Salary AS INT) BETWEEN 50000 AND 100000 THEN '50K-100K'
            WHEN TRY_CAST(Salary AS INT) BETWEEN 100000 AND 150000 THEN '100K-150K'
			WHEN TRY_CAST(Salary AS INT) BETWEEN 150000 AND 300000 THEN '150K-3000K'
            WHEN TRY_CAST(Salary AS INT) > 300000 THEN 'Above 300K'
            ELSE 'Unknown'
        END AS Salary_Range
    FROM Employee
    WHERE TRY_CAST(Salary AS INT) IS NOT NULL  -- Ensuring Salary is a valid numeric value
)
SELECT 
    Salary_Range,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS Attrition_Count,
    SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) AS Retention_Count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS Attrition_Rate
FROM SalaryGroups
WHERE Attrition IN (1, 0)  -- Ensuring only valid attrition values
GROUP BY Salary_Range
ORDER BY Attrition_Rate DESC;


--AttritiON Per Department>>>>>>>>>>>>>>>>Sales >>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT Department,
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS YES,
	SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS NO,
	Count (*) AS Total
FROM Employee  
GROUP BY Department
ORDER BY YES DESC

--Attrition per Department>>>>>>>>>>>>>>>>>>>(2nd)>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT 
    Department,
    SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS AttritionCount,
    COUNT(*) AS TotalEmployees,
    ROUND(
        (SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
        2
    ) AS AttritionRate -- Percentage
FROM Employee
GROUP BY Department;



--AttritiON Per JobRole>>>>>>>>>>>>>>>>Sales Representative >>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT JobRole,
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS YES,
	SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS NO,
	Count (*) AS Total
FROM Employee  
GROUP BY JobRole
ORDER BY YES DESC

------------------------------------------------------
-- Attrition per Years Since Last Promotion >>>>>>>>>>>>>>>>>>(NO)>>>>>>>>>>>>>>>>>>>>
SELECT YearsSinceLastPromotion,
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS YES,
	SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS NO,
	Count (*) AS Total
FROM Employee  
GROUP BY YearsSinceLastPromotion
ORDER BY YearsSinceLastPromotion DESC

-- Attrition per OverTime >>>>>>>>>>>>>>>>>>(NO)>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT OverTime,
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS YES,
	SUM(CASE WHEN Attrition = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS NO,
	Count (*) AS Total
FROM Employee  
GROUP BY OverTime


--OverTime Per Department>>>>>>>>>>>>>>>>(Sales) >>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT Department,
	SUM(CASE WHEN OverTime = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS YES,
	SUM(CASE WHEN OverTime = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS NO,
	Count (*) AS Total
FROM Employee
GROUP BY Department









