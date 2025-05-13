#!/usr/bin/env bash
set -e

DSN="postgresql://postgres:${PGPASSWORD:-postgres}@127.0.0.1:5439/postgis"
BASE_DATA_DIR="${1:-testdata}"

# echo "Migrating pgstac database..."
# pypgstac migrate --dsn "$DSN"

for DIR in "$BASE_DATA_DIR"/*/; do
  echo "Importing testdata from: $DIR"

  # Load STAC catalogs
  echo "Loading STAC catalogs in $DIR..."
  for f in "$DIR"*.*json; do
    if grep -q '"type": *"Catalog"' "$f"; then
      pypgstac load collections "$f" --dsn "$DSN" --method upsert
    fi
  done

  # Load STAC collections
  echo "Loading STAC collections in $DIR..."
  for f in "$DIR"*.*json; do
    if grep -q '"type": *"Collection"' "$f"; then
      pypgstac load collections "$f" --dsn "$DSN" --method upsert
    fi
  done

  # Load STAC items
  echo "Loading STAC items in $DIR..."
  for f in "$DIR"*.*json; do
    if grep -q '"type": *"Feature"' "$f"; then
      pypgstac load items "$f" --dsn "$DSN" --method upsert
    fi
  done
done

echo "STAC data loading completed."