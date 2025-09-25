-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022


SELECT * 
FROM 
	world_layoffs.layoffs;


--first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
CREATE TABLE
	world_layoffs.layoffs_staging 
LIKE
	world_layoffs.layoffs;

INSERT
	layoffs_staging 
SELECT *
	FROM world_layoffs.layoffs;

-- Now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways



-- 1. Remove Duplicates
-- First let's check for duplicates

SELECT *
FROM
	world_layoffs.layoffs_staging;

SELECT 
    company,
	industry, 
	total_laid_off,
	`date`,
	ROW_NUMBER() OVER (
	PARTITION BY company, industry, total_laid_off,`date`) AS row_num
FROM 
	world_layoffs.layoffs_staging;



SELECT *
	FROM(
	SELECT *,
		ROW_NUMBER()
		OVER(PARTITION BY
		company,
		location,
		industry,
		total_laid_off,
		`date`,
		stage,
		country,
		funds_raised_millions) AS row_num
	FROM layoffs_staging
) duplicates
WHERE
row_num > 1;

-- let's just look at oda to confirm
SELECT *
FROM 
	world_layoffs.layoffs_staging
WHERE
	company = 'Oda';


CREATE TABLE `layoffs_staging2` (
	`company` text,
	`location` text,
	`industry` text,
	`total_laid_off` int DEFAULT NULL,
	`percentage_laid_off` text,
	`date` text,
	`stage` text,
	`country` text,
	`funds_raised_millions` int DEFAULT NULL,
	row_num Int
);

INSERT INTO
	layoffs_staging2
SELECT *,
	ROW_NUMBER()
	OVER(PARTITION BY
	company,
	location,
	industry,
	total_laid_off,
	`date`,
	stage,
	country,
	funds_raised_millions) AS row_num
FROM
layoffs_staging;


SELECT * 
FROM
	layoffs_staging2
WHERE
	row_num > 1;

-- now that we have this we can delete rows were row_num is greater than 2

DELETE FROM
	layoffs_staging2
WHERE
	row_num > 1;


-- 2- Standardize  Data.


SELECT * 
FROM
	world_layoffs.layoffs_staging2;

-- Remove the white space 
SELECT
	company, trim(company) 
FROM
	layoffs_staging2;

UPDATE
	layoffs_staging2 
SET
	company = trim(company);


-- The Crypto has multiple different variations. We need to standardize that - let's say all to Crypto
SELECT *
FROM
	layoffs_staging2
WHERE
	industry LIKE 'Crypto%';


UPDATE
	layoffs_staging2 
SET
	industry ='Crypto'
WHERE
	industry LIKE 'Crypto%';

-- Everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.

SELECT 
	distinct country 
FROM 
	layoffs_staging2
ORDER BY 1;


UPDATE
	layoffs_staging2 
SET 
	country ='United States'
WHERE 
	country LIKE 'United States%';

-- Fix the date columns:
SELECT
	`date`,
	str_to_date(`date`,'%m/%d/%Y') AS format_date
FROM 
	layoffs_staging2;


UPDATE
	layoffs_staging2
SET 
	`date` = str_to_date(`date`,'%m/%d/%Y');


SELECT
	`date`
FROM
	layoffs_staging2;

ALTER TABLE layoffs_staging2 
MODIFY COLUMN `date` DATE;

-- 3- Null values or Blanks values.

SELECT *
FROM 
	layoffs_staging2
WHERE 
	industry IS NULL OR industry = '';

-- Make blanks fields Null in industry column

UPDATE 
	layoffs_staging2 
SET 
	industry = NULL
WHERE 
	industry = '';

-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

-- we should set the blanks to nulls since those are typically easier to work with
SELECT
	t1.industry, t2.industry
FROM 
	layoffs_staging2 AS t1
JOIN 
	layoffs_staging2 AS t2
	ON t1.company = t2.company 
WHERE
	(t1.industry IS NULL OR t1.industry  = '')
	AND t2.industry IS NOT NULL;


UPDATE
	layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	on t1.company = t2.company
SET
	t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry  = '')
	AND  t2.industry IS NOT NULL;


SELECT *
FROM layoffs_staging2;



-- 4- Remove any columns or Rows

-- These Rows are not elective so, we can DELETE them
SELECT *
FROM 
	layoffs_staging2
WHERE
	total_laid_off IS NULL
    AND percentage_laid_off IS NULL;


DELETE FROM
	layoffs_staging2
WHERE 
	total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

-- Delete row_num column, We used it instead of PRIMARY KEY column  

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;