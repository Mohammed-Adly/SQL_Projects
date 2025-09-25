# Exploratory Data Analysis (EDA) on Layoffs

This project explores layoffs data through a series of SQL queries.  
Each section presents a key **question**, the corresponding **SQL query**, and the **results**.
Check them out here: [Exploratory_Data_Analysis(EDA)](Exploratory_Data_Analysis(EDA).sql)

---

## 1. What is the maximum total laid off and the maximum percentage laid off?

```sql
SELECT 
    MAX(total_laid_off) AS max_total,
    MAX(percentage_laid_off) AS max_percentage
FROM
    layoffs_staging;
```

**Result:**
```
max_total | max_percentage
12000     | 1
```

---

## 2. How many companies had 100% layoffs?

```sql
SELECT
    COUNT(company) AS total_companies
FROM
    layoffs_staging
WHERE
    percentage_laid_off = 1;
```

**Result:**
```
total_companies
116
```

---


## 3. How many companies had 100% layoffs in 2023?

```sql
SELECT COUNT(company) AS total_companies
FROM layoffs_staging
WHERE percentage_laid_off = 1
AND YEAR(`date`) = 2023;
```

**Result:**
```
total_companies
14
```

---

## 4. Top 5 companies with the highest total layoffs

```sql
SELECT
    company,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 5;
```

**Result:**
```
company     | total_laid_off
Amazon      | 18150
Google      | 12000
Meta        | 11000
Salesforce  | 10090
Microsoft   | 10000
```

---

## 5. Start date and end date of layoffs data

```sql
SELECT
    MIN(`date`) AS start_date,
    MAX(`date`) AS end_date
FROM layoffs_staging;
```

**Result:**
```
start_date  | end_date
2020-03-11  | 2023-03-06
```

---

## 6. Top 10 industries with the highest total layoffs

```sql
SELECT
    industry,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY industry
ORDER BY total_laid_off DESC
LIMIT 10;
```

**Result:**
```
industry        | total_laid_off
Consumer        | 45182
Retail          | 43613
Other           | 36289
Transportation  | 33748
Finance         | 28344
Healthcare      | 25953
Food            | 22855
Real Estate     | 17565
Travel          | 17159
Hardware        | 13828
```

---

## 7. Top 7 countries with the highest total layoffs

```sql
SELECT
    country,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY country
ORDER BY total_laid_off DESC;
```

**Result:**
```
country         | total_laid_off
United States   | 256559
India           | 35993
Netherlands     | 17220
Sweden          | 11264
Brazil          | 10391
Germany         | 8701
United Kingdom  | 6398
```

---

## 8. Total layoffs per year

```sql
SELECT
    YEAR(`date`) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE `date` IS NOT NULL
GROUP BY year
ORDER BY year ASC;
```

**Result:**
```
year  | total_laid_off
2020  | 80998
2021  | 15823
2022  | 160661
2023  | 125677
```

---

## 9. Top 10 funding stages with the highest total layoffs

```sql
SELECT
    stage,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE stage IS NOT NULL
GROUP BY stage
ORDER BY total_laid_off DESC
LIMIT 10;
```

**Result:**
```
stage           | total_laid_off
Post-IPO        | 204132
Unknown         | 40716
Acquired        | 27576
Series C        | 20017
Series D        | 19225
Series B        | 15311
Series E        | 12697
Series F        | 9932
Private Equity  | 7957
Series H        | 7244
```

---

## 10. Total layoffs in January of each year

```sql
SELECT
    SUBSTRING(`date`,1,7) AS `Month`,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
AND MONTH(`date`) = 1
GROUP BY `Month`
ORDER BY `Month` ASC;
```

**Result:**
```
Month   | total_laid_off
2021-01 | 6813
2022-01 | 510
2023-01 | 84714
```

---

## 11. Top 5 companies with the highest layoffs per year

```sql
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
```

**Result (sample):**
```
company      | year | total_laid_off | ranking
Uber         | 2020 | 7525           | 1
Booking.com  | 2020 | 437            | 2
Groupon      | 2020 | 2800           | 3
Swiggy       | 2020 | 2250           | 4
Airbnb       | 2020 | 1900           | 5
Bytedance    | 2021 | 3600           | 1
Meta         | 2022 | 11000          | 1
Google       | 2023 | 12000          | 1
...
```

---

Each query provides a different perspective on layoffs, helping uncover trends across time, industries, companies, and funding stages.
