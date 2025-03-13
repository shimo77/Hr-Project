

/* Get Unique Values FROM PerformanceRating Table>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
SELECT DISTINCT(PerformanceID)
FROM PerformanceRatINg 
GROUP BY PerformanceID


/*Remove Duplicates FROM PerformanceRating Table>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
DELETE FROM PerformanceRatINg
WHERE PerformanceID IN (
	SELECT PerformanceID 
	FROM PerformanceRatINg 
	GROUP BY PerformanceID
	HAVING(COUNT(*)>1))


	
/*Get NULL Values FROM PerformanceRatINg TABLE>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
SELECT * FROM PerformanceRatINg
WHERE EmployeeID IS NULL 
   OR ReviewDate IS NULL 
   OR EnvirONmentSatISfactiON IS NULL
   OR JobSatISfactiON IS NULL
   OR RelatiONshipSatISfactiON IS NULL
   OR TraININgOpportunitiesTaken IS NULL
   OR TraININgOpportunitiesWithINYear IS NULL
   OR WorkLifeBalance IS NULL
   OR SelfRatINg IS NULL
   OR ManagerRatINg IS NULL




--Handling Null Values in Numerical Fields>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--Replace NULL EnvironmentSatisfaction With Average value
UPDATE PerformanceRating
SET EnvironmentSatisfaction= (
    SELECT AVG(EnvironmentSatisfaction)
    FROM PerformanceRating
    WHERE EnvironmentSatisfaction IS NOT NULL
)
WHERE EnvironmentSatisfaction IS NULL                                                                                                                    IS NULL

-- Replace NULL JobSatisfaction with Average value
DECLARE @AvgJobSatisfaction FLOAT;
SET @AvgJobSatisfaction = (SELECT AVG(JobSatisfaction) FROM PerformanceRating WHERE JobSatisfaction IS NOT NULL);
UPDATE PerformanceRating
SET JobSatisfaction = @AvgJobSatisfaction
WHERE JobSatisfaction IS NULL;

/*Replace NULL RelationshipSatisfaction With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
DECLARE @RelationshipSatisfaction FLOAT;
SET @RelationshipSatisfaction = (SELECT AVG(RelationshipSatisfaction) FROM PerformanceRating WHERE RelationshipSatisfaction IS NOT NULL);
UPDATE PerformanceRating
SET RelationshipSatisfaction = @RelationshipSatisfaction
WHERE RelationshipSatisfaction IS NULL;

/*Replace NULL TrainingOpportunitiesWithinYear With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
DECLARE @TrainingOpportunitiesWithinYear FLOAT;
SET @TrainingOpportunitiesWithinYear = (SELECT AVG(TrainingOpportunitiesWithinYear) FROM PerformanceRating WHERE TrainingOpportunitiesWithinYear IS NOT NULL);
UPDATE PerformanceRating
SET TrainingOpportunitiesWithinYear = @TrainingOpportunitiesWithinYear
WHERE TrainingOpportunitiesWithinYear IS NULL;


/*Replace NULL TrainingOpportunitiesTaken With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
DECLARE @TrainingOpportunitiesTaken  FLOAT;
SET @TrainingOpportunitiesTaken  = (SELECT AVG(TrainingOpportunitiesTaken ) FROM PerformanceRating WHERE TrainingOpportunitiesTaken  IS NOT NULL);
UPDATE PerformanceRating
SET TrainingOpportunitiesTaken  = @TrainingOpportunitiesTaken 
WHERE TrainingOpportunitiesTaken  IS NULL;
 

/*Replace NULL WorkLifeBalance With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
DECLARE @WorkLifeBalance  FLOAT;
SET @WorkLifeBalance  = (SELECT AVG(WorkLifeBalance ) FROM PerformanceRating WHERE WorkLifeBalance  IS NOT NULL);
UPDATE PerformanceRating
SET WorkLifeBalance  = @WorkLifeBalance 
WHERE WorkLifeBalance  IS NULL;



/*Replace NULL SelfRating With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
DECLARE @SelfRating  FLOAT;
SET @SelfRating  = (SELECT AVG(SelfRating ) FROM PerformanceRating WHERE SelfRating  IS NOT NULL);
UPDATE PerformanceRating
SET SelfRating  = @SelfRating
WHERE SelfRating  IS NULL;

/*Replace NULL ManagerRating With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
DECLARE @ManagerRating  FLOAT;
SET @ManagerRating  = (SELECT AVG(ManagerRating ) FROM PerformanceRating WHERE ManagerRating  IS NOT NULL);
UPDATE PerformanceRating
SET ManagerRating  = @ManagerRating
WHERE ManagerRating  IS NULL;
 
 --Handling Null Values in Categorical Fields>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 /*Replace NULL EmployeeID With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE PerformanceRating
SET EmployeeID = COALESCE(EmployeeID, 
    (SELECT TOP 1 EmployeeID 
     FROM PerformanceRating 
     WHERE EmployeeID IS NOT NULL 
     GROUP BY EmployeeID 
     ORDER BY COUNT(*) DESC)
);

 /*Replace NULL ReviewDate With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE PerformanceRating
SET ReviewDate = COALESCE(ReviewDate, 
    (SELECT TOP 1 ReviewDate 
     FROM PerformanceRating 
     WHERE ReviewDate IS NOT NULL 
     GROUP BY ReviewDate 
     ORDER BY COUNT(*) DESC)
);


/*Review Date Before HireDate*/
SELECT P.EmployeeID
FROM Employee E
JOIN PerformanceRatINg P
ON E.EmployeeID = P.EmployeeID
WHERE P.ReviewDate <= E.HireDate 


