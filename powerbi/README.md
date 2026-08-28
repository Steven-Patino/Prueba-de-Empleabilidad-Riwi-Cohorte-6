# Power BI dashboard

Built as a **PBIP project** (`Dashboard.pbip` + `Dashboard.Report/` + `Dashboard.SemanticModel/`).
The semantic model and the report page were authored programmatically (Power BI Modeling
MCP + `powerbi-report-author` CLI) and validated with `powerbi-report-author validate`
(0 errors, 0 warnings).

## Data sources (loaded into the model)

| Model table | Source file | Grain |
|---|---|---|
| `pedidos` | `../dataset_pedidos_semilla.csv` | one row per order (+ calc columns `Fecha`, `minutos_entrega`) |
| `reporte_pedidos` | `../data/reporte_pedidos.csv` (Airflow output) | long format `metrica / dimension / valor / fecha_reporte` |

Both are imported with Power Query using `en-US` culture so decimals parse correctly on a
Spanish locale.

## DAX measures (created, not auto-aggregations)

On `pedidos`: `Ingreso Total`, `Pedidos`, `Ticket Promedio`, `Pedidos Entregados`,
`% Entregados`, `Pedidos Cancelados`, `% Cancelados`, `Ingreso Neto sin Cancelados`,
`Tiempo Promedio Entrega (min)`.
On `reporte_pedidos`: `Ingresos (pipeline)`, `Cantidad Pedidos (pipeline)`,
`Tiempo Prom Entrega pipeline (min)`.

## Report page — "Operación EcoDelivery" (1280×720)

| Visual | Type | Binding |
|---|---|---|
| Title | textbox | "EcoDelivery — Operación de Pedidos" |
| KPI row | `cardVisual` (multi-value) | `Ingreso Total`, `Ticket Promedio`, `% Entregados`, `Tiempo Promedio Entrega (min)` |
| Zona filter | `slicer` (dropdown) | `pedidos[zona]` |
| Ingresos por zona | `columnChart` | axis `pedidos[zona]`, value `[Ingreso Total]`, sorted desc |
| Pedidos por día | `lineChart` | axis `pedidos[Fecha]`, value `[Pedidos]` |
| Pedidos por estado | `columnChart` | axis `pedidos[estado]`, value `[Pedidos]`, sorted desc |
| Tiempo prom. entrega por zona | `barChart` | axis `pedidos[zona]`, value `[Tiempo Promedio Entrega (min)]`, sorted desc |

Covers the assessment minimums: ≥3 visuals (bar + line + more), a KPI card, ≥1 slicer,
and custom DAX measures.

## How to open

Open `Dashboard.pbip` in Power BI Desktop. If the canvas looks empty on first open, use
Refresh or reopen the file. Save (`Ctrl+S`) to keep the layout; export a `.pbix` from
Desktop if a single-file deliverable is also wanted.
