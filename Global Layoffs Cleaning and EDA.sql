# DATA CLEANING
Use world_layoffs;
Select*
From layoffs;

-- 1. Remove Duplicates
-- 2. Standardize data
-- 3. Null/Blank values
-- 4. Remove Columns

-- 1. Identifying duplicates

Create TABLE layoffs_copy like layoffs;
Insert into layoffs_copy
Select* from layoffs;

WITH CTE_layoffs as (
Select company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, count(*) as row_num
from layoffs_copy
group by company, location,  industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
)

Select*
from CTE_layoffs 
where count > 1;

-- 1.1 Removing Duplicates
CREATE TABLE `layoffs_copy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_copy2
Select company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, count(*) as row_num
from layoffs_copy
group by company, location,  industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions;

SET SQL_SAFE_UPDATES = 0;

Delete
from layoffs_copy2
WHERE row_num > 1;

Select*
from layoffs_copy2
where row_num = 1;

-- 2. Standardization of the Data
Update layoffs_copy2
SET company =  TRIM(company);

Select*
from layoffs_copy2;

Select industry
from layoffs_copy2
group by industry
order by 1;

Select industry
from layoffs_copy2
where industry like '%crypto%';

Update layoffs_copy2
SET industry = 'Crypto'
where industry like '%crypto%';

Update layoffs_copy2
SET country = trim(trailing '.' from country);

Select `date` ,
str_to_date (`date`, ('%m/%d/%Y'))
from layoffs_copy2;

Update layoffs_copy2
SET `date`= str_to_date (`date`, ('%m/%d/%Y'));

-- 3. Null/blank values

SELECT * FROM world_layoffs.layoffs_copy2
where industry is null OR 
industry = '' ;

Update world_layoffs.layoffs_copy2
SET industry = 'Travel'
where company = 'Airbnb';

Select* 
from layoffs_copy2
where company IN ('Juul','Carvana','Bally''s Interactive');

Update world_layoffs.layoffs_copy2
SET industry = 'Transportation'
where company = 'Carvana';

Update world_layoffs.layoffs_copy2
SET industry = 'Consumer'
where company = 'Juul';


-- 4. Deleting data for companies with no lay_offs

Select*
from layoffs_copy2
where total_laid_off is Null 
AND percentage_laid_off is NUll;

Delete 
from layoffs_copy2
where total_laid_off is Null 
AND percentage_laid_off is NUll;

Alter table layoffs_copy2
drop row_num;

Select*
from layoffs_copy2


#Exploratory Data Analysis
-- 1.layoffs in Pak

Select*
from layoffs_copy2
where country = 'Pakistan';

-- 2. Most layoffs by a company in a day
Select company, max(total_laid_off), max(percentage_laid_off)
from layoffs_copy2
group by company
order by 2 desc;

-- 2.1 total layoffs by every company
Select company, sum(total_laid_off)
from layoffs_copy2
group by company
order by 2 desc;

-- 3. count of companies that went under completely and the funding they were receiving
select max(percentage_laid_off), count(percentage_laid_off)
from layoffs_copy2
group by percentage_laid_off 
order by percentage_laid_off desc;

select*
from layoffs_copy2
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- 4. years this data covers + the years that were hit the worst
SELECT 
    MAX(YEAR(`date`)) AS max_year, 
    MIN(YEAR(`date`)) AS min_year
FROM 
    layoffs_copy2;
    
Select YEAR(`date`), sum(total_laid_off) as total_laid_off
from layoffs_copy2
group by YEAR(`date`)
order by total_laid_off desc;
-- 5. Industry that got hit the most

Select industry, sum(total_laid_off)
from layoffs_copy2
group by industry
order by 2 desc;

-- 6. Country that got hit the most

Select country, sum(total_laid_off)
from layoffs_copy2
group by country
order by 2 desc;

-- 7. Rolling total by month
Select substring(`date`,1,7) as month, sum(total_laid_off) as total_off
from layoffs_copy2
where substring(`date`,1,7) is not null
group by month
order by month asc;

with rolling_total as (Select substring(`date`,1,7) as month, sum(total_laid_off) as total_off
from layoffs_copy2
where substring(`date`,1,7) is not null
group by month)


select month, total_off, sum(total_off) over (order by month) as rolling_total_count
from rolling_total