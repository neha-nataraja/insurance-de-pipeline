-- models/marts/mart_risk_segment_loss_cost.sql
--
-- Business question: where in the current rating structure (bonus-malus x
-- vehicle power x region) is loss cost out of line with the risk band --
-- i.e. where might the portfolio be under- or over-priced -- and how much
-- of the book sits in segments with too few claims to price reliably?
--
-- Grain: one row per (bonus_malus_band, vehicle_power_band, region).

with policy_segments as (

    select
        policy_id,
        exposure,
        claim_count_actual,
        total_claim_amount,
        bonus_malus,

        case
            when bonus_malus <= 50  then '50 (best)'
            when bonus_malus <= 70  then '51-70'
            when bonus_malus <= 100 then '71-100'
            when bonus_malus <= 130 then '101-130'
            else '131+ (worst)'
        end as bonus_malus_band,

        case
            when vehicle_power <= 5 then 'low (<=5)'
            when vehicle_power <= 9 then 'mid (6-9)'
            else 'high (10+)'
        end as vehicle_power_band,

        region

    from {{ ref('fct_policy_claims') }}

),

segment_agg as (

    select
        bonus_malus_band,
        vehicle_power_band,
        region,
        count(distinct policy_id)      as policy_count,
        sum(exposure)                   as total_exposure,
        sum(claim_count_actual)         as total_claim_count,
        sum(total_claim_amount)         as total_claim_amount

    from policy_segments
    group by 1, 2, 3

)

select
    bonus_malus_band,
    vehicle_power_band,
    region,
    policy_count,
    total_exposure,
    total_claim_count,
    total_claim_amount,

    -- frequency: claims per unit of exposure (policy-year)
    round((total_claim_count / nullif(total_exposure, 0))::numeric, 4)      as claim_frequency,

    -- severity: average cost per claim
    round((total_claim_amount / nullif(total_claim_count, 0))::numeric, 2) as avg_claim_severity,

    -- loss cost: expected cost per unit of exposure = frequency x severity
    round((total_claim_amount / nullif(total_exposure, 0))::numeric, 2)    as loss_cost_per_exposure,

    -- credibility: segments with fewer than 30 claims are too small to price
    -- off reliably -- the average is mostly noise, not signal
    case
        when total_claim_count < 30 then 'low credibility'
        else 'credible'
    end as credibility_flag

from segment_agg
order by loss_cost_per_exposure desc