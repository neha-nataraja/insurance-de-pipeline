# Insurance Data Engineering Pipeline

End-to-end insurance data pipeline — Python, PostgreSQL and dbt — transforming public French motor insurance data into tested, business-facing analytical marts, with a Power BI dashboard on top.

## Architecture

```text
Public Insurance Data (OpenML/CASdatasets)
   ↓ Python ingestion
PostgreSQL
   ↓ dbt
Staging → Intermediate → Marts (fct_policy_claims)
   ↓ 5 passing tests
Power BI Dashboard
```

## Dataset

`freMTPL2freq` (678,013 policies) and `freMTPL2sev` (26,639 claims) — French motor third-party liability insurance data, from [CASdatasets](https://github.com/dutangc/CASdatasets), retrieved via OpenML (IDs 41214/41215).

## Pipeline

1. **Ingestion** — `download_data.py` pulls both datasets from OpenML
2. **Loading** — `load_to_postgres.py` loads raw data into PostgreSQL
3. **dbt** — staging (clean/rename/cast) → intermediate (aggregate claims to policy level) → marts (`fct_policy_claims`, the analytics-ready fact table)
4. **Testing** — `not_null`/`unique` tests on primary keys, 5/5 passing
5. **Analytics** — Power BI dashboard on `fct_policy_claims`

## Dashboard

Answers: which regions have the highest claim cost and frequency, and total portfolio exposure.

![Dashboard Screenshot](dashboards/dashboard_screenshot.png)

## Tech Stack

Python · pandas · SQLAlchemy · PostgreSQL · dbt · Power BI · Git

## Status

- [x] MVP1 — Ingestion & PostgreSQL
- [x] MVP2 — dbt staging/intermediate/marts, tested
- [x] MVP3 — Power BI dashboard

## Limitations

Uses a public, synthetic-realistic dataset — no Deloitte or client data, and not representative of enterprise production scale. Tests are basic (`not_null`/`unique`); a production pipeline would add referential integrity, freshness checks, and orchestration (e.g. Airflow).

## Why This Project

Four years of enterprise insurance data experience at Deloitte (SAP HANA/CDS, IFRS17 reporting). Built this to demonstrate the same rigor applied with modern DE tooling — Python, PostgreSQL, dbt, automated testing — on a public dataset.

## Reproducing

```bash
git clone https://github.com/neha-nataraja/insurance-de-pipeline.git
cd insurance-de-pipeline
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python src/ingestion/download_data.py
# create .env with your own PostgreSQL credentials
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