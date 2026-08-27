# EcoDelivery S.A.S. — Orders & Analytics System
### FastAPI + Apache Airflow (LocalExecutor) + PostgreSQL + Flutter

End-to-end solution that replaces EcoDelivery's spreadsheet-based order tracking with a
real system: a **REST API** with real persistence, a **daily ETL pipeline** orchestrated
with **Apache Airflow**, and a **Flutter** mobile app that consumes the API. The Power BI
dashboard is under development and consumes the pipeline output.

EcoDelivery is a fictional eco-friendly delivery startup (bikes and electric motorbikes)
operating in five city zones: **Norte, Sur, Centro, Occidente, Chapinero**.

---

## Model Diagram

Single table `pedidos` in the `ecodelivery` database. The ETL derives three metric groups
into `data/reporte_pedidos.csv`.

```
pedidos
├── id_pedido       INTEGER      PK, auto-increment
├── cliente         VARCHAR      NOT NULL
├── zona            VARCHAR      NOT NULL   (Norte|Sur|Centro|Occidente|Chapinero)
├── fecha_creacion  TIMESTAMP    NOT NULL   (set on create, UTC)
├── fecha_entrega   TIMESTAMP    NULL       (set automatically when estado -> entregado)
├── estado          VARCHAR      NOT NULL   (pendiente|en_camino|entregado|cancelado)
├── repartidor      VARCHAR      NULL       (null until assigned)
├── metodo_pago     VARCHAR      NOT NULL   (efectivo|tarjeta|app)
└── monto           NUMERIC(10,2) NOT NULL  (> 0)
```

---

## Current State

The project is operational end to end with this architecture:

- **FastAPI** exposes the 4 required endpoints with field validation and correct HTTP
  codes (`201 / 400 / 404 / 409 / 422`).
- **PostgreSQL 16** provides real persistence. One container hosts two databases:
  `ecodelivery` (app data) and `airflow` (Airflow metadata).
- On startup the API creates its tables and **seeds** `dataset_pedidos_semilla.csv` if the
  table is empty (idempotent).
- **Airflow 2.10.5** with **LocalExecutor** orchestrates `etl_pedidos_diario`
  (`extract >> transform >> load`).
- The ETL reads from the **live API** (`GET /pedidos`) and **falls back to the seed CSV**
  if the API is unreachable.
- Status transitions are enforced server-side (e.g. `cancelado -> entregado` is rejected
  with `409`).
- Optional `X-API-Key` on write endpoints, **shipped disabled** so nothing needs
  configuring to run.
- Everything (except the Flutter app) runs with a single `docker compose up --build`.

---

## Prerequisites

| Tool | Minimum version | Check with |
|---|---|---|
| Docker Desktop | 4.x | `docker --version` |
| Docker Compose | v2.1+ | `docker compose version` |
| Flutter SDK *(only for the mobile app)* | 3.x stable | `flutter --version` |

> Python, FastAPI, Airflow and PostgreSQL are **not** required on the host — they all run
> inside containers. Flutter is only needed to run module 1.

Host ports used: `8000` (API), `8080` (Airflow UI), `5432` (PostgreSQL).

---

## Project Structure

