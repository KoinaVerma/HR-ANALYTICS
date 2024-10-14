# HR ANALYTICS



A company can enhance employee experience through **HR analytics**, which unlocks workforce potential. 

But what is HR analytics?  

It involves gathering data and key metrics on employees to gain insights that drive informed decisions on hiring and management.                                                                                                                                      
In this article, I explore HR analytics by analyzing workforce diversity and turnover rates using SQL.     

Let’s dive into the project.

### TABLE OF CONTENT

- [Project overview](#project-overview)
- [Data Source](#data-source)
- [Data Preparation](#data-preparation)
- [Data Cleaning](#data-cleaning)
- [Analysis](#analysis)
- [Insights](#insights)
- [Recommendations](#recommendations)

### PROJECT OVERVIEW

In this project, I represent a fictional company aiming to boost workplace diversity and improve employee retention. To reach these objectives, HR executives need insights into employees' demographics and turnover trends from recent years. Here are the key questions and metrics they’re focused on:

1. What is the gender breakdown of Employees in the company?
2. What is the ethnicity breakdown of Employees in the company?
3. What is the age distribution of Employees in the company?
4. How many employees work at headquarters versus remote locations?
5. What is the average length of employment of employees who have been terminated?
6. How does the gender distribution vary across departments?
7. What is the distribution of job titles across the company?
8. Which department has the highest turnover rate?
9. What is the Turnover rate across jobtitles?
10. What is the distribution of employees across locations by state?
11. How have turnover rates changed each year?
12. What is the tenure distribution for each department?
13. What is the Gender Turnover rate across departments ?
    
Understanding the above metrics helps executives make data-driven decisions. 

### DATA SOURCE

•	MySQL - Data Cleaning, Data Analysis

•	Power BI - Creating Reports

This report will show you my interpretations and queries for each question. I will also provide some insights and recommendations based on my analysis.

### DATA PREPARATION

I downloaded the dataset from Kaggle.com. The website has various fictitious datasets for data projects. I previewed the dataset in Excel Sheets to see the numbers of rows and columns. The dataset originally had 13 columns, 22214 rows, and consists of employees’ details from 2000 to 2020. I proceeded to import the data to MySQL by creating a database first, followed by creating a table for the data to get stored. 

I created a table named **“hr”** within the project database. To do this, I utilized the Table Data Import Wizard feature, where I imported data from the Excel file. During the process, I mapped the columns from the Excel file to the corresponding fields in the table and assigned appropriate data types, such as VARCHAR for text fields and INT for numeric fields. This method helped me efficiently structure the data for subsequent analysis.

### DATA CLEANING

After importing my data, I started the cleaning process. Cleaning is an essential step in data analysis, it improves the quality of data and makes it suitable for use. I summarized the process below:

Firstly, I **renamed** the ï»¿id column to emp_ID.

``` sql
-- renaming the ID column 
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;
```

I checked if there were any **duplicate** rows by using the ID column, as each employee should have a unique ID. No duplicates detected.

``` sql
SELECT emp_id, count(*)
FROM hr
GROUP BY emp_id
HAVING count(*) > 1;
```

Then I checked the race and gender columns for **nulls** and **unique** values. No empty row was found and all values were properly inputted.

``` sql
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
```

Then, I changed the **date format** and **data types** of some columns using the queries below:

#### Birthdate

``` sql
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
```

#### Hiredate

``` sql
-- chamging hire date data type
UPDATE hr
SET hire_date = CASE
  WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'),'%Y-%m-%d')
  WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'),'%Y-%m-%d')
  ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;
```

#### Termdate

``` sql
-- chamging term date data type
UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

SELECT termdate FROM hr;

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

ALTER TABLE hr
MODIFY COLUMN termdate DATE;
```

I checked for empty values in all other columns. None was found except in the “term_date” column which means the employee is still in the company. To answer the question on age distribution, I created a new column **“age”** by subtracting the birth date from the current date.

``` sql
-- adding a new column age
ALTER TABLE hr ADD COLUMN age INT;

SELECT * FROM hr;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());
```

I checked for the **minimum** and **maximum** ages of employees. And found that some values were negative with birth dates greater than today’s date for eg. 2060, so I assumed that there might have been an error in the dataset, where, instead of 1960 the birth year was written as 2060. 

``` sql
-- checking minimum and maximum ages of employees
SELECT 
min(age) as youngest,
max(age) as oldest
FROM hr;
```

So, to address this issue I **subtracted 100 years** from such values:

``` sql
-- subtracting 100 years from birth dates which are greater than the current date
UPDATE hr
SET birthdate = DATE_SUB(birthdate, INTERVAL 100 YEAR)
WHERE birthdate >= '2060-01-01' AND birthdate < '2070-01-01';
```

I will be working with **22214 rows** and **14 columns** throughout my analysis.


### ANALYSIS

Now that I have the data ready, I can start writing queries to answer the questions and metrics that the HR executives are interested in.

#### Gender and Race Distribution

I calculated gender and race distribution by using the **GROUP BY** statement and **Count()** function to get the count of employees in each category.

``` sql
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
```

#### Age Distribution

I checked the minimum and maximum ages which are 22 and 58 respectively. Then, I used the **CASE expression** to create age groups and counted the employees in each group.

``` sql
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
```

#### Work Location

I used the **GROUP BY** statement to calculate the number of employees working remotely or in the headquarters.

``` sql
-- 4. How many employees work at the headquaters versus remote locations?
SELECT location, count(*) AS count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY location;
```

#### Average Employee Tenure

This is the average length of time an employee has worked for the company. I calculated the average tenure for all employees who have been terminated by finding the difference between termination and hire year.

``` sql
-- 5. What is the average length of employment of employes who have been terminated?
SELECT
  round(avg(datediff(termdate, hire_date))/365,0) AS avg_length_employment
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00';
```

#### Gender distribution across departments

I calculated the number of employees in each department by gender.

``` sql
-- 6. How does the gender distribution vary across departments?
SELECT department, gender, count(*) AS count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY department, gender
ORDER BY department;
```

#### Job titles across the company

Here, I calculated the number of employees across job titles regardless of gender and limited it to the top 10.

``` sql
-- 7. What is the distribution of job titles across the company? 
SELECT jobtitle, count(*) AS count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;
```

#### Turnover rate in each Department

Employee Turnover rate is the percentage of employees who have left the company over a certain period. I calculated the turnover rate for each department by dividing the number of terminated employees by the total number of employees. And then sorted the departments in descending order of turnover rate to identify the department with the highest turnover.

``` sql
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
```
	
#### Turnover rate per Job title

I calculated the turnover rate per title using queries similar to the above.

``` sql
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
```

#### Employee distribution by state

I calculated the number of employees in each state.

``` sql
-- 10. What is the distribution of employees across locations by state?
SELECT location_state, count(*) AS count
FROM hr
WHERE termdate = '0000-00-00'
GROUP BY location_state
ORDER BY count DESC;
```

#### Turnover rates per year

I calculated the turnover rate per year using the queries below:

``` sql
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
```

#### Average Tenure for each department 

I calculated the average tenure of employees as per each department in the company.

``` sql
-- 12. What is the tenure distribution for each department?
SELECT department, round(avg(datediff(termdate, hire_date))/365,0) AS avg_tenure
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00'
GROUP BY department;
```

#### Gender Turnover rate across departments

I calculated the turnover rate of each gender for all the departments.	

``` sql
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
```

### INSIGHTS

I imported my data to **Power BI** for ease of communication. I grouped my findings under Employee Diversity and Turnover rate.

#### Employee Diversity

- The total number of **Employees hired** from 2000 to 2020 is 18,285, out of which 13,710 work from the **headquarters**. This means that 25% of employees work **remotely**.

- 51.01% of people hired are **Male**, 46.24% **female**, and 2.75% non-conforming. The company has more employees between the ages of **30 to 49**.

- 14,788 employees (80.87%) live in **Ohio** while **Wisconsin** has the least employees. This correlates with the above insight since the headquarters is located in Ohio.

- 5,214 of the employees hired are **White** and this is the race with the highest employees.

- The **Engineering department** has the most employees. The company hired more **Research Assistant II** followed by **Business Analyst** and **Human Resources Analyst II**.


<img width="576" alt="Employee Diversity Report " src="https://github.com/user-attachments/assets/76fd4fcf-08a8-49c5-b146-72a3922a6bb9">


#### Employee Turnover

- The number of Employees that have **left** the company between 2020 and now is 3,929. The **turnover rate** is 12%, which means that 12% of all employees hired have left the company.

- The **average length of employment** of an employee in the company is **8** years.

- The year **2001** had the highest turnover rate with 18.09% while **2020** had the lowest turnover rate with 3.66% of employees hired leaving the company.

- The department and position with the highest turnover rate are **Auditing** and **Executive Secretary, Statistician III and Statistician IV** respectively. **17%** of the employees hired in the Auditing department and **50%** of the three positions left the department.

- **Non-conforming** employees have the highest turnover rate in **Research and Development** (20%), while **female** employees face notable turnover in **Legal** (15%) and Training (14%). **Male** turnover is relatively balanced across departments but peaks in **Auditing** (25%), indicating significant retention challenges in this department for male employees.


<img width="577" alt="Employee Turnover Dashboard" src="https://github.com/user-attachments/assets/0b185810-afdc-4819-bfe2-31466ecb9675">


### RECOMMENDATIONS

Here are a few recommendations that will help the company to increase employee diversity and reduce the turnover rates

1.	Gender inclusiveness should be embraced especially for the non-conforming. Also, hire more people from the age of 20 to 29.
   
2.	Create an enabling environment for employees to work remotely, hence employing more people living outside of Ohio. Ask questions like can fewer employees work from the headquarters? Employees can also be allowed to work hybrid.
  
3.	The turnover rate has reduced over the years and this is impressive but there are positions with over 20% turnover rate. The company should have discussions with employees in those positions, conduct surveys to understand the factors influencing turnovers, and take actions.

### Note:
   
In the analysis, the job title **"Office Assistant II"** was excluded from the visualization of the top 10 highest turnover rates. This position had a 100% turnover rate, as it was held by a single employee who left the company. To maintain the accuracy and relevance of the analysis, I focused on job titles with multiple employees, ensuring the results reflect meaningful trends rather than isolated cases.

