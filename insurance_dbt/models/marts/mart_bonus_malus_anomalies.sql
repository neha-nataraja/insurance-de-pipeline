-- Persist credible adjacent bonus-malus comparisons where the observed
-- loss cost is lower in the worse band, holding region and vehicle-power
-- band constant. These are investigation leads, not pricing conclusions.

with ranked as (
    select
        region,
        vehicle_power_band,
        bonus_malus_band,
        loss_cost_per_exposure,
        credibility_flag,
        case bonus_malus_band
            when '50 (best)'    then 1
            when '51-70'        then 2
            when '71-100'       then 3
            when '101-130'      then 4
            when '131+ (worst)' then 5
        end as band_rank
    from {{ ref('mart_risk_segment_loss_cost') }}
    where credibility_flag = 'credible'
)

select
    r1.region,
    r1.vehicle_power_band,
    r1.bonus_malus_band as better_band,
    r1.loss_cost_per_exposure as better_band_loss_cost,
    r2.bonus_malus_band as worse_band,
    r2.loss_cost_per_exposure as worse_band_loss_cost,
    round(
        (r1.loss_cost_per_exposure - r2.loss_cost_per_exposure)::numeric,
        2
    ) as loss_cost_decline,
    round(
        (
            100.0 * (r1.loss_cost_per_exposure - r2.loss_cost_per_exposure)
            / nullif(r1.loss_cost_per_exposure, 0)
        )::numeric,
        2
    ) as loss_cost_decline_pct
from ranked r1
join ranked r2
    on r1.region = r2.region
    and r1.vehicle_power_band = r2.vehicle_power_band
    and r2.band_rank = r1.band_rank + 1
    and r2.loss_cost_per_exposure < r1.loss_cost_per_exposure
