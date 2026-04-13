-- ============================================================
-- FILE:    06_executive_kpi_summary.sql
-- PROJECT: Healthcare Claims Denial Intelligence
-- ============================================================



-- ============================================================
-- MASTER KPI SUMMARY — Run this for the one-page executive view
-- ============================================================

SELECT
    --Volume
    COUNT(*)  AS total_claims,
    SUM(CAST(denial_flag AS INT)) AS total_denied,
    COUNT(*) - SUM(CAST(denial_flag AS INT)) AS total_approved,
    ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2) AS denial_rate_pct,

    -- Revenue 
    ROUND(SUM(claim_amount), 2) AS total_billed,
    ROUND(SUM(approved_amount), 2) AS total_approved_revenue,
    ROUND(SUM(claim_amount) - SUM(approved_amount), 2)  AS total_revenue_gap,
    ROUND((SUM(claim_amount) - SUM(approved_amount))
          * 100.0 / SUM(claim_amount), 2) AS gap_pct_of_billed,

    --  Denial Financial Exposure 
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END), 2) AS denied_claims_value,
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END)
          * 100.0 / SUM(claim_amount), 2) AS denied_pct_of_billed,

    -- Underpayment Exposure 
    ROUND(SUM(CASE WHEN denial_flag = 0
                        AND approved_amount < claim_amount
                   THEN claim_amount - approved_amount
                   ELSE 0 END), 2) AS underpayment_gap,

    -- Recovery Opportunity (conservative @ 50%) 
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END) * 0.50, 2) AS recovery_potential_50pct,

    -- Clinical Metrics 
    ROUND(AVG(CAST(length_of_stay AS FLOAT)), 1)  AS avg_length_of_stay,
    ROUND(AVG(cost_per_case), 2) AS avg_cost_per_case,
    ROUND(AVG(claim_amount), 2)  AS avg_claim_amount,

    -- Date Range
    MIN(claim_date) AS data_start_date,
    MAX(claim_date) AS data_end_date
FROM dbo.claims_dataset;
GO

-- ============================================================
-- PAYER SCORECARD — Side-by-side payer comparison
-- ============================================================

SELECT
    payer_type,
    COUNT(*)   AS claims,
    ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2) AS denial_rate_pct,
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END), 2) AS at_risk_revenue,
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END) * 0.50, 2) AS recovery_potential,
    ROUND(AVG(claim_amount), 2) AS avg_claim,
    RANK() OVER (ORDER BY SUM(CAST(denial_flag AS INT))
                          * 100.0 / COUNT(*) DESC) AS denial_rate_rank
FROM dbo.claims_dataset
GROUP BY payer_type
ORDER BY denial_rate_rank;
GO

-- ============================================================
-- PROCEDURE RISK MATRIX — Ranked by financial impact
-- ============================================================

SELECT
    procedure_code,
    COUNT(*)  AS total_claims,
    SUM(CAST(denial_flag AS INT))  AS denied_count,
    ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2)  AS denial_rate_pct,
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END), 2) AS denied_value,
    ROUND(AVG(CAST(length_of_stay AS FLOAT)), 1)  AS avg_los,
    DENSE_RANK() OVER (ORDER BY SUM(CAST(denial_flag AS INT))
                                * 100.0 / COUNT(*) DESC) AS risk_rank
FROM dbo.claims_dataset
GROUP BY procedure_code
ORDER BY risk_rank;
GO