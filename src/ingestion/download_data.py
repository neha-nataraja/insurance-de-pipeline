"""
download_data.py

What this file does, in plain words:
  1. Connects to a website called OpenML (it's free, no login needed)
  2. Downloads two insurance datasets
  3. Saves them as two CSV files on your computer, inside data/raw/

You only need to run this ONE TIME. After that, the CSV files are
sitting on your laptop and you don't need the internet for them again.
"""

import openml
import pandas as pd
import os

# -----------------------------------------------------------------
# STEP 1: make sure the folder "data/raw" exists
# (if it already exists, this line just does nothing — it won't error)
# -----------------------------------------------------------------
os.makedirs("data/raw", exist_ok=True)


# -----------------------------------------------------------------
# STEP 2: download freMTPL2freq
# This dataset = one row per insurance POLICY
# (who the driver is, what car, how many claims they made)
# -----------------------------------------------------------------
print("Downloading freMTPL2freq (policy-level data)...")

freq_dataset = openml.datasets.get_dataset(41214)   # 41214 = freMTPL2freq's ID on OpenML
freq_df, *_ = freq_dataset.get_data()               # turns it into a normal pandas table

freq_df.to_csv("data/raw/freMTPL2freq.csv", index=False)

print(f"  Saved. Shape: {freq_df.shape[0]} rows, {freq_df.shape[1]} columns")


# -----------------------------------------------------------------
# STEP 3: download freMTPL2sev
# This dataset = one row per CLAIM
# (how much money was paid out for a specific claim)
# -----------------------------------------------------------------
print("Downloading freMTPL2sev (claim-level data)...")

sev_dataset = openml.datasets.get_dataset(41215)    # 41215 = freMTPL2sev's ID on OpenML
sev_df, *_ = sev_dataset.get_data()

sev_df.to_csv("data/raw/freMTPL2sev.csv", index=False)

print(f"  Saved. Shape: {sev_df.shape[0]} rows, {sev_df.shape[1]} columns")


# -----------------------------------------------------------------
# STEP 4: quick peek, so you can see it worked
# -----------------------------------------------------------------
print("\n--- freMTPL2freq preview ---")
print(freq_df.head())

print("\n--- freMTPL2sev preview ---")
print(sev_df.head())

print("\nDone! Check the data/raw/ folder — you should see 2 new CSV files.")