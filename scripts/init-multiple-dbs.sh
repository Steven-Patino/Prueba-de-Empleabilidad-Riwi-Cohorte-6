#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE ecodelivery;
    CREATE DATABASE airflow;
EOSQL

echo "Bases de datos 'ecodelivery' y 'airflow' creadas"
