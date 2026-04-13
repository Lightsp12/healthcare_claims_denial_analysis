-- ============================================================
-- SECTION B: COLUMN TYPE VERIFICATION
-- ============================================================
 
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME   = 'claims_dataset'
  AND TABLE_SCHEMA = 'dbo'
ORDER BY ORDINAL_POSITION;
 
-- ============================================================
-- SECTION C: BUSINESS RULE VALIDATION
-- ============================================================
 
-- Rule 1: No negative claim amounts
SELECT COUNT(*) AS invalid_negative_claims
FROM dbo.claims_dataset
WHERE claim_amount < 0 OR approved_amount < 0;
 
-- Rule 2: Denied claims should have approved_amount = 0 or less than claim_amount
SELECT
    denial_flag,
    COUNT(*)  AS claim_count,
    AVG(approved_amount)  AS avg_approved,
    SUM(CASE WHEN approved_amount > claim_amount
             THEN 1 ELSE 0 END) AS approved_exceeds_claimed  -- flag anomalies
FROM dbo.claims_dataset
GROUP BY denial_flag;
 
-- Rule 3: denial_flag must only be 0 or 1
SELECT DISTINCT denial_flag
FROM dbo.claims_dataset
ORDER BY denial_flag;
 
-- Rule 4: Distinct categorical values
SELECT 'payer_type'  AS column_name, payer_type  AS distinct_value, COUNT(*) AS freq FROM dbo.claims_dataset GROUP BY payer_type
UNION ALL
SELECT 'reimbursement_model' AS column_name, reimbursement_model AS distinct_value, COUNT(*) AS freq FROM dbo.claims_dataset GROUP BY reimbursement_model
UNION ALL
SELECT 'procedure_code' AS column_name, procedure_code  AS distinct_value, COUNT(*) AS freq FROM dbo.claims_dataset GROUP BY procedure_code
ORDER BY column_name, freq DESC;
 
-- Rule 5: Date range sanity check
SELECT
    MIN(claim_date) AS earliest_claim,
    MAX(claim_date) AS latest_claim,
    DATEDIFF(DAY, MIN(claim_date), MAX(claim_date)) AS date_span_days
FROM dbo.claims_dataset;
 
-- ============================================================
-- SECTION D: DESCRIPTIVE STATISTICS
-- ============================================================
 
SELECT
    COUNT(*)                     AS total_records,
    MIN(claim_amount)            AS min_claim_amt,
    MAX(claim_amount)            AS max_claim_amt,
    AVG(claim_amount)            AS avg_claim_amt,
    STDEV(claim_amount)          AS stddev_claim_amt,
    MIN(approved_amount)         AS min_approved_amt,
    MAX(approved_amount)         AS max_approved_amt,
    AVG(approved_amount)         AS avg_approved_amt,
    AVG(CAST(denial_flag AS FLOAT)) * 100 AS overall_denial_rate_pct,
    MIN(length_of_stay)          AS min_los,
    MAX(length_of_stay)          AS max_los,
    AVG(CAST(length_of_stay AS FLOAT))   AS avg_los,
    MIN(cost_per_case)           AS min_cost_per_case,
    MAX(cost_per_case)           AS max_cost_per_case,
    AVG(cost_per_case)           AS avg_cost_per_case
FROM dbo.claims_dataset;
GO