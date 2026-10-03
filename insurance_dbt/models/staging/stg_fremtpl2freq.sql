select
    cast("IDpol" as bigint) as policy_id,
    "ClaimNb" as claim_count,
    "Exposure" as exposure,
    "Area" as area,
    "VehPower" as vehicle_power,
    "VehAge" as vehicle_age,
    "DrivAge" as driver_age,
    "BonusMalus" as bonus_malus,
    "VehBrand" as vehicle_brand,
    "VehGas" as vehicle_fuel_type,
    "Density" as density,
    "Region" as region
from {{ source('raw', 'raw_fremtpl2freq') }}