```
Prueba De Empleabilidad/
│
├── docker-compose.yml          # 5 services: postgres, backend, airflow-init, airflow-webserver, airflow-scheduler
├── .env.example                # TEMPLATE: copy to .env (already carries working local values)
├── .gitignore
├── .gitattributes              # forces LF endings (the postgres init script must be LF)
├── README.md
├── dataset_pedidos_semilla.csv # seed data (generated; ~260 rows over ~35 days)
│
├── scripts/
│   ├── generate_seed.py        # regenerates dataset_pedidos_semilla.csv (fixed random seed)
│   └── init-multiple-dbs.sh    # creates the 'ecodelivery' and 'airflow' databases in PostgreSQL
│
├── backend/                    # MODULE 2 — REST API (FastAPI)
│   ├── Dockerfile              # python:3.11-slim + uvicorn
│   ├── requirements.txt        # pinned versions
│   ├── .env.example
│   ├── pytest.ini
│   ├── app/
│   │   ├── config.py           # settings from env vars (DATABASE_URL, API_KEY, SEED_CSV_PATH)
│   │   ├── database.py         # SQLAlchemy engine, session, get_db dependency, Base
│   │   ├── enums.py            # allowed zones/states/payment methods + transition rules
│   │   ├── models.py           # Pedido ORM table
│   │   ├── schemas.py          # Pydantic request/response models + validators
│   │   ├── crud.py             # DB operations (create, list+filters, get, update state)
│   │   ├── security.py         # optional X-API-Key dependency
│   │   ├── seed.py             # loads the seed CSV into the DB if empty
│   │   └── main.py             # FastAPI app, routes, CORS, startup hook
│   └── tests/
│       └── test_pedidos.py     # 10 pytest cases (endpoints, codes, transitions)
│
├── airflow/                    # MODULE 3 — Data pipeline (Airflow)
│   ├── Dockerfile              # apache/airflow:2.10.5-python3.11 + pandas + requests
│   ├── requirements.txt
│   └── dags/
│       └── etl_pedidos_diario.py   # extract >> transform >> load
│
├── app_flutter/                # MODULE 1 — Mobile app (Flutter)
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   ├── .env.example
│   ├── README.md               # per-target run instructions
│   └── lib/
│       ├── main.dart           # providers + login/list routing
│       ├── config.dart         # API base URL from --dart-define
│       ├── session.dart        # in-memory session (username + API key)
│       ├── estado_helpers.dart # status colors, next-status logic, dropdown option lists
│       ├── models/pedido.dart
│       ├── services/api_service.dart   # real GET/POST/PATCH calls
│       ├── state/
│       │   ├── auth_provider.dart      # login / logout
│       │   └── pedidos_provider.dart   # loading / error / loaded states
│       └── screens/
│           ├── login_screen.dart          # username + optional API key
│           ├── pedidos_list_screen.dart   # list + filters + pull-to-refresh + logout
│           ├── pedido_detail_screen.dart  # detail + advance-status button
│           └── crear_pedido_screen.dart   # validated create form
│
├── powerbi/
│   └── README.md               # MODULE 4 — data contract for the dashboard (in development)
│
└── data/                       # shared volume; the ETL writes reporte_pedidos.csv here
    └── .gitkeep
```

---

## Quick Start (Backend + Airflow)

### Step 0 — Get the project

```bash
cd "Prueba De Empleabilidad"
```

### Step 1 — Configure environment

```bash
# Windows PowerShell:
copy .env.example .env

# Mac / Linux:
cp .env.example .env
```

`.env.example` already carries working values for local use (database credentials,
Airflow Fernet key, admin user). Only edit `.env` if you want to change them.

### Step 2 — Bring up the whole environment

```bash
docker compose up --build -d
```

This does everything automatically:

1. Builds the backend image (`python:3.11-slim` + uvicorn) and the Airflow image
   (`apache/airflow:2.10.5-python3.11` + pandas + requests). ~3–5 min the first time.
2. Starts PostgreSQL and creates the `ecodelivery` and `airflow` databases.
3. Runs `airflow-init`: `airflow db migrate` + creates the `admin` UI user.
4. Starts the backend, which creates its tables and seeds `dataset_pedidos_semilla.csv`.
5. Starts the Airflow webserver and scheduler with **LocalExecutor**.

Check the containers:

```bash
docker compose ps
```

Expected:

```
NAME                                        STATUS
pruebadeempleabilidad-postgres-1            Up (healthy)
pruebadeempleabilidad-backend-1             Up (healthy)
pruebadeempleabilidad-airflow-init-1        Exited (0)      <- normal: one-shot init
pruebadeempleabilidad-airflow-webserver-1   Up (healthy)
pruebadeempleabilidad-airflow-scheduler-1   Up
```

| Service | URL | Credentials |
|---|---|---|
| REST API | http://localhost:8000 | — |
| API docs (Swagger) | http://localhost:8000/docs | — |
| Airflow UI | http://localhost:8080 | `admin` / `admin` |

### Step 3 — Run the pipeline

Open **http://localhost:8080**, find the DAG **`etl_pedidos_diario`**, enable it with the
left toggle, and click **▶ Trigger DAG**.

Or from the terminal:

```bash
docker compose exec airflow-scheduler airflow dags test etl_pedidos_diario 2025-01-01
```

