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

  SELECT CAST(posted-at] AS DATE) FROM JOBS_DATA;