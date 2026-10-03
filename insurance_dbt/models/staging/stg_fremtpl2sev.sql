select
    cast("IDpol" as bigint) as policy_id,
    "ClaimAmount" as claim_amount
from {{ source('raw', 'raw_fremtpl2sev') }}