(A date argument is required; any past date works because the DAG has no schedule.)

### Step 4 — Validate results

```bash
# API returns seeded orders
curl http://localhost:8000/pedidos

# the ETL produced the report
cat data/reporte_pedidos.csv
```

`data/reporte_pedidos.csv` should contain three metric groups: average delivery time per
zone, order count per status, and total revenue per zone.

---

## Module 2 — REST API

FastAPI app in `backend/app/`. Persistence in PostgreSQL (`ecodelivery` database).

### Endpoints

| Method | Path | Description |
|---|---|---|
| `POST` | `/pedidos` | Creates an order with `estado = pendiente`. Returns `201`. |
| `GET` | `/pedidos` | Lists orders. Optional filters `?estado=` and `?zona=`. |
| `GET` | `/pedidos/{id}` | Order detail. `404` if it does not exist. |
| `PATCH` | `/pedidos/{id}/estado` | Changes status. Validates the transition. Sets `fecha_entrega` when it becomes `entregado`. |
| `GET` | `/health` | Health check used by Docker. |

### Status transitions

```
pendiente  ──▶ en_camino ──▶ entregado   (final)
    │              │
    └────▶ cancelado ◀────┘               (final)
```

Any other transition (for example `cancelado -> entregado`, or `entregado -> anything`)
returns HTTP `409`.

### HTTP codes

| Code | When |
|---|---|
| `201` | order created |
| `200` | successful read / update |
| `400` | invalid `?estado=` or `?zona=` filter value |
| `404` | order id not found |
| `409` | invalid status transition (or same status) |
| `422` | body validation failed (missing field, bad zone/payment method, `monto <= 0`) |

### Try it

```bash
curl "http://localhost:8000/pedidos?estado=entregado&zona=Norte"

curl -X POST http://localhost:8000/pedidos \
  -H "Content-Type: application/json" \
  -d '{"cliente":"Ana Gomez","zona":"Norte","metodo_pago":"efectivo","monto":25000}'

curl -X PATCH http://localhost:8000/pedidos/1/estado \
  -H "Content-Type: application/json" \
  -d '{"estado":"en_camino"}'
```

### Optional API key (assessment "extra")

Write endpoints (`POST`, `PATCH`) accept an `X-API-Key` header. It is **disabled by
default**: with `API_KEY` empty in `.env`, writes are open. To enable it, set
`API_KEY=some-secret` in `.env`, restart, and send `-H "X-API-Key: some-secret"` on writes.

### Run the backend without Docker

```bash
cd backend
python -m venv .venv
source .venv/bin/activate            # Windows: .venv\Scripts\activate
pip install -r requirements.txt
export DATABASE_URL="sqlite:///./ecodelivery.db"
export SEED_CSV_PATH="../dataset_pedidos_semilla.csv"
uvicorn app.main:app --reload
```

### Tests

```bash
cd backend
pip install -r requirements.txt
pytest
```

10 tests cover creation, filters, `404 / 409 / 422`, the transition rules and the
automatic `fecha_entrega`. They use an in-memory SQLite DB — no server needed.

---

## Module 3 — Data Pipeline (Airflow)

DAG `airflow/dags/etl_pedidos_diario.py`. Executor: **LocalExecutor** (runs locally, no
Celery / Redis). Airflow metadata lives in the `airflow` database of the same PostgreSQL
container. Version pinned to **2.10.5** on purpose — the last stable 2.x release; Airflow
3.x is newer and still has configuration rough edges.

### Pipeline flow (DAG)

```
extract
   │  GET http://backend:8000/pedidos
   │  (falls back to /opt/airflow/seed/dataset_pedidos_semilla.csv if the API is down)
   │  writes data/_stage_pedidos.json
   ▼
transform
   │  pandas:
   │   - average delivery time (minutes) per zone      [entregado only]
   │   - order count per status
   │   - total revenue (monto) per zone
   │  writes data/_stage_metricas.csv
   ▼
load
   │  writes data/reporte_pedidos.csv   (the Power BI source)
```

### Output — `data/reporte_pedidos.csv`

Long / tidy format: `metrica, dimension, valor, fecha_reporte`. See `powerbi/README.md`
for the column meaning. Example:

