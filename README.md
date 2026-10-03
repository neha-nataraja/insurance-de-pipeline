# Insurance Data Engineering Pipeline

Built an end-to-end insurance data pipeline using Python, PostgreSQL and dbt, transforming publicly available French motor third-party liability insurance data into tested, business-facing analytical marts, with a Power BI dashboard on top.

## Overview

This project demonstrates a reproducible, modern data engineering workflow applied to real insurance data: raw files are ingested programmatically, loaded into a PostgreSQL warehouse, modeled through a layered dbt architecture (staging → intermediate → marts), validated with automated data-quality tests, and surfaced through a Power BI dashboard answering real business questions.

## Architecture

```text
Public Insurance Data (OpenML / CASdatasets)
        ↓
   Python Ingestion
        ↓
     PostgreSQL
        ↓
        dbt
 ┌──────────────┐
 │   Sources    │
 └──────┬───────┘
        ↓
     Staging
        ↓
   Intermediate
        ↓
      Marts
        ↓
 fct_policy_claims
        ↓
  dbt Tests (5 passing)
        ↓
   Power BI Dashboard
```

## Dataset

**freMTPL2freq** and **freMTPL2sev** — French motor third-party liability insurance data, maintained in the [CASdatasets](https://github.com/dutangc/CASdatasets) project and retrieved programmatically via [OpenML](https://www.openml.org/) (dataset IDs 41214 and 41215).

- `freMTPL2freq`: 678,013 policies — risk characteristics (vehicle power/age, driver age, bonus-malus, region, etc.) and claim counts
- `freMTPL2sev`: 26,639 individual claims — claim amounts, linked to policies via `IDpol`

## Pipeline

1. **Ingestion** (`src/ingestion/download_data.py`) — pulls both datasets programmatically from OpenML; raw data is never committed to the repo, only the script that reproduces it
2. **Loading** (`src/ingestion/load_to_postgres.py`) — loads raw CSVs into PostgreSQL as `raw_fremtpl2freq` and `raw_fremtpl2sev`
3. **Transformation (dbt)**:
   - **Staging** — cleans and renames source columns, casts types (`stg_fremtpl2freq`, `stg_fremtpl2sev`)
   - **Intermediate** — aggregates claim-level data to policy level (`int_policy_claims_agg`)
   - **Marts** — joins policy and claims data into a single analytics-ready fact table (`fct_policy_claims`)
4. **Testing** — 5 dbt tests (`not_null`, `unique`) on primary keys across staging and mart models, all passing
5. **Analytics** — Power BI dashboard connected directly to `fct_policy_claims`

## Business Questions Answered

- Which regions have the highest total claim cost?
- How does claim frequency vary by region?
- What's the total claim exposure across the portfolio?

(See `dashboards/dashboard_screenshot.png` and `dashboards/insurance_dashboard.pbix`)

![Dashboard Screenshot](dashboards/dashboard_screenshot.png)

## Tech Stack

Python · pandas · SQLAlchemy · PostgreSQL · dbt · Power BI · Git/GitHub

## Project Status

- [x] **MVP1** — Data acquisition, PostgreSQL warehouse
- [x] **MVP2** — dbt staging/intermediate/marts, 5 passing tests
- [x] **MVP3** — Power BI dashboard on business metrics

## Data Limitations

This project uses publicly available historical French motor third-party liability insurance data — it does not contain any Deloitte, client, or policyholder data, and is not representative of any real insurer's production scale, data volume, or latency requirements. The dbt layer uses simple `not_null`/`unique` tests appropriate to the dataset's scope; a production pipeline at enterprise scale would require additional tests (referential integrity across source systems, freshness checks, anomaly detection) and orchestration (e.g. Airflow) not yet implemented here.

## Why This Project

I have 4.5 years of enterprise insurance data experience from Deloitte, working with SAP HANA/CDS data models and IFRS17 reporting pipelines. For this portfolio project, I wanted to demonstrate how I'd apply modern data engineering practices — Python, PostgreSQL, dbt, automated testing — to a public insurance dataset, building the kind of layered, tested pipeline I'd bring to a Data Engineer or Analytics Engineer role.

## Reproducing This Project

```bash
git clone https://github.com/neha-nataraja/insurance-de-pipeline.git
cd insurance-de-pipeline
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python src/ingestion/download_data.py
# create a .env file with your own PostgreSQL credentials (see .env format below)
python src/ingestion/load_to_postgres.py
cd insurance_dbt
dbt run
dbt test
```

`.env` format:
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=insurance_pipeline
DB_USER=postgres
DB_PASSWORD=your_password
```
