-- Preserve claims whose policy ID is missing from the frequency source.
-- These records need investigation and must not silently disappear.

select
    sev.policy_id,
    sev.claim_amount
from {{ ref('stg_fremtpl2sev') }} as sev
where not exists (
    select 1
    from {{ ref('stg_fremtpl2freq') }} as freq
    where freq.policy_id = sev.policy_id
)
