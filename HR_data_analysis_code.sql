USE HR_data;

-- List all the columns
SELECT name
FROM sys.columns
WHERE object_id = OBJECT_ID('dbo.HR_data')

-- View the top 10 rows to see that the dataset has loaded properly.
SELECT TOP 10*
FROM dbo.HR_data;

-- 3310 Check how many employees (including the soon to be starting, retrired and fired ones) the company has.
SELECT COUNT(*)
FROM dbo.HR_data;

SELECT COUNT(*)
FROM dbo.HR_data;


/*
I will determine a good employee basing it on:
- the length of they work in the company
- their performance score
*/

-- Declare current year variable (YY)
DECLARE @CurrentYear INT = 20;
/* I want to know how long each employee has been working in this company.
I can do this by subtracting the current year from the year extracted from 
the date of hire. This will work, since we know that first hires started in 2006.
*/
SELECT EmpID, DateOfHire, SUBSTRING(DateOfHire, 7, 2), @CurrentYear - SUBSTRING(DateOfHire, 7, 2) AS YearInPosition
FROM DBO.HR_data
ORDER BY  SUBSTRING(DateOfHire, 7, 2);

/* I want to add a new column for that value.
ALTER TABLE dbo.HR_data
ADD YearsInCompany INT;
*/

-- Set values for the new column with the calculated values. This should be updated on an annual basis.
UPDATE dbo.HR_data
SET YearsInCompany = @CurrentYear - SUBSTRING(DateOfHire, 7, 2);

-- Now I want to find out which employees worked in a company for 10 or more years.
SELECT EmpID, YearsInCompany
FROM dbo.HR_data
WHERE YearsInCompany >= 10
ORDER BY YearsInCompany DESC;

-- I want to know the performance score for these employees.
SELECT COUNT(YearsIncompany), PerformanceScore
FROM dbo.HR_data
WHERE YearsInCompany >= 10
GROUP BY PerformanceScore;


-- I am only interested in the employees who are either exceeding or fully meeting the expectations.
SELECT COUNT(YearsInCompany), PerformanceScore
FROM dbo.HR_data
WHERE YearsInCompany >= 10 AND PerformanceScore IN ('Exceeds', 'Fully Meets')
GROUP BY PerformanceScore;

/*
Finally I want to know
- through which recruitment source have they been employed
- what gender are their
- whether they are the US citizen
- whether they are hispanic or not
*/
SELECT COUNT(Sex), Sex, CitizenDesc, HispanicLatino
FROM dbo.HR_data
WHERE YearsInCompany >= 10 AND PerformanceScore IN ('Exceeds')
GROUP BY Sex, CitizenDesc, HispanicLatino
ORDER BY COUNT(Sex) DESC;

SELECT COUNT(Sex), Sex, CitizenDesc, HispanicLatino
FROM dbo.HR_data
WHERE YearsInCompany >= 10 AND PerformanceScore IN ('Fully Meets')
GROUP BY Sex, CitizenDesc, HispanicLatino
ORDER BY COUNT(Sex) DESC;
/*
Among employees employed for over 10 years and exceeding expectations there are:
- 15 female US citizens of non-Hispanic origins
- 11 female US citizens of Hispanic origins
- 7 male US citizens of non-Hispanic origins
  
Among employees employed for over 10 years and meeting the expectations there are:
- 84 female and 65 male US citizens of non-Hispanic origins
- 15 female and 9 male US citizens of Hispanic origins
- 4 female and 1 male eligible non-citizens of non-Hispanic origins
- 1 female non-US citizen of non-Hispanic roots
*/

-- I would like to know which recruitment source brings in the most of employee.
SELECT COUNT(RecruitmentSource), RecruitmentSource
FROM dbo.HR_data
WHERE YearsInCompany >= 10 AND PerformanceScore IN ('Exceeds', 'Fully Meets')
GROUP BY RecruitmentSource
ORDER BY COUNT(RecruitmentSource) DESC;

-- 1. Query for Tableau- to showcase which recruitment source brings in the most of employee.
SELECT * 
FROM dbo.HR_data
WHERE YearsInCompany >= 10 AND PerformanceScore IN ('Exceeds', 'Fully Meets');

/*
Now I will look at people who quit and at what were their reasons.
TermReason
DeptID
Department
Position
EngagementSurvey
EmpSatisfaction
*/

-- Find what types of termination reasons are there.
SELECT DISTINCT TermReason
FROM dbo.HR_data;

/*
There are couple of them that the company could take up on some actions to prevent employees leaving
the company from those reasons. They are the following:
- medical issues, 
- more money, 
- maternity leave-did not return
- unhappy
*/
SELECT COUNT(TermReason) AS Nb, TermReason
FROM dbo.HR_data
WHERE TermReason IN ('medical issues', 'more money', 'maternity leave - did not return', 'unhappy')
GROUP BY TermReason
ORDER BY Nb DESC;


