#!/usr/bin/env bash
set -e

DSN="postgresql://postgres:${PGPASSWORD:-postgres}@localhost:5439/postgis"
BASE_DATA_DIR="${1:-testdata}"

echo "Migrating pgstac database..."
docker run --rm --network host -v "$PWD/$BASE_DATA_DIR":/data stacutils/pgstac:v0.9.2 \
  pypgstac migrate --dsn "$DSN"

for DIR in "$BASE_DATA_DIR"/*/; do
  echo "Importing testdata from: $DIR"

  # Load STAC catalogs
  echo "Loading STAC catalogs in $DIR..."
  for f in "$DIR"*.json; do
    if grep -q '"type": *"Catalog"' "$f"; then
      docker run --rm --network host -v "$PWD/$BASE_DATA_DIR":/data stacutils/pgstac:v0.9.2 \
        pypgstac load collections "/data/$(basename "$DIR")/$(basename "$f")" --dsn "$DSN" --method upsert
    fi
  done

  # Load STAC collections
  echo "Loading STAC collections in $DIR..."
  for f in "$DIR"*.*json; do
    if grep -q '"type": *"Collection"' "$f"; then
      docker run --rm --network host -v "$PWD/$BASE_DATA_DIR":/data stacutils/pgstac:v0.9.2 \
        pypgstac load collections "/data/$(basename "$DIR")/$(basename "$f")" --dsn "$DSN" --method upsert
    fi
  done

  # Load STAC items
  echo "Loading STAC items in $DIR..."
  for f in "$DIR"*.*json; do
    if grep -q '"type": *"Feature"' "$f"; then
      docker run --rm --network host -v "$PWD/$BASE_DATA_DIR":/data stacutils/pgstac:v0.9.2 \
        pypgstac load items "/data/$(basename "$DIR")/$(basename "$f")" --dsn "$DSN" --method upsert
    fi
  done
done

echo "STAC data loading completed."