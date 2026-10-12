-- Reconcile every source claim against the policy fact and
-- the unmatched-policy exception model.
-- This test passes when it returns zero rows.

with source_totals as (
    select
        count(*) as source_claim_rows,
        coalesce(sum(claim_amount), 0) as source_total_claim_amount
    from {{ ref('stg_fremtpl2sev') }}
),

policy_fact_totals as (
    select
        coalesce(sum(claim_count_actual), 0) as claim_rows,
        coalesce(sum(total_claim_amount), 0) as claim_amount
    from {{ ref('fct_policy_claims') }}
),

exception_totals as (
    select
        count(*) as claim_rows,
        coalesce(sum(claim_amount), 0) as claim_amount
    from {{ ref('fct_unmatched_policy_claims') }}
),

combined_totals as (
    select
        policy_fact_totals.claim_rows + exception_totals.claim_rows
            as combined_claim_rows,
        policy_fact_totals.claim_amount + exception_totals.claim_amount
            as combined_claim_amount
    from policy_fact_totals
    cross join exception_totals
)

select
    source_totals.source_claim_rows,
    combined_totals.combined_claim_rows,
    source_totals.source_total_claim_amount,
    combined_totals.combined_claim_amount
from source_totals
cross join combined_totals
where source_totals.source_claim_rows <> combined_totals.combined_claim_rows
   or abs(
       source_totals.source_total_claim_amount
       - combined_totals.combined_claim_amount
   ) > 0.01
