"""
load_to_postgres.py

What this file does, in plain words:
  1. Reads the .env file to get your database password (so it's never
     typed directly into this script, which is good practice — this
     script is safe to show in interviews or push to GitHub)
  2. Opens the two CSV files you already downloaded
  3. Writes them into PostgreSQL as two tables

Run this AFTER download_data.py has already created the CSVs in data/raw/.
"""

import os
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL
from dotenv import load_dotenv

# -----------------------------------------------------------------
# STEP 1: load the secrets from .env
# -----------------------------------------------------------------
load_dotenv()

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

# -----------------------------------------------------------------
# STEP 2: build the connection safely using URL.create()
# (This handles special characters like @ : / in your password
#  correctly, instead of just pasting text together, which breaks
#  if your password has symbols in it.)
# -----------------------------------------------------------------
print("Connecting to PostgreSQL...")

url = URL.create(
    drivername="postgresql+psycopg2",
    username=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=int(DB_PORT),
    database=DB_NAME,
)

engine = create_engine(url)

# -----------------------------------------------------------------
# STEP 3: read the two CSVs from data/raw/
# -----------------------------------------------------------------
print("Reading CSV files...")

freq_df = pd.read_csv("data/raw/freMTPL2freq.csv")
sev_df = pd.read_csv("data/raw/freMTPL2sev.csv")

print(f"  freMTPL2freq: {freq_df.shape[0]} rows, {freq_df.shape[1]} columns")
print(f"  freMTPL2sev:  {sev_df.shape[0]} rows, {sev_df.shape[1]} columns")

# -----------------------------------------------------------------
# STEP 4: write each one into PostgreSQL as a table
#
# if_exists="replace" means: if you run this script again later,
# it will wipe and rebuild the tables rather than erroring out.
# That's intentional — it keeps this script safely re-runnable.
# -----------------------------------------------------------------
print("Writing freMTPL2freq -> table 'raw_fremtpl2freq'...")
freq_df.to_sql("raw_fremtpl2freq", engine, if_exists="replace", index=False)

print("Writing freMTPL2sev -> table 'raw_fremtpl2sev'...")
sev_df.to_sql("raw_fremtpl2sev", engine, if_exists="replace", index=False)

print("\nDone! Both tables are now in PostgreSQL.")
print("You can check them in pgAdmin under:")
print("  Servers > PostgreSQL 18 > Databases > insurance_pipeline > Schemas > public > Tables")