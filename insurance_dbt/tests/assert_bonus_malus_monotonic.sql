-- tests/assert_bonus_malus_monotonic.sql
--
-- Business-logic test (not a schema test): within the same region and
-- vehicle-power band, a worse bonus-malus band should not have a LOWER
-- loss cost than the adjacent better band. Violations are candidates for
-- investigation, not definitive pricing conclusions.
--
-- Compare only segments with at least 30 claims (credible segments).
-- Warning severity surfaces anomalies without failing the entire build.

{{ config(severity = 'warn') }}

with ranked as (

    select
        region,
        vehicle_power_band,
        bonus_malus_band,
        loss_cost_per_exposure,
        credibility_flag,

        -- bonus_malus_band is a text label, so rank it explicitly by risk
        -- order rather than comparing band labels alphabetically.
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
    r1.bonus_malus_band       as better_band,
    r1.loss_cost_per_exposure as better_band_loss_cost,
    r2.bonus_malus_band       as worse_band,
    r2.loss_cost_per_exposure as worse_band_loss_cost
from ranked r1
join ranked r2
    on r1.region = r2.region
    and r1.vehicle_power_band = r2.vehicle_power_band
    and r2.band_rank = r1.band_rank + 1
    and r2.loss_cost_per_exposure < r1.loss_cost_per_exposure
