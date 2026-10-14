from pathlib import Path
from urllib.parse import quote_plus

import pandas as pd
from sqlalchemy import create_engine

# --- CHANGE THESE TWO ---
SERVER = r"DESKTOP-IR19VI5\SQLEXPRESS"                      # e.g. r".\SQLEXPRESS" or r"DESKTOP-XXXX\SQLEXPRESS"
DRIVER = "ODBC Driver 17 for SQL Server"   # use whichever version Step 3 showed
# ------------------------

conn_str = (
    f"DRIVER={{{DRIVER}}};SERVER={SERVER};DATABASE=olist;"
    "Trusted_Connection=yes;TrustServerCertificate=yes;"
)
engine = create_engine(
    "mssql+pyodbc:///?odbc_connect=" + quote_plus(conn_str),
    fast_executemany=True,
)

DATA = Path(__file__).resolve().parent.parent / "data"

files = {
    "customers": "olist_customers_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "product_category_name_translation": "product_category_name_translation.csv",
}

date_cols = [
    "order_purchase_timestamp", "order_approved_at",
    "order_delivered_carrier_date", "order_delivered_customer_date",
    "order_estimated_delivery_date",
]

for table, f in files.items():
    df = pd.read_csv(DATA / f)
    if table == "orders":
        for c in date_cols:
            df[c] = pd.to_datetime(df[c])
    df.to_sql(table, engine, if_exists="replace", index=False, chunksize=10000)
    print(table, len(df))