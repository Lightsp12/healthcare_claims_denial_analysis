-- ============================================================
-- FILE:    03_denial_rate_by_payer.sql
-- PROJECT: Healthcare Claims Denial Intelligence
-- DESC:    Denial rate segmentation by payer type
-- ============================================================

USE TestPortfolio;
GO

-- ============================================================
-- ANALYSIS 1: Denial Rate & Revenue Exposure by Payer Type
-- ============================================================

SELECT
    payer_type,
    COUNT(*) AS total_claims,
    SUM(CAST(denial_flag AS INT)) AS denied_claims,
    COUNT(*) - SUM(CAST(denial_flag AS INT)) AS approved_claims,
    ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2) AS denial_rate_pct,

    -- Financial exposure
    ROUND(SUM(claim_amount), 2) AS total_billed,
    ROUND(SUM(approved_amount), 2) AS total_approved,
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END), 2) AS denied_value,

    -- Average metrics
    ROUND(AVG(claim_amount), 2) AS avg_claim_amount,
    ROUND(AVG(CAST(length_of_stay AS FLOAT)), 1) AS avg_length_of_stay,
    ROUND(AVG(cost_per_case), 2) AS avg_cost_per_case
FROM dbo.claims_dataset
GROUP BY payer_type
ORDER BY denial_rate_pct DESC;
GO

-- ============================================================
-- ANALYSIS 2: Denial Rate by Payer × Reimbursement Model
--             (Cross-tab to test interaction effect)
-- ============================================================

SELECT
    payer_type,
    reimbursement_model,
    COUNT(*) AS total_claims,
    SUM(CAST(denial_flag AS INT)) AS denied_claims,
    ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2) AS denial_rate_pct,
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END), 2) AS denied_value
FROM dbo.claims_dataset
GROUP BY payer_type, reimbursement_model
ORDER BY payer_type, denial_rate_pct DESC;
GO

-- ============================================================
-- ANALYSIS 3: Denial Rate by Payer × Procedure Code
--             (Identifies payer-procedure combinations driving excess denials)
-- ============================================================

SELECT
    payer_type,
    procedure_code,
    COUNT(*) AS total_claims,
    SUM(CAST(denial_flag AS INT)) AS denied_claims,
    ROUND(SUM(CAST(denial_flag AS INT)) * 100.0 / COUNT(*), 2) AS denial_rate_pct,
    ROUND(SUM(CASE WHEN denial_flag = 1
                   THEN claim_amount ELSE 0 END), 2) AS denied_value,
    ROUND(AVG(claim_amount), 2) AS avg_claim_amount
FROM dbo.claims_dataset
GROUP BY payer_type, procedure_code
ORDER BY payer_type, denial_rate_pct DESC;
GO

-- ============================================================
-- ANALYSIS 4: Top 10 Highest-Value Denied Claims by Payer
-- ============================================================

SELECT TOP 10
    claim_id,
    payer_type,
    reimbursement_model,
    procedure_code,
    claim_amount,
    length_of_stay,
    cost_per_case,
    claim_date
FROM dbo.claims_dataset
WHERE denial_flag = 1
ORDER BY claim_amount DESC;
GO