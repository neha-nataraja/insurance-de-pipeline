# \# Insurance Data Engineering Pipeline

# 

# Built an end-to-end insurance data pipeline using Python, PostgreSQL and dbt, transforming publicly available French motor third-party liability insurance data into tested, business-facing analytical marts, with a Power BI dashboard on top.

# 

# \## Overview

# 

# This project demonstrates a reproducible, modern data engineering workflow applied to real insurance data: raw files are ingested programmatically, loaded into a PostgreSQL warehouse, modeled through a layered dbt architecture (staging → intermediate → marts), validated with automated data-quality tests, and surfaced through a Power BI dashboard answering real business questions.

# 

# \## Architecture

# 

# ```text

# Public Insurance Data (OpenML / CASdatasets)

# &#x20;       ↓

# &#x20;  Python Ingestion

# &#x20;       ↓

# &#x20;    PostgreSQL

# &#x20;       ↓

# &#x20;       dbt

# &#x20;┌──────────────┐

# &#x20;│   Sources    │

# &#x20;└──────┬───────┘

# &#x20;       ↓

# &#x20;    Staging

# &#x20;       ↓

# &#x20;  Intermediate

# &#x20;       ↓

# &#x20;     Marts

# &#x20;       ↓

# &#x20;fct\_policy\_claims

# &#x20;       ↓

# &#x20; dbt Tests (5 passing)

# &#x20;       ↓

# &#x20;  Power BI Dashboard

# ```

# 

# \## Dataset

# 

# \*\*freMTPL2freq\*\* and \*\*freMTPL2sev\*\* — French motor third-party liability insurance data, maintained in the \[CASdatasets](https://github.com/dutangc/CASdatasets) project and retrieved programmatically via \[OpenML](https://www.openml.org/) (dataset IDs 41214 and 41215).

# 

# \- `freMTPL2freq`: 678,013 policies — risk characteristics (vehicle power/age, driver age, bonus-malus, region, etc.) and claim counts

# \- `freMTPL2sev`: 26,639 individual claims — claim amounts, linked to policies via `IDpol`

# 

# \## Pipeline

# 

# 1\. \*\*Ingestion\*\* (`src/ingestion/download\_data.py`) — pulls both datasets programmatically from OpenML; raw data is never committed to the repo, only the script that reproduces it

# 2\. \*\*Loading\*\* (`src/ingestion/load\_to\_postgres.py`) — loads raw CSVs into PostgreSQL as `raw\_fremtpl2freq` and `raw\_fremtpl2sev`

# 3\. \*\*Transformation (dbt)\*\*:

# &#x20;  - \*\*Staging\*\* — cleans and renames source columns, casts types (`stg\_fremtpl2freq`, `stg\_fremtpl2sev`)

# &#x20;  - \*\*Intermediate\*\* — aggregates claim-level data to policy level (`int\_policy\_claims\_agg`)

# &#x20;  - \*\*Marts\*\* — joins policy and claims data into a single analytics-ready fact table (`fct\_policy\_claims`)

# 4\. \*\*Testing\*\* — 5 dbt tests (`not\_null`, `unique`) on primary keys across staging and mart models, all passing

# 5\. \*\*Analytics\*\* — Power BI dashboard connected directly to `fct\_policy\_claims`

# 

# \## Business Questions Answered

# 

# \- Which regions have the highest total claim cost?

# \- How does claim frequency vary by region?

# \- What's the total claim exposure across the portfolio?

# 

# (See `dashboards/dashboard\_screenshot.png` and `dashboards/insurance\_dashboard.pbix`)

# 

# !\[Dashboard Screenshot](dashboards/dashboard\_screenshot.png)

# 

# \## Tech Stack

# 

# Python · pandas · SQLAlchemy · PostgreSQL · dbt · Power BI · Git/GitHub

# 

# \## Project Status

# 

# \- \[x] \*\*MVP1\*\* — Data acquisition, PostgreSQL warehouse

# \- \[x] \*\*MVP2\*\* — dbt staging/intermediate/marts, 5 passing tests

# \- \[x] \*\*MVP3\*\* — Power BI dashboard on business metrics

# 

# \## Data Limitations

# 

# This project uses a public, synthetic-realistic dataset of historical French motor insurance policies — it does not contain any Deloitte, client, or policyholder data, and is not representative of any real insurer's production scale, data volume, or latency requirements. The dbt layer uses simple `not\_null`/`unique` tests appropriate to the dataset's scope; a production pipeline at enterprise scale would require additional tests (referential integrity across source systems, freshness checks, anomaly detection) and orchestration (e.g. Airflow) not yet implemented here.

# 

# \## Why This Project

# 

# I have four years of enterprise insurance data experience from Deloitte, working with SAP HANA/CDS data models and IFRS17 reporting pipelines. For this portfolio project, I wanted to demonstrate how I'd apply modern data engineering practices — Python, PostgreSQL, dbt, automated testing — to a public insurance dataset, building the kind of layered, tested pipeline I'd bring to a Data Engineer or Analytics Engineer role.

# 

# \## Reproducing This Project

# 

# ```bash

# git clone https://github.com/neha-nataraja/insurance-de-pipeline.git

# cd insurance-de-pipeline

# python -m venv .venv

# .venv\\Scripts\\activate

# pip install -r requirements.txt

# python src/ingestion/download\_data.py

# \# create a .env file with your own PostgreSQL credentials (see .env format below)

# python src/ingestion/load\_to\_postgres.py

# cd insurance\_dbt

# dbt run

# dbt test

# ```

# 

# `.env` format:

# ```

# DB\_HOST=localhost

# DB\_PORT=5432

# DB\_NAME=insurance\_pipeline

# DB\_USER=postgres

# DB\_PASSWORD=your\_password

# ```

