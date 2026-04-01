# Enterprise Grafana Observability Platform Dashboards

**33 production-ready, executive-grade Grafana dashboards** for the complete LGTM+ observability stack (Loki, Grafana, Tempo, Mimir, Pyroscope). Built for Grafana 11.6.4 with 558 panels covering QoS, SLO compliance, admin operations, ingestion analytics, anomaly detection, and predictive capacity forecasting.

[![Grafana](https://img.shields.io/badge/Grafana-11.6.4-orange?logo=grafana)](https://grafana.com)
[![Dashboards](https://img.shields.io/badge/Dashboards-33-blue)]()
[![Panels](https://img.shields.io/badge/Panels-558-green)]()
[![License](https://img.shields.io/badge/License-MIT-yellow)]()

---

## Dashboard Previews

> **To view live:** Run `docker compose up -d` and open http://localhost:3200 (admin/admin). All 33 dashboards are auto-provisioned.

### C-Suite Executive Dashboards

| Dashboard | Description | Live Link |
|-----------|-------------|-----------|
| **Observability Platform — Executive Summary** | SLO scorecard, 30-day compliance trends, traffic volume, user experience latency | [Open](http://localhost:3200/d/ceo-platform-exec-summary) |
| **SLA & Business Impact Report** | 3-decimal SLA precision, error budget gauge, MTBI, service-level breakdown | [Open](http://localhost:3200/d/sla-business-impact-report) |
| **Risk & Incident Intelligence** | Threat-level indicators, multi-window burn rate, latency risk bands | [Open](http://localhost:3200/d/risk-incident-intelligence) |

### Admin & Operations

| Dashboard | Description | Live Link |
|-----------|-------------|-----------|
| **Admin Command Center** | Instance health, HTTP analytics, DB pool, resources | [Open](http://localhost:3200/d/grafana-admin-command-center) |
| **Service Health Matrix** | Flight-status board for every LGTM component | [Open](http://localhost:3200/d/service-health-matrix) |
| **Anomaly Detection** | Statistical deviation bands, z-score, configurable sigma | [Open](http://localhost:3200/d/anomaly-detection-outliers) |

### Ingestion Analytics

| Dashboard | Description | Live Link |
|-----------|-------------|-----------|
| **Loki Ingestion** | Log volume by namespace/job/tenant, stream cardinality | [Open](http://localhost:3200/d/loki-ingestion-analytics) |
| **Mimir Ingestion** | Samples/series by tenant, distributor health | [Open](http://localhost:3200/d/mimir-ingestion-analytics) |
| **Tempo Ingestion** | Spans by tenant, live traces, compaction | [Open](http://localhost:3200/d/tempo-ingestion-analytics) |
| **Pyroscope Ingestion** | Profiles by service/tenant, active series | [Open](http://localhost:3200/d/pyroscope-ingestion-analytics) |
| **Cross-Signal Volume** | Unified bytes/sec across all signals, WoW growth | [Open](http://localhost:3200/d/cross-signal-volume-analytics) |

### Generating Screenshots

To generate screenshots from your running Grafana instance, the Docker Compose includes a Grafana Image Renderer service. Once Grafana is running with real data, use:

```bash
# Example: render a dashboard to PNG
curl -u admin:admin \
  "http://localhost:3200/render/d/ceo-platform-exec-summary?orgId=1&width=1400&height=900&theme=dark&timeout=120" \
  -o screenshot.png
```

> **Note:** Screenshots require real metrics data flowing through the LGTM stack. With the stub Prometheus included in docker-compose, panels will show "No data" — the dashboard layouts, colors, and structure are still fully visible.

---

## Dashboard Catalog

### QoS Executive Dashboards (01-05)

| # | Dashboard | SLO | Source Metric |
|---|-----------|-----|---------------|
| 01 | Platform UI QoS | 95% ≤ 1.0s | `grafana_http_request_duration_seconds_bucket` |
| 02 | Loki Write QoS | 95% ≤ 0.5s | `loki_write_request_duration_seconds_bucket` |
| 03 | Mimir Write QoS | 95% ≤ 0.5s | `cortex_request_duration_seconds_bucket` |
| 04 | Mimir Read QoS | 95% ≤ 0.5s | `cortex_query_frontend_enqueue_duration_seconds_bucket` |
| 05 | Log Query Experience | 95% ≤ 2.0s | `grafana_http_request_duration_seconds_bucket` (proxy) |

### Deep Dive Operations (06-13)

| # | Dashboard | Focus |
|---|-----------|-------|
| 06 | LGTM Stack Health Overview | Single pane of glass for entire stack |
| 07 | Mimir Deep Dive | Write/read path, compactor, querier, cache |
| 08 | Loki Deep Dive | Distributor, ingester, compactor, index |
| 09 | Tempo Deep Dive | Spans, traces, compaction, block storage |
| 10 | Pyroscope Deep Dive | Profiles, distributor, ingester, compactor |
| 11 | Cross-Stack Capacity Planning | Resource forecasting across all services |
| 12 | Multi-Tenant Analytics | Per-tenant usage, quotas, cardinality |
| 13 | SLO Error Budget Burn Rate | Multi-window burn rate (Google SRE) |

### Grafana Admin (14-16)

| # | Dashboard | Focus |
|---|-----------|-------|
| 14 | Admin Command Center | Instance health, HTTP analytics, DB pool, CPU/memory |
| 15 | Access & Security Analytics | RBAC performance, login security, API patterns |
| 16 | DB & Performance Deep Dive | Connection pool, GC, heap memory, incident correlation |

### C-Suite Premium (17-19)

| # | Dashboard | Audience |
|---|-----------|----------|
| 17 | Observability Platform — Executive Summary | CTO / Board Meetings |
| 18 | SLA & Business Impact Report | CFO / QBR Presentations |
| 19 | Risk & Incident Intelligence | VP Reliability / CTO |

### Ingestion Analytics (20-23)

| # | Dashboard | Drill-Down Variables |
|---|-----------|---------------------|
| 20 | Loki — Log Ingestion & Volume | cluster, namespace, job, tenant |
| 21 | Mimir — Metrics Ingestion & Cardinality | cluster, namespace, tenant |
| 22 | Tempo — Trace Ingestion & Throughput | cluster, namespace, tenant |
| 23 | Pyroscope — Profile Ingestion & Storage | cluster, namespace, tenant, service |

### Advanced Analytics (24-28)

| # | Dashboard | Key Technique |
|---|-----------|--------------|
| 24 | Cross-Signal Volume & Growth | Unified bytes/sec across all signals, WoW comparison |
| 25 | Service Health Matrix | Flight-status board for every LGTM component |
| 26 | Predictive Capacity Forecasting | `predict_linear()`, `deriv()`, days-to-double |
| 27 | User Activity & Audit Analytics | Per-handler API analysis, session tracking, RBAC overhead |
| 28 | Anomaly Detection & Outlier Analysis | `stddev_over_time` bands, z-score, adjustable sigma |

### Admin Error & Operations (29-33)

| # | Dashboard | Component |
|---|-----------|-----------|
| 29 | Loki Admin — Errors, Rejections & Operations | Loki |
| 30 | Mimir Admin — Errors, Rejections & Operations | Mimir |
| 31 | Tempo Admin — Errors, Rejections & Operations | Tempo |
| 32 | Pyroscope Admin — Errors, Rejections & Operations | Pyroscope |
| 33 | Grafana Admin — Errors, Requests & API Health | Grafana |

---

## Quick Start

### Option 1: Docker Compose (Recommended)

```bash
git clone https://github.com/gpadidala/Grafana-Dashbords.git
cd Grafana-Dashbords
docker compose up -d
```

Open **http://localhost:3200** (admin / admin)

All 33 dashboards are auto-provisioned on startup.

### Option 2: Manual Import

1. Open your Grafana instance
2. Go to **Dashboards** > **New** > **Import**
3. Click **Upload JSON file**
4. Select any `.json` file from this repository
5. Choose your Prometheus/Mimir datasource
6. Click **Import**

### Option 3: Grafana Provisioning

Copy the files into your Grafana provisioning directory:

```bash
# Copy dashboards
cp *.json /etc/grafana/provisioning/dashboards/

# Add provisioning config
cat > /etc/grafana/provisioning/dashboards/dashboards.yml << 'EOF'
apiVersion: 1
providers:
  - name: "Enterprise Dashboards"
    orgId: 1
    type: file
    disableDeletion: false
    updateIntervalSeconds: 30
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF
```

---

## User Guide

### Understanding Template Variables

Every dashboard includes dropdown filters at the top. These let you drill down into specific clusters, namespaces, tenants, or services without editing any queries.

| Variable | Used In | Purpose |
|----------|---------|---------|
| `datasource` | All dashboards | Select your Prometheus/Mimir data source |
| `cluster` | Most dashboards | Filter by Kubernetes cluster |
| `namespace` | Most dashboards | Filter by Kubernetes namespace |
| `tenant` | Ingestion dashboards | Filter by Mimir/Loki/Tempo tenant |
| `job` | Loki ingestion | Filter by Prometheus job label |
| `service` | Pyroscope ingestion | Filter by service name |
| `instance` | Grafana admin | Filter by Grafana instance |
| `handler` | Grafana admin | Filter by API handler/route |
| `route` | Admin error dashboards | Filter by component route |
| `slo_period` | SLA report | Select SLO evaluation window (7d/14d/30d/90d) |
| `severity_window` | Risk intelligence | Alert sensitivity window (5m/15m/1h/6h) |
| `sensitivity` | Anomaly detection | Standard deviation threshold (1σ/2σ/3σ) |
| `environment` | CEO summary | Filter by environment (Production/Staging/Dev) |

### Reading the Executive Dashboards (17-19)

These dashboards tell a story from top to bottom:

```
1. HERO STRIP       — Branded header with live status
2. SCORECARD        — 4-6 large KPI stat panels (the headlines)
3. TREND            — 30-day compliance line charts
4. BREAKDOWN        — Per-service or per-cluster bar gauges
5. DETAILS          — Latency percentiles, error rates
6. FOOTER           — Navigation links to related dashboards
```

**Color semantics across all dashboards:**
- **Green** — Healthy, SLO met, budget remaining
- **Amber/Yellow** — Warning, approaching SLO boundary
- **Red** — Critical, SLO breached, action required

### Reading the Admin Error Dashboards (29-33)

Each admin dashboard follows the same structure:

```
Row 0: ERROR OVERVIEW       — 6 stat panels (error %, 5xx/s, 4xx/s, success %, P95)
Row 1: STATUS CODE BREAKDOWN — Stacked timeseries with per-code colors
Row 2: ERROR ROUTES          — Top 10 worst routes (horizontal bar gauges)
Row 3: CLUSTER ANALYSIS      — Per-cluster error rate & volume
Row 4: REJECTIONS            — Discarded samples/spans/profiles by reason
Row 5: REQUEST VOLUME        — Top 15 routes by traffic
Row 6: WRITE/READ PATH       — Path-specific error isolation
Row 7: LATENCY              — P95 by route + percentile distribution
```

**HTTP status code color mapping:**

| Code | Color | Meaning |
|------|-------|---------|
| 400 | Amber | Bad request — check client payload |
| 401 | Orange | Unauthorized — credentials issue |
| 403 | Dark Orange | Forbidden — RBAC/permission issue |
| 404 | Grey | Not found — usually harmless |
| 429 | Red | Rate limited — tenant hitting limits |
| 500 | Dark Red | Internal server error — investigate immediately |
| 502 | Red | Bad gateway — upstream service down |
| 503 | Light Red | Service unavailable — capacity issue |
| 504 | Salmon | Gateway timeout — slow upstream |

### Using Ingestion Analytics (20-23)

These dashboards answer **"who is sending what, and how much?"**

1. Select a **cluster** from the dropdown
2. Narrow to a **namespace** or **tenant**
3. The **Top Producers** bar gauges show your biggest data sources
4. The **Stream/Series Cardinality** panels reveal label explosion issues
5. The **Rejections** section shows what's being dropped and why

### Using Anomaly Detection (28)

1. Set the **Sensitivity** dropdown to control detection threshold:
   - **1σ** — Very sensitive, more alerts
   - **2σ** — Balanced (recommended)
   - **3σ** — Only major anomalies
2. The **Anomaly Status** row shows current-vs-baseline ratios (1.0 = normal)
3. The **Deviation Bands** show the "normal range" — anything outside the band is anomalous
4. The **Outlier Endpoints** bar gauges surface specific API handlers that are behaving abnormally

### Using Predictive Forecasting (26)

1. The **headline stats** show "Days to Double" for each LGTM component
   - **Green (≥90 days)** — No action needed
   - **Yellow (30-90 days)** — Plan capacity expansion
   - **Red (<30 days)** — Urgent capacity action required
2. The **forecast charts** show current trends with dashed prediction lines
3. The **WoW Growth** bar gauge shows weekly growth rates — anything >15% is a red flag

### Dashboard Navigation Map

```
CEO Executive Summary (17)
  ├── Platform UI QoS (01)
  ├── Mimir Write QoS (03)
  ├── Loki Write QoS (02)
  ├── Mimir Read QoS (04)
  └── Log Query Experience (05)

SLA Business Impact (18)
  ├── SLO Error Budget Burn (13)
  └── CEO Executive Summary (17)

Risk Intelligence (19)
  ├── CEO Executive Summary (17)
  ├── SLA Business Impact (18)
  └── Admin Command Center (14)

Admin Command Center (14)
  ├── Access & Security (15)
  └── DB Performance (16)

Cross-Signal Volume (24)
  ├── Loki Ingestion (20)
  ├── Mimir Ingestion (21)
  ├── Tempo Ingestion (22)
  └── Pyroscope Ingestion (23)
```

---

## Validation

Run the included validation suite to verify all dashboards:

```bash
# Against a running Grafana instance
GRAFANA_URL=http://localhost:3200 bash validate-dashboards.sh

# Or directly with Python
python3 validate.py --url http://localhost:3200 --dashboard-dir .
```

The validation suite checks:
- JSON syntax validity (all 33 files)
- Grafana API health
- Datasource provisioning
- Dashboard loading (all 33 UIDs)
- Datasource UID consistency across all panels
- Grafana 11 safety (no range value mappings in stat panels)
- API import capability

---

## Architecture & Design Principles

### Metric Sources

| Component | Metrics Used |
|-----------|-------------|
| **Grafana** | `grafana_http_request_duration_seconds_*`, `grafana_stat_*`, `grafana_database_conn_*`, `grafana_alerting_*`, `grafana_access_evaluation_*` |
| **Mimir** | `cortex_request_duration_seconds_*`, `cortex_ingester_active_series`, `cortex_distributor_received_samples_total`, `cortex_discarded_samples_total`, `cortex_query_frontend_*` |
| **Loki** | `loki_request_duration_seconds_*`, `loki_write_request_duration_seconds_*`, `loki_distributor_bytes_received_total`, `loki_distributor_lines_received_total`, `loki_ingester_memory_streams`, `loki_discarded_samples_total` |
| **Tempo** | `tempo_request_duration_seconds_*`, `tempo_distributor_spans_received_total`, `tempo_ingester_live_traces`, `tempo_discarded_spans_total`, `tempodb_blocklist_*` |
| **Pyroscope** | `pyroscope_request_duration_seconds_*`, `pyroscope_distributor_received_samples_total`, `pyroscope_ingester_active_series`, `pyroscope_discarded_samples_total` |
| **Go Runtime** | `process_cpu_seconds_total`, `process_resident_memory_bytes`, `go_goroutines`, `go_gc_duration_seconds`, `go_memstats_*` |

### Design Rules

- **No invented metrics** — every query uses confirmed, real Prometheus metrics
- **No hardcoded datasource UIDs** — all dashboards use `${datasource}` variable
- **Grafana 11 safe** — no range value mappings in stat panels (known crash trigger)
- **`le` values are strings** — `"0.5"`, `"1.0"`, `"+Inf"` (histogram format)
- **`$__rate_interval`** in timeseries panels for adaptive resolution
- **Division-by-zero protection** — `+ 0.001` on all denominators
- **Schema version 39** — compatible with Grafana 10.x and 11.x

### SLO Methodology

All QoS dashboards follow Google SRE practices:

```
SLO Compliance = rate(bucket{le="threshold"}) / rate(bucket{le="+Inf"}) * 100
Error Budget   = (current_slo - target) / (1 - target) * 100
Burn Rate      = (1 - current_slo) / (1 - target)
```

Multi-window burn rates (5m, 30m, 1h, 6h) detect both fast incidents and slow degradation.

---

## Requirements

- **Grafana** 10.x or 11.x (tested on 11.6.4)
- **Prometheus** or **Mimir** as datasource
- **LGTM Stack** (Loki, Grafana, Tempo, Mimir) with default metric endpoints
- **Pyroscope** (optional — dashboards 10, 23, 32 require it)
- **Docker** (optional — for the included docker-compose setup)

---

## File Structure

```
Grafana-Dashbords/
├── 01-platform-ui-qos-executive.json          # QoS Executive
├── 02-loki-write-qos-executive.json
├── 03-mimir-write-qos-executive.json
├── 04-mimir-read-qos-executive.json
├── 05-log-query-experience-executive.json
├── 06-lgtm-stack-health-overview.json         # Deep Dive Operations
├── 07-mimir-deep-dive.json
├── 08-loki-deep-dive.json
├── 09-tempo-deep-dive.json
├── 10-pyroscope-deep-dive.json
├── 11-cross-stack-capacity-planning.json
├── 12-multi-tenant-analytics.json
├── 13-slo-error-budget-burn.json
├── 14-grafana-admin-command-center.json        # Grafana Admin
├── 15-grafana-access-security-analytics.json
├── 16-grafana-db-performance-deep-dive.json
├── 17-ceo-platform-executive-summary.json      # C-Suite Premium
├── 18-sla-business-impact-report.json
├── 19-risk-incident-intelligence.json
├── 20-loki-ingestion-analytics.json            # Ingestion Analytics
├── 21-mimir-ingestion-analytics.json
├── 22-tempo-ingestion-analytics.json
├── 23-pyroscope-ingestion-analytics.json
├── 24-cross-signal-volume-analytics.json       # Advanced Analytics
├── 25-service-dependency-health-matrix.json
├── 26-predictive-capacity-forecasting.json
├── 27-grafana-user-activity-analytics.json
├── 28-anomaly-detection-outliers.json
├── 29-loki-admin-errors-operations.json        # Admin Error & Operations
├── 30-mimir-admin-errors-operations.json
├── 31-tempo-admin-errors-operations.json
├── 32-pyroscope-admin-errors-operations.json
├── 33-grafana-admin-errors-operations.json
├── docker-compose.yml                          # Infrastructure
├── provisioning/
│   ├── datasources/datasources.yml
│   ├── dashboards/dashboards.yml
│   └── prometheus.yml
├── validate-dashboards.sh                      # Validation
├── validate.py
└── README.md
```

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-dashboard`)
3. Add your dashboard JSON to the root directory
4. Run validation: `python3 validate.py --url http://localhost:3200 --dashboard-dir .`
5. Commit and push
6. Open a Pull Request

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

## Author

**Gopal Padidala** — Platform Engineering

Built with the assistance of Claude (Anthropic) for enterprise observability at scale.
