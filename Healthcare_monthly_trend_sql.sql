-- ============================================================
-- FILE:    05_monthly_trend.sql
-- PROJECT: Healthcare Claims Denial Intelligence
-- DESC:    Time-series denial trend analysis — Jan to Dec 2023
--          Finding 5: August peak at 20.52% (summer staffing signal)
-- ============================================================

USE TestPortfolio;
GO

-- ============================================================
-- ANALYSIS 1: Monthly Denial Rate Trend
-- ============================================================

SELECT
    FORMAT(claim_date, 'yyyy-MM') AS claim_month,
    DATENAME(MONTH, claim_date) AS month_name,
    COUNT(*) AS total_claims,
    SUM(CAST(denial_flag AS INT)) AS denied_claims,
    COUNT(*) - SUM(CAST(denial_flag AS INT))  AS approved_claims,
    ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2) AS denial_rate_pct,
    ROUND(SUM(claim_amount), 2) AS total_billed,
    ROUND(SUM(approved_amount), 2) AS total_approved,
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END), 2) AS denied_value
FROM dbo.claims_dataset
GROUP BY FORMAT(claim_date, 'yyyy-MM'), DATENAME(MONTH, claim_date)
ORDER BY claim_month;
GO

-- ============================================================
-- ANALYSIS 2: Monthly Trend with MoM Change
--             Uses LAG() to calculate month-over-month delta
-- ============================================================

WITH monthly AS (
    SELECT
        FORMAT(claim_date, 'yyyy-MM') AS claim_month,
        COUNT(*) AS total_claims,
        SUM(CAST(denial_flag AS INT)) AS denied_claims,
        ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2) AS denial_rate_pct,
        ROUND(SUM(CASE WHEN denial_flag = 1
                       THEN claim_amount ELSE 0 END), 2) AS denied_value
    FROM dbo.claims_dataset
    GROUP BY FORMAT(claim_date, 'yyyy-MM')
)
SELECT
    claim_month,
    total_claims,
    denied_claims,
    denial_rate_pct,
    denied_value,
    LAG(denial_rate_pct) OVER (ORDER BY claim_month) AS prev_month_rate,
    ROUND(denial_rate_pct
        - LAG(denial_rate_pct) OVER (ORDER BY claim_month), 2) AS mom_rate_change,
    CASE
        WHEN denial_rate_pct > LAG(denial_rate_pct) OVER (ORDER BY claim_month) THEN 'Worsening'
        WHEN denial_rate_pct < LAG(denial_rate_pct) OVER (ORDER BY claim_month) THEN 'Improving'
        ELSE 'Flat'
    END   AS trend_direction
FROM monthly
ORDER BY claim_month;
GO

-- ============================================================
-- ANALYSIS 3: Quarterly Summary
-- ============================================================

SELECT
    CONCAT('Q', DATEPART(QUARTER, claim_date), ' ',
           YEAR(claim_date)) AS quarter,
    COUNT(*)  AS total_claims,
    SUM(CAST(denial_flag AS INT)) AS denied_claims,
    ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2) AS denial_rate_pct,
    ROUND(SUM(claim_amount), 2) AS total_billed,
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END), 2) AS denied_value
FROM dbo.claims_dataset
GROUP BY DATEPART(QUARTER, claim_date), YEAR(claim_date)
ORDER BY YEAR(claim_date), DATEPART(QUARTER, claim_date);
GO

-- ============================================================
-- ANALYSIS 4: Day-of-Week Pattern
--             Do claims filed on certain days have higher denial rates?
-- ============================================================

SELECT
    DATENAME(WEEKDAY, claim_date) AS day_of_week,
    DATEPART(WEEKDAY, claim_date) AS day_num,
    COUNT(*) AS total_claims,
    SUM(CAST(denial_flag AS INT)) AS denied_claims,
    ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2) AS denial_rate_pct
FROM dbo.claims_dataset
GROUP BY DATENAME(WEEKDAY, claim_date), DATEPART(WEEKDAY, claim_date)
ORDER BY day_num;
GO

-- ============================================================
-- ANALYSIS 5: Rolling 3-Month Average Denial Rate
-- ============================================================

WITH monthly AS (
    SELECT
        FORMAT(claim_date, 'yyyy-MM') AS claim_month,
        ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2) AS denial_rate_pct
    FROM dbo.claims_dataset
    GROUP BY FORMAT(claim_date, 'yyyy-MM')
)
SELECT
    claim_month,
    denial_rate_pct,
    ROUND(AVG(denial_rate_pct) OVER (
        ORDER BY claim_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)  AS rolling_3mo_avg
FROM monthly
ORDER BY claim_month;
GO