select
    freq.policy_id,
    freq.exposure,
    freq.area,
    freq.vehicle_power,
    freq.vehicle_age,
    freq.driver_age,
    freq.bonus_malus,
    freq.vehicle_brand,
    freq.vehicle_fuel_type,
    freq.density,
    freq.region,
    freq.claim_count as claim_count_reported,
    coalesce(claims.claim_count_actual, 0) as claim_count_actual,
    coalesce(claims.total_claim_amount, 0) as total_claim_amount
from {{ ref('stg_fremtpl2freq') }} as freq
left join {{ ref('int_policy_claims_agg') }} as claims
    on freq.policy_id = claims.policy_id