```
metrica,dimension,valor,fecha_reporte
tiempo_promedio_entrega_min,Norte,56.1,2026-08-27
cantidad_pedidos,entregado,168.0,2026-08-27
ingresos_totales,Norte,2991451.85,2026-08-27
```

### Run it

```bash
# UI:  http://localhost:8080  ->  enable  ->  Trigger DAG

# CLI:
docker compose exec airflow-scheduler airflow dags test etl_pedidos_diario 2025-01-01

# check the DAG parses with no import errors:
docker compose exec airflow-scheduler airflow dags list-import-errors
```

---

## Module 4 — Dashboard (Power BI)

Under development. It consumes the pipeline output `data/reporte_pedidos.csv`.
`powerbi/README.md` documents the source file, its columns, and the required visuals /
slicer / DAX measure so the report can be built against a stable data contract.

---

## Module 1 — Mobile App (Flutter)

Full instructions in `app_flutter/README.md`. Short version:

```bash
cd app_flutter
flutter create .        # generates android/ios/web folders the first time
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

`10.0.2.2` is how the Android emulator reaches the host. Use `http://localhost:8000` for
Chrome or the iOS simulator; use `http://<your-pc-ip>:8000` from a physical phone.

Screens: login (username + optional API key), orders list (filter by status/zone, colored
status chip, pull-to-refresh, logout), order detail (advance-status button), create order
(validated form). Every screen calls the API — no hard-coded data.

---

## Seed dataset — `dataset_pedidos_semilla.csv`

No seed file came with the assessment, so one was generated with
`python scripts/generate_seed.py` — fixed random seed, ~260 rows over ~35 days, covering
all zones, statuses and payment methods. It is used by the backend to populate the
database and by the DAG as a fallback source.

---

## Management Commands

```bash
# live logs
docker compose logs -f airflow-scheduler
docker compose logs -f backend

# stop (keeps the database volume)
docker compose down

# full reset (drops the database volume)
docker compose down -v

# rebuild after changing a Dockerfile or requirements.txt
docker compose up --build -d
```

---

## Troubleshooting

**Airflow webserver takes a while on first start** — wait 30–60 s; it is normal.

**`airflow-init` exits with a non-zero code** — check the logs:
`docker compose logs airflow-init`.

**PostgreSQL container exits on first run with `database "..." does not exist`** — the
`scripts/init-multiple-dbs.sh` file must have **LF** line endings. `.gitattributes`
enforces this; if you edited it on Windows, re-save it as LF and run `docker compose down -v`
then `docker compose up`.

**The ETL cannot reach the backend** — it automatically falls back to the seed CSV; the
DAG still succeeds. To force the live path, make sure the `backend` container is `healthy`
(`docker compose ps`).

**Port already in use (8000 / 8080 / 5432)** — stop the process using it or change the
left side of the port mapping in `docker-compose.yml`.

**Rebuild from scratch, no cache:**
```bash
docker compose build --no-cache && docker compose up -d
```

---

## Decisions & Assumptions

- **Backend**: FastAPI (the assessment allows Node or FastAPI; FastAPI was chosen for this
  delivery).
- **Database**: one PostgreSQL container, two databases (`ecodelivery`, `airflow`). Real
  persistence, not an in-memory list; keeps the compose file small.
- **Airflow**: 2.10.5 + LocalExecutor — a stable release, not the newest 3.x line.
- **Flutter app not containerized**: a mobile app does not run usefully in Docker; it is
  delivered as source and run on the host against the dockerized API.
- **Power BI**: under development; it consumes `data/reporte_pedidos.csv` and the data
  contract for it is documented in `powerbi/`.
- **Auth (extra)**: optional `X-API-Key` on writes, shipped disabled. Implemented.
- **Flutter optional extras**: login screen and pull-to-refresh — both implemented.
- **Timestamps** are stored in UTC.
- **Seed data** was generated because none was provided; its schema matches the model.

### Status by module

- Modules 1–3 (Flutter app, REST API, Airflow ETL): complete and running.
- Module 4 (Power BI dashboard): in progress, building on the `reporte_pedidos.csv`
  produced by module 3.
- Flutter platform folders are not committed — `flutter create .` regenerates them.
- No Alembic migrations — tables are created from the SQLAlchemy models on startup, which
  is enough for this scope.
