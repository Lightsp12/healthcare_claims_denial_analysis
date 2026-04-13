-- ============================================================
-- FILE:    04_revenue_leakage.sql
-- PROJECT: Healthcare Claims Denial Intelligence
-- DESC:    Full revenue leakage waterfall analysis
--          Billed → Approved → Denied → Underpayment gap
-- ============================================================

USE TestPortfolio;
GO

-- ============================================================
-- ANALYSIS 1: Enterprise-Level Revenue Waterfall
-- ============================================================

SELECT
    -- Volume
    COUNT(*) AS total_claims,
    SUM(CAST(denial_flag AS INT)) AS total_denied_claims,
    COUNT(*) - SUM(CAST(denial_flag AS INT)) AS total_approved_claims,

    -- Revenue layers
    ROUND(SUM(claim_amount), 2) AS total_billed,
    ROUND(SUM(approved_amount), 2) AS total_approved,
    ROUND(SUM(claim_amount) - SUM(approved_amount), 2) AS total_revenue_gap,

    -- Denial layer
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END), 2) AS denied_claims_value,

    -- Underpayment layer (approved but less than billed, among non-denied)
    ROUND(SUM(CASE WHEN denial_flag = 0
                        AND approved_amount < claim_amount
                   THEN claim_amount - approved_amount
                   ELSE 0 END), 2) AS underpayment_gap,

    -- Rate metrics
    ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2) AS overall_denial_rate_pct,
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END)
          * 100.0 / SUM(claim_amount), 2) AS denied_value_pct_of_billed,
    ROUND((SUM(claim_amount) - SUM(approved_amount))
          * 100.0 / SUM(claim_amount), 2) AS total_gap_pct_of_billed
FROM dbo.claims_dataset;
GO

-- ============================================================
-- ANALYSIS 2: Revenue Leakage by Payer Type
-- ============================================================

SELECT
    payer_type,
    COUNT(*) AS total_claims,
    ROUND(SUM(claim_amount), 2) AS total_billed,
    ROUND(SUM(approved_amount), 2) AS total_approved,
    ROUND(SUM(claim_amount) - SUM(approved_amount), 2) AS revenue_gap,
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END), 2) AS denied_value,
    ROUND(SUM(CASE WHEN denial_flag = 0
                        AND approved_amount < claim_amount
                   THEN claim_amount - approved_amount
                   ELSE 0 END), 2) AS underpayment_gap,
    ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2) AS denial_rate_pct,
    ROUND((SUM(claim_amount) - SUM(approved_amount))
          * 100.0 / SUM(claim_amount), 2) AS gap_pct_of_billed
FROM dbo.claims_dataset
GROUP BY payer_type
ORDER BY revenue_gap DESC;
GO

-- ============================================================
-- ANALYSIS 3: Revenue Leakage by Procedure Code
-- ============================================================

SELECT
    procedure_code,
    COUNT(*) AS total_claims,
    SUM(CAST(denial_flag AS INT)) AS denied_claims,
    ROUND(SUM(claim_amount), 2) AS total_billed,
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END), 2) AS denied_value,
    ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2) AS denial_rate_pct,
    ROUND(AVG(claim_amount), 2) AS avg_claim_amount,
    ROUND(AVG(CAST(length_of_stay AS FLOAT)), 1) AS avg_los
FROM dbo.claims_dataset
GROUP BY procedure_code
ORDER BY denied_value DESC;
GO

-- ============================================================
-- ANALYSIS 4: Approved vs Denied — Cost & LOS Profile
--             Do denied claims have different clinical characteristics?
-- ============================================================

SELECT
    CASE WHEN denial_flag = 1 THEN 'Denied' ELSE 'Approved' END AS claim_status,
    COUNT(*) AS claim_count,
    ROUND(AVG(claim_amount), 2) AS avg_claim_amount,
    ROUND(AVG(approved_amount), 2) AS avg_approved_amount,
    ROUND(AVG(CAST(length_of_stay AS FLOAT)), 2) AS avg_length_of_stay,
    ROUND(AVG(cost_per_case), 2) AS avg_cost_per_case,
    ROUND(MIN(claim_amount), 2) AS min_claim,
    ROUND(MAX(claim_amount), 2) AS max_claim
FROM dbo.claims_dataset
GROUP BY denial_flag
ORDER BY denial_flag;
GO

-- ============================================================
-- ANALYSIS 5: Appeals Priority Queue
--             Denied claims > $5,000 ordered by value 
-- ============================================================

SELECT
    claim_id,
    patient_id,
    provider_id,
    payer_type,
    reimbursement_model,
    procedure_code,
    claim_amount,
    length_of_stay,
    cost_per_case,
    claim_date,
    -- Estimated recovery at 50% industry benchmark
    ROUND(claim_amount * 0.50, 2) AS estimated_recovery_50pct
FROM dbo.claims_dataset
WHERE denial_flag   = 1
  AND claim_amount  > 5000
ORDER BY claim_amount DESC;
GO