/*
I want to learn how to recognise what are the traits of employees who are most likely to quit their job.
I will be looking at:
- Position
- Department
- PerformanceScore
- EmpSatisfaction
- YearsInCompany
*/

-- Check how many people quitted.
SELECT COUNT(EmploymentStatus)
FROM dbo.HR_data
WHERE EmploymentStatus = 'Voluntarily Terminated';
-- 797 out of all employees 3310

-- Let's see what is the relation in between employees satisfaction and the quitting rate.
SELECT COUNT(EmpSatisfaction), EmpSatisfaction
FROM dbo.HR_data
WHERE EmploymentStatus = 'Voluntarily Terminated'
GROUP BY EmpSatisfaction
ORDER BY EmpSatisfaction DESC;

SELECT COUNT(PerformanceScore), PerformanceScore
FROM dbo.HR_data
WHERE EmploymentStatus = 'Voluntarily Terminated'
GROUP BY PerformanceScore
ORDER BY COUNT(PerformanceScore) DESC;

SELECT COUNT(YearsInCompany), YearsInCompany
FROM dbo.HR_data
WHERE EmploymentStatus = 'Voluntarily Terminated'
GROUP BY YearsInCompany
ORDER BY YearsInCompany DESC;

SELECT COUNT(Department), Department, Position
FROM dbo.HR_data
WHERE EmploymentStatus = 'Voluntarily Terminated'
GROUP BY Department, Position
ORDER BY COUNT(Department) DESC;


-- 2. Query for Tableau- to showcase which employees has quitted the company.
SELECT *
FROM dbo.HR_data
WHERE EmploymentStatus = 'Voluntarily Terminated';

/*
The HispanicLatino column contains values such as: Yes, yes, No, no.
As long as it doesn't matter for the sql calculations, which treats those values the same no matter
whether the value starts with a capital letter or not, they matter when creating visualisations in Tableau. 
I will correct that so that the values are unified and all are starting with a capital letter.
*/

-- Find cells in the HispanicLatino column in which the value start with a lower letter case
SELECT EmpID, HispanicLatino
FROM dbo.HR_data
WHERE HispanicLatino = 'yes' 
COLLATE Latin1_General_CS_AS;

SELECT EmpID, HispanicLatino
FROM dbo.HR_data
WHERE HispanicLatino = 'no' 
COLLATE Latin1_General_CS_AS;

/*
-- Update the yes values to Yes
UPDATE dbo.HR_data
SET HispanicLatino = 'Yes'
WHERE HispanicLatino = 'yes'
COLLATE Latin1_General_CS_AS;
*/

/*
-- Update the no values to No
UPDATE dbo.HR_data
SET HispanicLatino = 'No'
WHERE HispanicLatino = 'no'
COLLATE Latin1_General_CS_AS;
*/

/*
====================================
TABLEAU QUERIES
====================================
*/

-- 1. How many men/women, latino/non-latino employees does the company currently have?
SELECT COUNT(EmpID) AS 'Nb Of Employees', Sex, HispanicLatino 
FROM dbo.HR_data
WHERE TermReason LIKE '%still employed'
GROUP BY Sex, HispanicLatino
ORDER BY COUNT(EmpID) DESC;

-- 2. How many women/men are in each performance category: PIP, Needs Improvement, Fully Meets, Exceeds?
SELECT COUNT(Sex) AS 'Nb Of Employees', Sex, PerformanceScore
FROM dbo.HR_data
GROUP BY PerformanceScore, Sex
ORDER BY PerformanceScore DESC;

-- 3. How many people have been recruited through each of the recruitment source ever?
SELECT COUNT(EmpID) AS 'Nb Of Employees', RecruitmentSource
FROM dbo.HR_data
GROUP BY RecruitmentSource
ORDER BY COUNT(EmpID) DESC;

-- 4. How many people leave the company depending on how long they have been employeed for?
SELECT COUNT(YearsInCompany) AS 'Nb Of Employees', YearsInCompany  
FROM dbo.HR_data
WHERE EmploymentStatus = 'Voluntarily Terminated'
GROUP BY YearsInCompany
ORDER BY YearsInCompany;

-- 5. How many people leave each department each year?
SELECT COUNT(EmpID) AS 'Nb Of Employees', Department, SUBSTRING(DateofTermination, 7, 2)
FROM dbo.HR_data
WHERE EmploymentStatus = 'Voluntarily Terminated'
GROUP BY Department, SUBSTRING(DateofTermination, 7, 2)
ORDER BY SUBSTRING(DateofTermination, 7, 2);



