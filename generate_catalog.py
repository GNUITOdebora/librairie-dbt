from sqlalchemy import create_engine

import json
import sqlalchemy as sa
from datetime import datetime

from urllib.parse import quote_plus

password = quote_plus("Debora@123")

engine = create_engine(
    f"mysql+pymysql://debora:{password}@localhost/librairies"
)


catalog = {
    "metadata": {
        "dbt_schema_version": "https://schemas.getdbt.com/dbt/catalog/v1.json",
        "dbt_version": "1.7.9",
        "generated_at": datetime.now().isoformat(),
        "errors": None
    },
    "nodes": {},
    "sources": {}
}

with engine.connect() as conn:
    # Récupérer toutes les tables et vues du schéma
    tables = conn.execute(sa.text("""
        SELECT table_name, table_type
        FROM information_schema.tables
        WHERE table_schema = 'librairies'
        ORDER BY table_name
    """)).fetchall()

    for table_name, table_type in tables:
        # Récupérer les colonnes de chaque table
        columns = conn.execute(sa.text("""
            SELECT
                column_name,
                ordinal_position,
                data_type,
                is_nullable
            FROM information_schema.columns
            WHERE table_schema = 'librairies'
              AND table_name   = :tname
            ORDER BY ordinal_position
        """), {"tname": table_name}).fetchall()

        col_dict = {}
        for col_name, pos, dtype, nullable in columns:
            col_dict[col_name.lower()] = {
                "type": dtype,
                "index": pos,
                "name": col_name,
                "comment": None
            }

        entry = {
            "unique_id": f"model.librairie_dbt.{table_name}",
            "metadata": {
                "type": "VIEW" if table_type == "VIEW" else "BASE TABLE",
                "schema": "librairies",
                "name": table_name,
                "database": None,
                "comment": None,
                "owner": None
            },
            "columns": col_dict,
            "stats": {}
        }

        # Distinguer sources et modèles dbt
        if table_name.startswith("stg_") or table_name.startswith("mart_"):
            catalog["nodes"][f"model.librairie_dbt.{table_name}"] = entry
        else:
            catalog["sources"][f"source.librairie_dbt.librairies.{table_name}"] = entry

# Écrire dans target/
import os
os.makedirs("target", exist_ok=True)
with open("target/catalog.json", "w") as f:
    json.dump(catalog, f, indent=2)

print("✅ catalog.json généré dans target/")
print(f"   {len(catalog['nodes'])} modèles")
print(f"   {len(catalog['sources'])} sources")
