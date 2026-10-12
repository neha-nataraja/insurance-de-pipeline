-- Reconcile total claim amounts from the severity source to the policy fact.
-- This test passes when it returns zero rows.
with source_totals as (
    select
        count(*) as source_claim_rows,
        coalesce(sum(claim_amount), 0) as source_total_claim_amount
    from {{ ref('stg_fremtpl2sev') }}
),
fact_totals as (
    select
        coalesce(sum(claim_count_actual), 0) as fact_claim_rows,
        coalesce(sum(total_claim_amount), 0) as fact_total_claim_amount
    from {{ ref('fct_policy_claims') }}
)
select
    source_totals.source_claim_rows,
    fact_totals.fact_claim_rows,
    source_totals.source_total_claim_amount,
    fact_totals.fact_total_claim_amount
from source_totals
cross join fact_totals
where source_totals.source_claim_rows <> fact_totals.fact_claim_rows
   or abs(
        source_totals.source_total_claim_amount
        - fact_totals.fact_total_claim_amount
   ) > 0.01
