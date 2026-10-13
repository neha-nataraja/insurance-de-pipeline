{{ config(severity = 'warn') }}

-- Flag credible adjacent bonus-malus comparisons where the worse band has
-- lower loss cost, using the persisted like-for-like anomaly model.
-- Review these as investigation leads, not definitive pricing conclusions.

select *
from {{ ref('mart_bonus_malus_anomalies') }}
