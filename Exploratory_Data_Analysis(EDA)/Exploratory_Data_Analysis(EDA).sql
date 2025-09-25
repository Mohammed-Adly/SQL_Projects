-- Exploratory Data Analysis (EDA) --


-- 1. What is the maximum total laid off and the maximum percentage laid off?
SELECT 
    MAX(total_laid_off) AS max_total,
    MAX(percentage_laid_off) AS max_percentage
FROM
    layoffs_staging;

-- Output:
-- max_total | max_percentage
-- 12000     | 1

-- 2. How many companies had 100% layoffs?
SELECT
    COUNT(company) AS total_companies
FROM
    layoffs_staging
WHERE
    percentage_laid_off = 1;

-- Output:
-- total_companies
-- 116

-- 3. How many companies had 100% layoffs in 2023?
SELECT COUNT(company) AS total_companies
FROM layoffs_staging
WHERE percentage_laid_off = 1
AND YEAR(`date`) = 2023;

-- Output:
-- total_companies
-- 14

-- 4. Top 5 companies with the highest total layoffs
SELECT
    company,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 5;

-- Output:
-- company     | total_laid_off
-- Amazon      | 18150
-- Google      | 12000
-- Meta        | 11000
-- Salesforce  | 10090
-- Microsoft   | 10000

-- 5. Start date and end date of layoffs data
SELECT
    MIN(`date`) AS start_date,
    MAX(`date`) AS end_date
FROM layoffs_staging;

-- Output:
-- start_date  | end_date
-- 2020-03-11  | 2023-03-06

-- 6. Top 10 industries with the highest total layoffs
SELECT
    industry,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY industry
ORDER BY total_laid_off DESC
LIMIT 10;

-- Output:
-- industry        | total_laid_off
-- Consumer       | 45182
-- Retail         | 43613
-- Other          | 36289
-- Transportation | 33748
-- Finance        | 28344
-- Healthcare     | 25953
-- Food           | 22855
-- Real Estate    | 17565
-- Travel         | 17159
-- Hardware       | 13828

-- 7. Top 7 countries with the highest total layoffs
SELECT
    country,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY country
ORDER BY total_laid_off DESC;

-- Output:
-- country         | total_laid_off
-- United States  | 256559
-- India          | 35993
-- Netherlands    | 17220
-- Sweden         | 11264
-- Brazil         | 10391
-- Germany        | 8701
-- United Kingdom | 6398

-- 8. Total layoffs per year
SELECT
    YEAR(`date`) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE `date` IS NOT NULL
GROUP BY year
ORDER BY year ASC;

-- Output:
-- year  | total_laid_off
-- 2020  | 80998
-- 2021  | 15823
-- 2022  | 160661
-- 2023  | 125677

-- 9. Top 10 funding stages with the highest total layoffs
SELECT
    stage,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE stage IS NOT NULL
GROUP BY stage
ORDER BY total_laid_off DESC
LIMIT 10;

-- Output:
-- stage           | total_laid_off
-- Post-IPO       | 204132
-- Unknown        | 40716
-- Acquired       | 27576
-- Series C       | 20017
-- Series D       | 19225
-- Series B       | 15311
-- Series E       | 12697
-- Series F       | 9932
-- Private Equity | 7957
-- Series H       | 7244

-- 10. Total layoffs in January of each year
SELECT
    SUBSTRING(`date`,1,7) AS `Month`,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
AND MONTH(`date`) = 1
GROUP BY `Month`
ORDER BY `Month` ASC;

-- Output:
-- Month   | total_laid_off
-- 2021-01 | 6813
-- 2022-01 | 510
-- 2023-01 | 84714

-- 12. Top 5 companies with the highest layoffs per year
WITH company_year AS (
    SELECT 
        company,
        YEAR(`date`) AS year,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging
    GROUP BY company, year
),
company_year_rank AS (
    SELECT *,
        DENSE_RANK() OVER(PARTITION BY year ORDER BY total_laid_off DESC) AS ranking
    FROM company_year
    WHERE year IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;

-- Output:

-- company	     | year | total_laid_off	| ranking
-- --------------|------|-------------------|--------
-- Uber	         | 2020 |   7525            |   1
-- Booking.com	 | 2020 |	437             |   2
-- Groupon	     | 2020 |	2800            |   3
-- Swiggy	     | 2020 |	2250            |   4
-- Airbnb	     | 2020 |	1900	        |   5
-- Bytedance	 | 2021 |	3600	        |   1
-- Katerra	     | 2021 |	2434	        |   2
-- Zillow	     | 2021 |	2000	        |   3
-- Instacart	 | 2021 |	1877	        |   4
-- WhiteHat Jr   | 2021 |	1800	        |   5
-- Meta	    	 | 2022 |   11000	        |   1
-- Amazon	     | 2022 |	10150	        |   2
-- Cisco	     | 2022 |	4100	        |   3
-- Peloton	     | 2022 |	4084	        |   4
-- Carvana       | 2022 |	4000	        |   5
-- Philips	     | 2022 |	4000	        |   5
-- Google        | 2023 |	12000	        |   1
-- Microsoft     | 2023 |	10000	        |   2
-- Ericsson	     | 2023 |	8500	        |   3
-- Amazon	     | 2023 |	8000	        |   4
-- Salesforce    | 2023 |	8000	        |   4
-- Dell	     	 | 2023 |   6650	        |   5
