#!/bin/bash

# exit when any command fails
set -e

# download files, convert to SQLite and export to CSV

DATA_DIR=${DATA_DIR:-"./data"}

mkdir -p "$DATA_DIR" || true

echo "-- Working in $(dirname "$0")"
cd "$(dirname "$0")" || exit

echo "-- Download datasets"

# install sqlite3 if not exists
if ! command -v sqlite3 &> /dev/null
then
    echo "sqlite3 could not be found"
    apt-get update -y
    apt-get install -y sqlite3
fi
# install wget if not exists
if ! command -v wget &> /dev/null
then
    echo "wget could not be found"
    apt-get update -y
    apt-get install -y wget
fi
# install unzip if not exists
if ! command -v unzip &> /dev/null
then
    echo "unzip could not be found"
    apt-get update -y
    apt-get install -y unzip
fi

for d in $(seq -w 1 19) 2A 2B $(seq 21 74) $(seq 76 95) 98 ""; do
  wget --progress=bar:force:noscroll -q --show-progress "https://files.data.gouv.fr/geo-sirene/last/dep/geo_siret_$d.csv.gz" --directory-prefix="$DATA_DIR"
  gunzip "${DATA_DIR}/geo_siret_$d.csv.gz"
done

#Cas particulier Paris
for d in $(seq -w 1 20); do
  wget --progress=bar:force:noscroll -q --show-progress "https://files.data.gouv.fr/geo-sirene/last/dep/geo_siret_751$d.csv.gz" --directory-prefix="$DATA_DIR"
  gunzip "${DATA_DIR}/geo_siret_751$d.csv.gz"
done

#Cas particulier DOM
for d in $(seq -w 1 8); do
  wget --progress=bar:force:noscroll -q --show-progress "https://files.data.gouv.fr/geo-sirene/last/dep/geo_siret_97$d.csv.gz" --directory-prefix="$DATA_DIR"
  gunzip "${DATA_DIR}/geo_siret_97$d.csv.gz"
done

# SIRET data
wget --progress=bar:force:noscroll -q --show-progress https://files.data.gouv.fr/insee-sirene/StockUniteLegale_utf8.zip --directory-prefix="$DATA_DIR"
unzip "${DATA_DIR}/StockUniteLegale_utf8.zip" -d "${DATA_DIR}"

# WEEZ data
wget --progress=bar:force:noscroll -q --show-progress https://www.data.gouv.fr/fr/datasets/r/a785345a-6e8c-4961-ae0a-bc00878e4f2e -O "${DATA_DIR}/WEEZ.csv"

echo "-- Import CSV datasets to sqlite"

sqlite3 -echo "${DATA_DIR}/db.sqlite" ".read import.sql"

echo "-- Export sqlite data to CSV"

sqlite3 -header -csv "${DATA_DIR}/db.sqlite" ".read export.sql" > "${DATA_DIR}/output.csv"