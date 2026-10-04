-- tests/assert_bonus_malus_monotonic.sql
--
-- Business-logic test (not a schema test): bonus-malus is supposed to
-- track risk monotonically -- a worse bonus-malus band should never show a
-- LOWER loss cost than the next-better band in the same region. If it
-- does, that segment is a candidate for re-pricing.
--
-- severity: warn -- the point is to surface anomalies for review, not to
-- hard-fail the build on a legitimate finding.

{{ config(severity = 'warn') }}

with ranked as (

    select
        region,
        bonus_malus_band,
        loss_cost_per_exposure,
        credibility_flag,

        -- bonus_malus_band is a text label ('50 (best)', '131+ (worst)', ...)
        -- so it must be ranked explicitly in risk order, not alphabetically
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
    r1.bonus_malus_band       as better_band,
    r1.loss_cost_per_exposure as better_band_loss_cost,
    r2.bonus_malus_band       as worse_band,
    r2.loss_cost_per_exposure as worse_band_loss_cost
from ranked r1
join ranked r2
    on r1.region = r2.region
    and r2.band_rank = r1.band_rank + 1
    and r2.loss_cost_per_exposure < r1.loss_cost_per_exposure