/*Review Date After AttritionDate*/
SELECT P.EmployeeID
FROM Employee E
JOIN PerformanceRatINg P
ON E.EmployeeID = P.EmployeeID
WHERE P.ReviewDate >=DATEADD(Year,YearsAtCompany,HireDate ) AND E.AttritiON = 1


--Remove Inconsistent Review Dates >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
DELETE FROM PerformanceRatINg
WHERE EmployeeID not IN (
SELECT P.EmployeeID
FROM Employee E
JOIN PerformanceRatINg P
ON E.EmployeeID = P.EmployeeID
WHERE P.ReviewDate >= E.HireDate AND
((P.ReviewDate <=DATEADD(Year,YearsAtCompany,HireDate)) AND E.AttritiON = 1 or E.AttritiON = 0 ))


--Remove Inconsistent Review Dates >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*
	DELETE P
	FROM PerformanceRatINg P
	JOIN Employee E
	ON P.EmployeeID = E.EmployeeID
	WHERE 
		-- Condition 1: DELETE for all employees WHERE ReviewDate IS before HireDate
		P.ReviewDate < E.HireDate 

		-- Condition 2: DELETE for AttritiON = 1 WHERE ReviewDate IS after the expected END date
		OR (P.ReviewDate > DATEADD(Year, E.YearsAtCompany, E.HireDate) AND E.AttritiON = 1);


/*ADD CHECK CONSTRAINT That ReviewDate IS Before HireDate >>>>>>>>>>>>>>>>>>>>>>>>*/
ALTER TABLE PerformanceRating
ADD CONSTRAINT ReviewBefore_CHECK CHECK (ReviewDate <= HireDate) OR
(ReviewDate > DATEADD(Year, YearsAtCompany, HireDate) AND AttritiON = 1)

CREATE TRIGGER Check_ReviewDate
ON PerformanCeRating
AFTER INSERT, UPDATE
AS
BEGIN
    -- Check if any rows were inserted or updated
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN employee e ON i.employeeid = e.employeeid
        WHERE i.reviewdate <= e.hiredate OR
		(i.ReviewDate > DATEADD(Year, E.YearsAtCompany, E.HireDate) AND E.AttritiON = 1)
    )
    BEGIN
        -- Raise an error if reviewdate is not greater than hiredate
        THROW 50000, 'Review date must be after hire date , and before attrition', 1;
    END
END;



