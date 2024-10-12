-- * DATA PREPARATION *

-- creating database
CREATE DATABASE projects_hr;

USE projects_hr;

SELECT * FROM hr;


-- * DATA CLEANING *

-- renaming the ID column 
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr;


-- checking for duplicates
SELECT emp_id, count(*)
FROM hr
GROUP BY emp_id
HAVING count(*) > 1;


-- checking the gender column
SELECT DISTINCT(gender)
FROM hr;

-- Checking the race column
SELECT DISTINCT(race)
FROM hr;

-- checking for empty values in gender and race column
SELECT *
FROM hr
WHERE race IS NULL
 OR gender IS NULL;


-- chamging birth date data type
SELECT birthdate FROM hr;

UPDATE hr
SET birthdate = CASE
  WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'),'%Y-%m-%d')
  WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'),'%Y-%m-%d')
  ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;


-- chamging hire date data type
UPDATE hr
SET hire_date = CASE
  WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'),'%Y-%m-%d')
  WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'),'%Y-%m-%d')
  ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;


-- chamging term date data type
UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

SELECT termdate FROM hr;

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SET sql_mode = 'ALLOW_INVALID_DATES';

SELECT termdate FROM hr;

ALTER TABLE hr
MODIFY COLUMN termdate DATE;


-- adding a new column age
ALTER TABLE hr ADD COLUMN age INT;

SELECT * FROM hr;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT birthdate, age FROM hr;

-- checking minimum and maximum ages of employees
SELECT 
min(age) as youngest,
max(age) as oldest
FROM hr;


-- subtracting 100 years from birth dates which are greater than the current date
UPDATE hr
SET birthdate = DATE_SUB(birthdate, INTERVAL 100 YEAR)
WHERE birthdate >= '2060-01-01' AND birthdate < '2070-01-01';



-- * DATA ANALYSIS *

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, count(*) AS count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY gender;


-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, count(*) AS count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY race
ORDER BY count(*) DESC;


-- 3. What is the age distribution of employees in the company?

SELECT
  CASE
    WHEN age >= 22 AND age <=29 THEN '22-29'
    WHEN age >= 30 AND age <=39 THEN '30-39'
    WHEN age >= 40 AND age <=49 THEN '40-49'
    WHEN age >= 50 AND age <=59 THEN '50-59'
    ELSE '60+'
  END AS age_group, gender,
  count(*) AS count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender;


-- 4. How many employees work at the headquaters versus remote locations?
SELECT location, count(*) AS count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY location;


-- 5. What is the average length of employment of employes who have been terminated?
SELECT
  round(avg(datediff(termdate, hire_date))/365,0) AS avg_length_employment
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00';  


-- 6. How does the gender distribution vary across departments?
SELECT department, gender, count(*) AS count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY department, gender
ORDER BY department;


-- 7. What is the distribution of job titles across the company? 
SELECT jobtitle, count(*) AS count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;


-- 8.What is the turnover rate across departments?
SELECT department,
  total_count,
  terminated_count,
  concat(round(terminated_count/total_count*100,0),'%') AS termination_rate
FROM ( 
  SELECT department,
  count(*) AS total_count,
  sum(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
  FROM hr
  GROUP BY department
  ) AS subquery
ORDER BY termination_rate DESC;  


-- 9. What is the turnover rate across jobtitle?
SELECT jobtitle,
  total_count,
  terminated_count,
  concat(round(terminated_count/total_count*100,0),'%') AS termination_rate
FROM ( 
  SELECT jobtitle,
  count(*) AS total_count,
  sum(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
  FROM hr
  GROUP BY jobtitle
  ) AS subquery
ORDER BY termination_rate DESC;


-- 10. What is the distribution of employees across locations by state?
SELECT location_state, count(*) AS count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY location_state
ORDER BY count DESC;


-- 11. How have turnover rates changed each year?
SELECT 
    year,
    hires,
    terminations,
    round((terminations / hires) * 100, 2) AS turnover_rate_percent
FROM (
    SELECT 
        year(hire_date) AS year,
        COUNT(*) AS hires,
        SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM hr
    GROUP BY year(hire_date)
) AS subquery
ORDER BY year ASC;


-- 12. What is the tenure distribution for each department?
SELECT department, round(avg(datediff(termdate, hire_date))/365,0) AS avg_tenure
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00'
GROUP BY department;


-- 13. What is the gender turnover rate across departments?
SELECT department, gender,
  total_count,
  terminated_count,
  concat(round(terminated_count/total_count*100,0),'%') AS termination_rate
FROM ( 
  SELECT department, gender,
  count(*) AS total_count,
  sum(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
  FROM hr
  GROUP BY department, gender
  ) AS subquery
ORDER BY department; 




