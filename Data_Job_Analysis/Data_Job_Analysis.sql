/*
Question: What are the top-paying data analyst jobs?

- Identify the top 10 highest-paying Data Analyst roles that are available remotely.
- Focuses on job postings with specified salaries (remove nulls)
- BONUS: Include company names of top 10 roles
- Why? Highlight the top-paying opportunities for Data Analysts, offering insights into employment options and location flexibility.
*/

SELECT
	job_id,
	job_title,
	job_location,
	job_schedule_type,
	salary_year_avg,
	job_posted_date,
    name AS company_name 
FROM
	job_posting_fact
LEFT JOIN
	company_dim 
ON
	job_posting_fact.company_id = company_dim.company_id
WHERE
	job_location = 'Anywhere'
ORDER BY
	salary_year_avg DESC
LIMIT 10
;


/*
Here's the breakdown of the top data analyst jobs in 2023:
Wide Salary Range: Top 10 paying data analyst roles span from $184,000 to $650,000, indicating significant salary potential in the field.
Diverse Employers: Companies like SmartAsset, Meta, and AT&T are among those offering high salaries, showing a broad interest across different industries.
Job Title Variety: There's a high diversity in job titles, from Data Analyst to Director of Analytics, reflecting varied roles and specializations within data analytics.
*/

---

/*
Question: What skills are required for the top-paying data analyst jobs?
- Use the top 10 highest-paying Data Analyst jobs from first query
- Add the specific skills required for these roles
- Why? It provides a detailed look at which high-paying jobs demand certain skills, 
    helping job seekers understand which skills to develop that align with top salaries
*/

WITH top_playing_jobs AS (
	SELECT
		job_id,
		job_title,
		salary_year_avg,
		name AS company_name 
	FROM
		job_posting_fact
	INNER JOIN
		company_dim 
	ON
		job_posting_fact.company_id = company_dim.company_id
	WHERE
		job_location = 'Anywhere'
	ORDER BY
		salary_year_avg DESC
	LIMIT 10
)

SELECT 
	top_playing_jobs.*,
    skills
FROM
	top_playing_jobs
INNER JOIN skills_job_dim ON top_playing_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id 
ORDER BY
	salary_year_avg DESC;


/*
Here's the breakdown of the most demanded skills for data analysts in 2023, based on job postings:
SQL is leading with a bold count of 8.
Python follows closely with a bold count of 7.
Tableau is also highly sought after, with a bold count of 6.
Other skills like R, Snowflake, Pandas, and Excel show varying degrees of demand.
*/

---

/*
Question: What are the most in-demand skills for data analysts?
- Join job postings to inner join table similar to query 2
- Identify the top 5 in-demand skills for a data analyst.
- Focus on all job postings.
- Why? Retrieves the top 5 skills with the highest demand in the job market, 
    providing insights into the most valuable skills for job seekers.
*/

SELECT 
    skills,
    count(skills_job_dim.job_id) AS demand_count
FROM job_posting_fact
INNER JOIN skills_job_dim ON job_posting_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' 
    AND job_work_from_home = True 
GROUP BY
    skills
ORDER BY
    demand_count DESC
LIMIT 5;

/*
Here's the breakdown of the most demanded skills for data analysts in 2023
SQL and Excel remain fundamental, emphasizing the need for strong foundational skills in data processing and spreadsheet manipulation.
Programming and Visualization Tools like Python, Tableau, and Power BI are essential, pointing towards the increasing importance of technical skills in data storytelling and decision support.

*/

---

/*
Answer: What are the top skills based on salary?
- Look at the average salary associated with each skill for Data Analyst positions
- Focuses on roles with specified salaries, regardless of location
- Why? It reveals how different skills impact salary levels for Data Analysts and 
    helps identify the most financially rewarding skills to acquire or improve
*/

SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_posting_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True 
GROUP BY
    skills
ORDER BY
    avg_salary DESC
LIMIT 25;

/*
Here's a breakdown of the results for top paying skills for Data Analysts:
- High Demand for Big Data & ML Skills: Top salaries are commanded by analysts skilled in big data technologies (PySpark, Couchbase), machine learning tools (DataRobot, Jupyter), and Python libraries (Pandas, NumPy), reflecting the industry's high valuation of data processing and predictive modeling capabilities.
- Software Development & Deployment Proficiency: Knowledge in development and deployment tools (GitLab, Kubernetes, Airflow) indicates a lucrative crossover between data analysis and engineering, with a premium on skills that facilitate automation and efficient data pipeline management.
- Cloud Computing Expertise: Familiarity with cloud and data engineering tools (Elasticsearch, Databricks, GCP) underscores the growing importance of cloud-based analytics environments, suggesting that cloud proficiency significantly boosts earning potential in data analytics.
*/

---

/*
Answer: What are the most optimal skills to learn (aka it’s in high demand and a high-paying skill)?
- Identify skills in high demand and associated with high average salaries for Data Analyst roles
- Concentrates on remote positions with specified salaries
- Why? Targets skills that offer job security (high demand) and financial benefits (high salaries), 
    offering strategic insights for career development in data analysis
*/
create table download 
WITH skills_demand AS(
	SELECT
		skills_dim.skill_id,
		skills_dim.skills,
		count(skills_job_dim.job_id) AS  demand_count
	FROM
		job_posting_fact
	INNER JOIN
	skills_job_dim 
	ON job_posting_fact.job_id = skills_job_dim.job_id
	INNER JOIN
		skills_dim
	ON skills_job_dim.skill_id = skills_dim.skill_id
	GROUP BY skills_dim.skill_id, skills_dim.skills
),

average_salary AS (
	SELECT
        skills_job_dim.skill_id,
		FLOOR(AVG(salary_year_avg)) AS salary_avg
	FROM
		job_posting_fact
	INNER JOIN
		skills_job_dim
	ON job_posting_fact.job_id = skills_job_dim.job_id
	INNER JOIN skills_dim
	ON skills_job_dim.skill_id = skills_dim .skill_id
	GROUP BY skills_job_dim.skill_id
)

SELECT 
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    salary_avg
FROM skills_demand
INNER JOIN average_salary
ON skills_demand.skill_id = average_salary.skill_id
ORDER BY 
	demand_count DESC,
    salary_avg DESC
LIMIT 5;


/*
Here's a breakdown of the most optimal skills for Data Analysts in 2023: 
High-Demand Programming Languages: Python and R stand out for their high demand, with demand counts of 236 and 148 respectively. Despite their high demand, their average salaries are around $101,397 for Python and $100,499 for R, indicating that proficiency in these languages is highly valued but also widely available.
Cloud Tools and Technologies: Skills in specialized technologies such as Snowflake, Azure, AWS, and BigQuery show significant demand with relatively high average salaries, pointing towards the growing importance of cloud platforms and big data technologies in data analysis.
Business Intelligence and Visualization Tools: Tableau and Looker, with demand counts of 230 and 49 respectively, and average salaries around $99,288 and $103,795, highlight the critical role of data visualization and business intelligence in deriving actionable insights from data.
Database Technologies: The demand for skills in traditional and NoSQL databases (Oracle, SQL Server, NoSQL) with average salaries ranging from $97,786 to $104,534, reflects the enduring need for data storage, retrieval, and management expertise.
*/