/*RemovINg Extra Space FROM Columns IN Performance TABLE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
UPDATE PerformanceRatINg 
SET 
	PerformanceID= LTRIM(RTRIM(PerformanceID)),
    EmployeeID = LTRIM(RTRIM(EmployeeID)),
    ReviewDate = LTRIM(RTRIM(ReviewDate)),
    EnvirONmentSatISfactiON = LTRIM(RTRIM(EnvirONmentSatISfactiON)),
    JobSatISfactiON = LTRIM(RTRIM(JobSatISfactiON)),
    RelatiONshipSatISfactiON = LTRIM(RTRIM(RelatiONshipSatISfactiON)),
    TraININgOpportunitiesTaken = LTRIM(RTRIM(TraININgOpportunitiesTaken)),
    TraININgOpportunitiesWithINYear = LTRIM(RTRIM(TraININgOpportunitiesWithINYear)),
    WorkLifeBalance = LTRIM(RTRIM(WorkLifeBalance)),
	SelfRatINg = LTRIM(RTRIM(SelfRatINg)),
	ManagerRatINg = LTRIM(RTRIM(ManagerRatINg))



--Get Unique Values FROM Employee TABLE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT DISTINCT(EmployeeID)
FROM Employee 
GROUP BY EmployeeID



--Remove Duplicates FROM Employee TABLE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
DELETE FROM Employee 
WHERE EmployeeID IN (
        SELECT EmployeeID
        FROM Employee 
        GROUP BY EmployeeID 
        HAVING COUNT(*)  > 1 ) 


--Get NULL Values FROM Employee TABLE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SELECT * FROM Employee
WHERE FirstName IS NULL 
   OR LastName IS NULL 
   OR GENDer IS NULL
   OR Age IS NULL
   OR BusINessTravel IS NULL
   OR Department IS NULL
   OR DIStanceFROMHome_KM IS NULL
   OR State IS NULL
   OR Ethnicity IS NULL
   OR EducatiON IS NULL
   OR EducatiONField IS NULL
   OR JobRole IS NULL
   OR MaritalStatus IS NULL
   OR Salary IS NULL
   OR StockOptiONLevel IS NULL
   OR OverTime IS NULL
   OR HireDate IS NULL
   OR AttritiON IS NULL
   OR YearsAtCompany IS NULL
   OR YearsINMostRecentRole IS NULL
   OR YearsSINceLastPromotiON IS NULL
   OR YearsWithCurrManager IS NULL



--Handling Null Values in Numerical Fields>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--Replace NULL Salary With Average value
UPDATE Employee
SET Salary= (
    SELECT AVG(Salary)
    FROM Employee
    WHERE Salary IS NOT NULL
)
WHERE Salary IS NULL


/*Replace NULL Ages With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
UPDATE Employee
SET Age = (
			SELECT AVG(Age) FROM Employee
			WHERE Age IS NOT NULL)
WHERE Age IS NULL

/*Replace NULL DistanceFromHome_KM With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
UPDATE Employee
SET DistanceFromHome_KM = (
			SELECT AVG(DistanceFromHome_KM) FROM Employee
			WHERE DistanceFromHome_KM IS NOT NULL)
WHERE DistanceFromHome_KM IS NULL


/*Replace NULL Education With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
UPDATE Employee
SET Education = (
			SELECT AVG(Education) FROM Employee
			WHERE Education IS NOT NULL)
WHERE Education IS NULL

 /*Replace NULL Attrition With Average >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
-- Convert BIT to FLOAT to calculate the average
DECLARE @Attrition FLOAT;
SET @Attrition = (SELECT AVG(CAST(Attrition AS FLOAT)) FROM Employee WHERE Attrition IS NOT NULL);

-- Update NULL values with the calculated average (rounded to nearest 0 or 1)
UPDATE Employee
SET Attrition = ROUND(@Attrition, 0)  -- Round to 0 or 1 to keep BIT behavior
WHERE Attrition IS NULL;


/*Replace NULL StockOptionLevel With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
UPDATE Employee
SET StockOptionLevel = (
			SELECT AVG(StockOptionLevel) FROM Employee
			WHERE StockOptionLevel IS NOT NULL)
WHERE StockOptionLevel IS NULL

/*Replace NULL YearsAtCompany With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
UPDATE Employee
SET YearsAtCompany = (
			SELECT AVG(YearsAtCompany) FROM Employee
			WHERE YearsAtCompany IS NOT NULL)
WHERE YearsAtCompany IS NULL

/*Replace NULL YearsInMostRecentRole With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
UPDATE Employee
SET YearsInMostRecentRole = (
			SELECT AVG(YearsInMostRecentRole) FROM Employee
			WHERE YearsInMostRecentRole IS NOT NULL)
WHERE YearsInMostRecentRole IS NULL

/*Replace NULL YearsSinceLastPromotion With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
UPDATE Employee
SET YearsSinceLastPromotion = (
			SELECT AVG(YearsSinceLastPromotion) FROM Employee
			WHERE YearsSinceLastPromotion IS NOT NULL)
WHERE YearsSinceLastPromotion IS NULL

/*Replace NULL YearsWithCurrManager With Average value>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
UPDATE Employee
SET YearsWithCurrManager = (
			SELECT AVG(YearsWithCurrManager) FROM Employee
			WHERE YearsWithCurrManager IS NOT NULL)
WHERE YearsWithCurrManager IS NULL

 
 --Handling Null Values in Categorical Fields>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 /*Replace NULL FirstName With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE Employee
SET FirstName = COALESCE(FirstName, 
    (SELECT TOP 1 FirstName 
     FROM Employee 
     WHERE FirstName IS NOT NULL 
     GROUP BY FirstName 
     ORDER BY COUNT(*) DESC)
);

 /*Replace NULL LastName With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE Employee
SET LastName = COALESCE(LastName, 
    (SELECT TOP 1 LastName 
     FROM Employee 
     WHERE LastName IS NOT NULL 
     GROUP BY LastName 
     ORDER BY COUNT(*) DESC)
);


 /*Replace NULL Gender With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE Employee
SET Gender = COALESCE(Gender, 
    (SELECT TOP 1 Gender 
     FROM Employee 
     WHERE Gender IS NOT NULL 
     GROUP BY Gender 
     ORDER BY COUNT(*) DESC)
);

 /*Replace NULL BusinessTravel With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE Employee
SET BusinessTravel = COALESCE(BusinessTravel, 
    (SELECT TOP 1 BusinessTravel 
     FROM Employee 
     WHERE BusinessTravel IS NOT NULL 
     GROUP BY BusinessTravel 
     ORDER BY COUNT(*) DESC)
);


 /*Replace NULL Department With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE Employee
SET Department = COALESCE(Department, 
    (SELECT TOP 1 FirstName 
     FROM Employee 
     WHERE Department IS NOT NULL 
     GROUP BY Department , FirstName 
     ORDER BY COUNT(*) DESC)
);


 /*Replace NULL State With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE Employee
SET State = COALESCE(State, 
    (SELECT TOP 1 State 
     FROM Employee 
     WHERE State IS NOT NULL 
     GROUP BY State 
     ORDER BY COUNT(*) DESC)
);


 /*Replace NULL Ethnicity With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE Employee
SET Ethnicity = COALESCE(Ethnicity, 
    (SELECT TOP 1 Ethnicity 
     FROM Employee 
     WHERE Ethnicity IS NOT NULL 
     GROUP BY Ethnicity 
     ORDER BY COUNT(*) DESC)
);


 /*Replace NULL EducationField With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE Employee
SET EducationField = COALESCE(EducationField, 
    (SELECT TOP 1 EducationField 
     FROM Employee 
     WHERE EducationField IS NOT NULL 
     GROUP BY EducationField 
     ORDER BY COUNT(*) DESC)
);

 /*Replace NULL JobRole With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE Employee
SET JobRole = COALESCE(JobRole, 
    (SELECT TOP 1 JobRole 
     FROM Employee 
     WHERE JobRole IS NOT NULL 
     GROUP BY JobRole 
     ORDER BY COUNT(*) DESC)
);


 /*Replace NULL MaritalStatus With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE Employee
SET MaritalStatus = COALESCE(MaritalStatus, 
    (SELECT TOP 1 MaritalStatus 
     FROM Employee 
     WHERE MaritalStatus IS NOT NULL 
     GROUP BY MaritalStatus 
     ORDER BY COUNT(*) DESC)
);

 /*Replace NULL OverTime With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE Employee
SET OverTime = COALESCE(OverTime, 
    (SELECT TOP 1 OverTime 
     FROM Employee 
     WHERE OverTime IS NOT NULL 
     GROUP BY OverTime 
     ORDER BY COUNT(*) DESC)
);


 /*Replace NULL HireDate With Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 UPDATE Employee
SET HireDate = COALESCE(HireDate, 
    (SELECT TOP 1 HireDate 
     FROM Employee 
     WHERE HireDate IS NOT NULL 
     GROUP BY HireDate 
     ORDER BY COUNT(*) DESC)
);

--Remove Extra Space FROM Columns IN Employee TABLE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
UPDATE Employee
SET 
	EmployeeID = LTRIM(RTRIM(EmployeeID)),
	FirstName = LTRIM(RTRIM(FirstName)),
    LastName = LTRIM(RTRIM(LastName)),
    GENDer = LTRIM(RTRIM(GENDer)),
    Department = LTRIM(RTRIM(Department)),
    State = LTRIM(RTRIM(State)),
    EducatiON = LTRIM(RTRIM(EducatiON)),
    Ethnicity = LTRIM(RTRIM(Ethnicity)),
    JobRole = LTRIM(RTRIM(JobRole)),
    MaritalStatus = LTRIM(RTRIM(MaritalStatus));


--Handle Wrong Age And ADD CHECK CONSTRAINT That Age IS BETWEEN 18 AND 65>>>>>>>>>>>>>>>>>>>>>>
DELETE FROM Employee
WHERE  Age < 18
OR Age > 65

ALTER TABLE Employee
ADD CONSTRAINT Age_CHECK CHECK (Age <= 65)


--Handle Wrong EducationField>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
UPDATE Employee
set EducationField = 'Marketing'
where EducationField = 'Marketing '


--Categorize Ages INto Ranges >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ALTER TABLE Employee
ADD AgeRange VARCHAR(20)

UPDATE Employee
SET AgeRange = CASE 
	WHEN Age >= 18 AND Age < 30 THEN '18-30'
    WHEN Age >= 30 AND Age < 40 THEN '30-40'
	WHEN Age >= 40 AND Age <= 50 THEN '40-50'
ELSE ' > 50'
END ;


SELECT Age, AgeRange
FROM Employee


--Categorize Distance INto Ranges >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ALTER TABLE Employee
ADD DistanceRange VARCHAR(20)

UPDATE Employee
SET DistanceRange = CASE 
	WHEN DistanceFromHome_KM BETWEEN 1 AND 10 THEN '1-10 km'
	WHEN DistanceFromHome_KM BETWEEN 11 AND 20 THEN '11-20 km'
	WHEN DistanceFromHome_KM BETWEEN 21 AND 30 THEN '21-30 km'
	WHEN DistanceFromHome_KM BETWEEN 31 AND 45 THEN '31-45 km'
ELSE 'Above 45'
END 


SELECT DistanceFromHome_KM,DistanceRange
FROM Employee



--Correct States Names>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
UPDATE Employee
SET State = CASE 
	WHEN State = 'CA' THEN 'California'
	WHEN State = 'IL' THEN 'Illinois'
	WHEN State = 'NY' THEN 'New York'
ELSE State
END

SELECT State from Employee


--Handle Gender Values>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
UPDATE Employee
SET GENDer = 'Other'
WHERE GENDer = 'NON-BINary'
OR GENDer = 'Prefer Not To Say'

-- Add a constraint to enforce gender values>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ALTER TABLE Employee
ADD CONSTRAINT Check_Gender CHECK (Gender IN ('Male', 'Female', 'Other'));



--Group JobRole By Department
SELECT  Department, JobRole
FROM Employee
GROUP BY Department, JobRole 


--How  many Invaid Entry in Technology Department
SELECT count(EmployeeID), EmployeeID
FROM Employee
WHERE Department = 'Technology' and JobRole = 'Sales Executive' 
GROUP BY EmployeeID



--Hanadle invalid JobRole >>>> Sales Executive must be in Sals Department Not Technology
Update Employee
SET Department = 'Sales'
WHERE Department = 'Technology' and JobRole= 'Sales Executive'



--Check Delete invalid entry
SELECT *
FROM Employee
WHERE Department = 'Technology' and JobRole= 'Sales Executive'


/*Remove Duplicates FROM EducatiONLevel TABLE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
DELETE FROM EducatiONLevel
WHERE EducatiONLevelID IN (
	SELECT EducatiONLevelID 
	FROM EducatiONLevel 
	GROUP BY EducatiONLevelID
	HAVING(COUNT(*)>1))

/*Remove Duplicates FROM SatISfiedLevel TABLE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
DELETE FROM SatISfiedLevel
WHERE SatISfactiONID IN (
	SELECT SatISfactiONID 
	FROM SatISfiedLevel 
	GROUP BY SatISfactiONID
	HAVING(COUNT(*)>1))


/*Remove Duplicates FROM RatINgLevel TABLE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
DELETE FROM RatINgLevel
WHERE RatINgID IN (
	SELECT RatINgID 
	FROM RatINgLevel 
	GROUP BY RatINgID
	HAVING(COUNT(*)>1))



