# SQL Data Cleaning

This project focuses on cleaning and standardizing a dataset related to global layoffs in 2022. The goal is to ensure the data is accurate, consistent, and ready for analysis.
Check them out here: [data_cleaning.sql](data_cleaning.sql)

---

## Background

This project was inspired by the need to clean and prepare raw data for analysis. The dataset contains information about layoffs from various companies worldwide, including details like company names, industries, locations, and the number of employees laid off. The cleaning process ensures the data is reliable and ready for further exploration.

### The questions I wanted to answer through my SQL queries were:

1. **How can we identify and remove duplicate records?**
2. **How can we standardize data formats and fix errors?**
3. **How do we handle null or missing values?**
4. **Which columns or rows can be removed to improve data quality?**

---

## Tools I Used

For this data cleaning project, I relied on the following tools:

- **SQL:** The backbone of my analysis, allowing me to query and clean the dataset.
- **MySQL:** The chosen database management system for handling the layoffs data.
- **Git & GitHub:** Essential for version control and sharing my SQL scripts and analysis.

---

### 1. Remove Duplicates

To ensure data accuracy, I identified and removed duplicate records from the dataset.

```sql
-- Create a staging table to preserve raw data
CREATE TABLE world_layoffs.layoffs_staging
LIKE world_layoffs.layoffs;

INSERT INTO layoffs_staging
SELECT * FROM world_layoffs.layoffs;

-- Identify duplicates using ROW_NUMBER()
SELECT *
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
) duplicates
WHERE row_num > 1;

-- Remove duplicates
DELETE FROM layoffs_staging2
WHERE row_num > 1;
```

**Key Insights:**

- Duplicates were identified using a combination of columns like `company`, `location`, `industry`, and `date`.
- A staging table was created to preserve the raw data before cleaning.

---

### 2. Standardize Data

To ensure consistency, I standardized the data by trimming whitespace, fixing industry names, and correcting country names.

```sql
-- Trim whitespace from company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize the 'Crypto' industry
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardize country names
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Convert date format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
```

**Key Insights:**

- Whitespace was removed from company names to ensure consistency.
- Variations of the 'Crypto' industry were standardized.
- Date formats were corrected and converted to the `DATE` data type.

---

### 3. Handle Null Values

To improve data quality, I addressed null or missing values in the dataset.

```sql
-- Update blank industry fields to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populate missing industry values using existing data
UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
    AND t2.industry IS NOT NULL;
```

**Key Insights:**

- Blank industry fields were updated to `NULL` for easier handling.
- Missing industry values were populated using existing data from the same company.

---

### 4. Remove Unnecessary Columns and Rows

To streamline the dataset, I removed unnecessary columns and rows.

```sql
-- Delete rows where both total_laid_off and percentage_laid_off are NULL
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

-- Drop the row_num column used for duplicate removal
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
```

**Key Insights:**

- Rows with no relevant data (both `total_laid_off` and `percentage_laid_off` as `NULL`) were removed.
- The `row_num` column, used for duplicate removal, was dropped after cleaning.

---

## What I Learned

Throughout this project, I enhanced my SQL skills and gained valuable experience in data cleaning:

- **Data Cleaning Techniques:** Learned how to identify and remove duplicates, standardize data, and handle null values.
- **Date Formatting:** Mastered converting and standardizing date formats in SQL.
- **Data Quality Improvement:** Understood the importance of removing unnecessary columns and rows to improve data quality.

---

## Conclusions

This project was a great opportunity to practice data cleaning techniques using SQL. The cleaned dataset is now ready for further analysis, and the skills I gained will be invaluable for future data projects. Clean data is the foundation of any successful analysis, and this project reinforced that principle.
