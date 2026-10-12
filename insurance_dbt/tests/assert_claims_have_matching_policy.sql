{{ config(severity='warn') }}

-- Every severity claim should map to a policy in the frequency table.
-- Known unmatched policy IDs are surfaced as warnings while being retained
-- in fct_unmatched_policy_claims for investigation.
select distinct
    sev.policy_id
from {{ ref('stg_fremtpl2sev') }} as sev
left join {{ ref('stg_fremtpl2freq') }} as freq
    on sev.policy_id = freq.policy_id
where freq.policy_id is null
