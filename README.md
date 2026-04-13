# Healthcare Claims Denial Intelligence: Revenue Leakage & Risk Analysis

(file:///C:/Users/jesus/Downloads/portfolio_project%20(2).html)

# Executive Summary

Claim denial rates remain elevated across the health system, prompting revenue cycle leadership to seek root causes and actionable solutions. Using SQL, Python, and a structured analytical framework, I extracted the claims dataset, conducted multi-dimensional denial segmentation, and quantified the total revenue impact. The analysis revealed that nearly 1 in 5 claims is denied uniformly across all payers, resulting in a $286.8M gap between billed and approved amounts. I recommend the Revenue Cycle team take three immediate actions:

1. Launch a targeted denial appeal program for high-value claims (>$5,000)
2. Implement front-end eligibility verification and pre-authorization checklists.
3. Negotiate denial rate SLAs into all new payer contracts.

---

# Business Problem

Denied claims are the primary source of revenue leakage in healthcare. Leadership noted persistently high denial rates but lacked insight into which payer segments, procedure codes, or time periods contributed most to them. Without this breakdown, targeted solutions were not possible.

How can we pinpoint where denials occur in the claims process, identify the segments with the highest financial risk, and determine which interventions will yield the greatest recovery ROI?

Stakeholders: CFO · Revenue Cycle Director · Billing Operations · Payer Contracting

---

# Methodology

1. SQL: Designed schema, SQL query that extracts, cleans, and transforms the data from the database, reimbursement model, and procedure code.
2. Python (pandas): Conducted exploratory data analysis, monthly trend decomposition with month-over-month change detection, revenue leakage analysis, and ROI modeling for four intervention scenarios.
3. Multi-Dimensional Segmentation: Analyzed denial rates across key dimensions to determine if the issue is payer-driven, procedure-driven, or structural.

---

# Skills

SQL: DDL/DML, BULK INSERT, CASE, aggregate functions, window functions (LAG), INFORMATION_SCHEMA validation, analytical indexes
Python: pandas, groupby/agg, time-series period analysis, lambda functions, ROI modeling
Analytics: Revenue leakage quantification, denial rate benchmarking, cohort segmentation, MoM trend analysis, appeal ROI modeling
Domain: Healthcare Revenue Cycle Management, payer mix, reimbursement models, denial management, underpayment recovery

---

# Results & Business Recommendations

Denial rates remain approximately 20% across all payer segments (Medicare 20.15%, Medicaid 19.86%, Private 19.67%), ruling out payer contract issues as the cause. Consistent rates across payers indicate the problem lies upstream in documentation and coding, not in contracts.

The analysis also found that the reimbursement model (Fee-for-Service vs. Value-Based) does not affect denial likelihood, with both at approximately 19.9%. Although value-based contracts are often expected to reduce administrative friction, the data do not support this assumption.

PROC_C has the highest denial rate among all procedure codes at 20.20%. This 0.43-point excess over the lowest-denial procedure results in approximately $1.1M in additional annual leakage, which can be addressed through targeted pre-submission documentation review.

August has the highest denial rate at 20.52%, which aligns with summer resident transitions and the billing department's vacation periods. The annual denial rate trend is flat, indicating that without intervention, the same $204M in denied claims will recur next year.

Total revenue gap: $286.8M ($204M in denials + $82.8M in underpayments on approved claims).

Based on these findings, I recommend four actions:

1. Appeal all denied claims above $5,000. Industry first-level appeal recovery rates are 45–60%, making $86M–$115M in recoverable revenue attainable from this group alone.
2. Implement pre-authorization and eligibility verification workflows at the front end of the revenue cycle to eliminate preventable denials before submission, targeting a 30–40% reduction in avoidable denials.
3. Assign dedicated coding review to PROC_C claims before submission to address the procedure's above-average denial rate and recover the estimated $1.1M in annual excess leakage.
4. Increase billing quality assurance staffing from June through August, and set an automated alert to flag any month in which the denial rate exceeds 20%.

These actions directly address the largest financial exposures and can be implemented within the current operational structure, without requiring new payer contracts or system changes.

---

# Next Steps

1. Extract denial reason codes from payer 835 remittance files to build a root cause taxonomy (CO-4, CO-97, PR-96). This will confirm whether the upstream documentation hypothesis is correct and identify the specific coding gaps causing denials.
2. Conduct provider-level segmentation to identify which providers or departments generate disproportionate denials, enabling targeted education rather than organization-wide interventions.
3. Benchmark performance against HFMA standards (industry median approximately 10–12%) and present the performance gap to leadership to support a business case for a comprehensive Revenue Cycle transformation initiative.
