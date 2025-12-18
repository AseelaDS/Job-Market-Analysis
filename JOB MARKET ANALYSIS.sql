--DQL Statements --

--Select Database
USE JOB;

--##DQL STATEMENTS##--

--1.How many records does this table contain?
SELECT COUNT(*) AS "NO OF RECORDS" FROM JOBS_DATA;

--2. Does the data has duplicates?
--CHECK DATA 
SELECT * FROM JOBS_DATA;

SELECT COUNT(*)AS "Total Records", COUNT(DISTINCT(job_id)) AS "NO Of Unique records" 
FROM JOBS_DATA;

--3. List the top 5 companies and the no of exact job postings?

SELECT company_name, COUNT(*)
FROM JOBS_DATA
GROUP BY company_name,[description]
HAVING COUNT(*)>1
;
 --List 6 field(column names) and describtion token for five random rows

 --SELECT TOP 6 COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
 --WHERE TABLE_NAME= 'JOBS_DATA';

-- SELECT * FROM INFORMATION_SCHEMA.COLUMNS
 --WHERE TABLE_NAME= 'JOBS_DATA';

 SELECT TOP 5 [index],title,company_name,[location],via,[description],description_tokens
 FROM JOBS_DATA
 ORDER BY NEWID();

 /*--5. Average standardised salary by schedule type and remote status 
 what is the average salary _standardized for jobs, broken down by schedule_type and whether they are work from home or not 
 Include only full time and contract jobs for this analysis	*/
 SELECT *
 FROM JOBS_DATA;
 SELECT DISTINCT(Schedule_type)
 FROM JOBS_DATA;
 SELECT DISTINCT(work_from_home)
 FROM JOBS_DATA;
 
 SELECT schedule_type,CASE
                         WHEN work_from_home='1'THEN 'REMOTE'
						 ELSE 'ON SITE'
						 END AS Work_Location,
						 ROUND(Avg(salary_standardized),0) AS Average_Standardized_Salary
 FROM JOBS_DATA
 WHERE schedule_type IN ('Full-time','Contract')
 GROUP BY schedule_type,work_from_home;

 /*--6. Top two job posting sources by total standardized salary offered 
 Which three job posting sources 
 (via)collectively represent the highest sum of average standardized salaries(salary_standardized)*/
 
  SELECT * FROM JOBS_DATA;
  SELECT DISTINCT (VIA) FROM JOBS_DATA;

  SELECT TOP 2 via, ROUND(SUM(salary_standardized),0) AS Total_Standardized_Salary
  FROM JOBS_DATA 
  GROUP BY VIA
  ORDER BY 2 DESC;

  /*--7.Job Titles with the highest proportion of the remote oportunities 
  List the  Top 5 job opportunities that have the highest proportion of the work_ from_ home positions among all their
  Job postings. Consider only titles with atleast 3 total postings*/

  SELECT DISTINCT(title)
  FROM JOBS_DATA;

  SELECT TOP 5 title,
               CAST(SUM(CASE WHEN work_from_home= 1 THEN 1 ELSE 0 END)/COUNT(*) AS FLOAT ) AS Remote_Work
  FROM JOBS_DATA
  GROUP BY title
  HAVING  COUNT(*)>1
  ORDER BY 2 DESC;

  /*--8 Overall average Standardized salary for hourly Vs yearly rate
  Compare the overall average standardized salary(salary_standardized) 
  for jobs listed as 'hourly'(salary rate = 'hour' ) versus 'yearly' (salary rate = 'year' )*/

  SELECT DISTINCT(salary_rate)FROM JOBS_DATA;
  SELECT * FROM JOBS_DATA;

  SELECT salary_rate,ROUND(AVG(salary_standardized),0) AS Average_standardized_salary
  FROM JOBS_DATA
  GROUP BY salary_rate
  ORDER BY 2 DESC;
  /*--9. Locations with a high concentration of Specific tech jobs
  Identifying locations (excluding 'remote')that contains 'developer' And 'frontend'or 'backend' in their describtion_tokens
  Count how many such jobs each identfied location has*/

  SELECT TOP 50 * FROM JOBS_DATA;

  SELECT location, COUNT(*) As 'Count'
  FROM JOBS_DATA
  WHERE work_from_home <> 1
  AND description_tokens LIKE '%developer%'
  AND (description_tokens LIKE '%frontend%' OR description_tokens LIKE '%backend%')
  GROUP BY [location];

  /*--Salary comparison for the recently posted jobs in the last 7 days(relative to the date time column, assuming date time represents 'now'
  for the data point)versus jobs posted earlier.*/

  SELECT TOP 20 * FROM JOBS_DATA;


 
  SELECT MAX(CAST(posted_at AS DATE)) FROM JOBS_DATA;

 /* SELECT CASE
          WHEN posted_at>= DATEADD(Day,-7,'2025-07-25')THEN 'Posted last 7 days'
	      ELSE 'posted_earlier'
		  END AS Posted_Period, ROUND(AVG(salary_standardized),0) Average_salary
 FROM JOBS_DATA
 GROUP BY CASE
        WHEN posted_at >= DATEADD(DAY, -7, '2025-07-25')
        THEN 'Posted last 7 days'
        ELSE 'Posted earlier'
    END;*/

 SELECT CASE
        WHEN posted_at >= DATEADD(DAY, -7, '2025-07-25') THEN 'Posted last 7 days'
        ELSE 'Posted earlier'
    END AS Posted_Period,
    ROUND(AVG(salary_standardized), 0) AS Average_salary
FROM JOBS_DATA
GROUP BY 
    CASE
        WHEN posted_at >= DATEADD(DAY, -7, '2025-07-25') THEN 'Posted last 7 days'
        ELSE 'Posted earlier'
    END;

