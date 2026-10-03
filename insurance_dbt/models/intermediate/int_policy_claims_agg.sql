select
    policy_id,
    count(*) as claim_count_actual,
    sum(claim_amount) as total_claim_amount
from {{ ref('stg_fremtpl2sev') }}
group by policy_id