/*--11. Determine days since job posting 
show company_name, posted_at, date_time(the time stamp when the record was observed),and a new calculated column DaysSincePosting which represent how many days  have passed betwen the posted_at date and the date_time of te record */

SELECT TOP 5 *
FROM JOBS_DATA ;

SELECT company_name,posted_at, DATEDIFF(DAY,posted_at,GETDATE()) AS DaysSincePosting 
FROM JOBS_DATA
ORDER BY 3 DESC;

/*--12. Categorize salary ranges 
'High' if salary_standardized is greater than  120,000
'medium' if salary_standardized is between 75,000 & 120,000(inclusive)
'Low' if salary_standardized is less than 75,000
'unspecified' if salary_standardized is Null.*/

SELECT company_name,title,salary_standardized,
        CASE
		WHEN salary_standardized >  120000 THEN 'High'
		WHEN salary_standardized BETWEEN 75000 AND 120000 THEN 'medium'
		WHEN salary_standardized < 75000 THEN 'Low'
		ELSE 'unspecified'
		END AS Salary_Tier
FROM JOBS_DATA
ORDER BY 3 DESC;

/* --13. Identify Potential  AI/Data/ML roles
For each job , display its title, company_name, and a boolean-like calculated column IsDataAIMLRole		
that is '1' if "Data", 'AI', 'ML' is present in description_tokens(case_insentitive ), otherwise '0'*/

SELECT title, company_name, description_tokens,
CASE 
WHEN LOWER(description_tokens) LIKE '%data%' 
  OR LOWER(description_tokens) LIKE '%ai%' 
  OR LOWER(description_tokens) LIKE '%ml%' 
  OR LOWER(description_tokens) LIKE '%machine learning%' THEN 1
ELSE 0
END AS 'IsDataAIMLRole'	
FROM JOBS_DATA
ORDER BY 4 DESC;

/* Filter all IsDataAIMLRole having 'Data','AI','ML'*/

WITH CTE AS (
SELECT title, company_name, description_tokens,
CASE 
WHEN LOWER(description_tokens) LIKE '%data%' 
  OR LOWER(description_tokens) LIKE '%ai%' 
  OR LOWER(description_tokens) LIKE '%ml%' 
  OR LOWER(description_tokens) LIKE '%machine learning%' THEN 1
ELSE 0
END AS 'IsDataAIMLRole'	
FROM JOBS_DATA)
SELECT title, company_name, description_tokens,IsDataAIMLRole
FROM CTE 
WHERE IsDataAIMLRole=1;

SELECT * FROM JOBS_DATA;

/*--14. Standardized commute category & Estimated commute time in hours
   created 2 calculated columnns
   1.commute category : 'Short'(<=20 mins),'Medium'(>20 and <=45 mins), 'Long'(>45 mins), or 'NA' if comute time is not numeric
   2.CommuteTimeInHours: Converts the commute_time(assuming the time in 'X mins' format)to hours .  */

 /*  SELECT company_name,title,commute_time,TRY_CAST(REPLACE(commute_time, 'mins','') AS INT) AS Commute_Time_mins,
   CASE 
       WHEN TRY_CAST(REPLACE(commute_time, 'mins','') AS INT)<=20 THEN 'Short'
	   WHEN TRY_CAST(REPLACE(commute_time, 'mins','') AS INT) BETWEEN 21 AND 45 THEN 'Medium'
	   WHEN TRY_CAST(REPLACE(commute_time, 'mins','') AS INT)>45 THEN 'Long'
	   ELSE 'NA'
	   END AS Standardized_commute_category
   FROM JOBS_DATA;*/

WITH CTE AS
(
SELECT company_name,title,commute_time,
 TRY_CAST(REPLACE(commute_time, 'mins','') AS INT) AS Commute_Time_mins
 FROM JOBS_DATA
 )
SELECT company_name,title,commute_time,
CASE 
       WHEN Commute_Time_mins<=20 THEN 'Short'
	   WHEN Commute_Time_mins BETWEEN 21 AND 45 THEN 'Medium'
	   WHEN Commute_Time_mins>45 THEN 'Long'
	   ELSE 'NA'
	   END AS Standardized_commute_category,
CASE 
WHEN Commute_Time_mins IS NOT NULL THEN ROUND(TRY_CAST(Commute_Time_mins AS FLOAT) / 60,3)
ELSE NULL
END AS Commute_time_hrs
FROM CTE
ORDER BY 5;
   
/* 14. Analyze Average Salary and Remote Job Proportion for Top 5 Job Titles

For the 5 most frequently posted titles (excluding 'Remote' locations), 
calculate their average salary_standardized. Then, for each of these top 5 titles, 
determine the percentage of jobs that are work_from_home. 
Rank these top titles by their average standardized salary. */

 -- SELECT * FROM JOBS_DATA; --

/* -- SELECT Top 5 title
FROM  JOBS_DATA
WHERE [location] <> 'Remote'
GROUP BY title
ORDER BY COUNT(title) DESC;*/

WITH CTE AS
(SELECT Top 5 title
FROM  JOBS_DATA
WHERE [location] <> 'Remote'
GROUP BY title
ORDER BY COUNT(title) DESC)
SELECT J.title,AVG(salary_standardized) As Salary_standardized,
CAST(SUM(CASE
WHEN work_from_home=1 THEN 1 ELSE 0
END)AS FLOAT)*100/COUNT(J.title) AS Percentage_of_Work_from_home, 
RANK()OVER(ORDER BY AVG(J.Salary_standardized) DESC) AS RANK
FROM CTE C
INNER JOIN
JOBS_DATA J 
ON C.title=j.title
GROUP BY C.title
;

