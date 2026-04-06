# Grafana Enterprise Dashboard Suite

**57 production-ready dashboards | 991 panels | 11 folders | Grafana 11.6.4**

The most comprehensive open-source Grafana dashboard collection for the LGTM+ observability stack (Loki, Grafana, Tempo, Mimir, Pyroscope). From C-suite executive summaries to deep-dive SRE troubleshooting — every dashboard you need, production-ready.

[![Grafana](https://img.shields.io/badge/Grafana-11.6.4-F46800?logo=grafana&logoColor=white)](https://grafana.com)
[![Dashboards](https://img.shields.io/badge/Dashboards-57-blue)](.)
[![Panels](https://img.shields.io/badge/Panels-991-green)](.)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)
[![MCP](https://img.shields.io/badge/MCP-Grafana_v0.11.4-purple)](https://github.com/grafana/mcp-grafana)

---

## Quick Start
## Dashboard Previews

> **To view live:** 
> - **Docker:** Run `docker compose up -d` and open http://localhost:3200 (admin/admin)
> - **Podman (Windows):** Run `.\Start-Grafana-TLS-Fix.ps1` and open http://localhost:3200 (admin/admin)
> - **Podman (Alternative):** Run `.\start-podman-dashboards-alt.bat` 
> 
> All 33 dashboards are auto-provisioned and organized into folders:
> - 📁 **Grafana** - Admin and operational dashboards
> - 📁 **Loki** - Log analytics dashboards  
> - 📁 **Mimir** - Metrics storage dashboards
> - 📁 **Tempo** - Distributed tracing dashboards
> - 📁 **Pyroscope** - Continuous profiling dashboards
> - 📁 **Platform & Executive** - Executive summary dashboards

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

Both Docker and Podman setups include a Grafana Image Renderer service for generating dashboard screenshots. Once Grafana is running with real data:

**Docker/Podman (Linux):**
```bash
# Clone and run — dashboards auto-provision
git clone https://github.com/gpadidala/Grafana-Dashbords.git
cd Grafana-Dashbords
docker compose up -d

# Open Grafana
open http://localhost:3200    # admin / admin
```

All 57 dashboards appear in organized folders. No manual import needed.

---

## Demo

### Home Page
> Clean, search-first landing page. Press `Cmd+K` to search everything.

| Home | Your starred dashboards + Firing alerts |
|------|----------------------------------------|
| Centered search prompt | Native `dashlist` + `alertlist` panels |

### L0 Executive Command Center
> Single pane of glass for leadership. Every metric links to its drill-down.

### Platform KPI
> The one dashboard a CTO opens at 8am. 5-second read.

| Component Health | SLO Strip | Error Budget | Request Volume |
|-----------------|-----------|-------------|----------------|
| Grafana/Mimir/Loki/Tempo/Pyroscope | UI/Write/Read/Query SLOs | 30-day remaining % | Stacked by component |

### Anomaly Detection
> Statistical deviation bands with adjustable sigma sensitivity.

### User Journey
> Enter a user email → see their complete journey across 5 signals.
**Podman (Windows PowerShell):**
```powershell
# Example: render a dashboard to PNG
Invoke-WebRequest -Uri "http://localhost:3200/render/d/ceo-platform-exec-summary?orgId=1&width=1400&height=900&theme=dark&timeout=120" -Credential (New-Object System.Management.Automation.PSCredential("admin", (ConvertTo-SecureString "admin" -AsPlainText -Force))) -OutFile "screenshot.png"
```

**Available Render Endpoints:**
- Grafana UI: http://localhost:3200
- Renderer Service: http://localhost:8081
- Prometheus: http://localhost:9090

> **Note:** Screenshots require real metrics data flowing through the LGTM stack. With the stub Prometheus included, panels will show "No data" — the dashboard layouts, colors, and structure are still fully visible.

---

## Dashboard Catalog

### Dashboard Hierarchy (L0 → L3)

Dashboards follow a **drill-down hierarchy** — click any metric to go deeper:

```
L0 Executive ──→ L1 Domain ──→ L2 Service ──→ L3 Deep Dive
   (1 dashboard)    (3)           (1)            (4)
```

| Level | Dashboard | Panels | Purpose |
|-------|-----------|--------|---------|
| **L0** | Executive Command Center | 22 | C-suite overview, links to all L1s |
| **L1** | Infrastructure Overview | 21 | K8s clusters, nodes, resources |
| **L1** | Application Performance | 21 | Service RED metrics, SLOs |
| **L1** | Profiling Overview | 15 | CPU/memory profiles across services |
| **L2** | Service Golden Signals | 24 | Per-service rate, errors, duration, saturation |
| **L3** | Trace Explorer | 16 | Distributed tracing deep dive |
| **L3** | Log Explorer | 12 | LogQL query workbench |
| **L3** | Profile Explorer | 11 | Flamegraph analysis |
| **L3** | Kubernetes Debug | 18 | Pod/container troubleshooting |

### Platform & Executive (13 dashboards)

| Dashboard | Panels | Key Feature |
|-----------|--------|-------------|
| **Home Page** | 3 | Search-first, starred dashboards, firing alerts |
| **Platform KPI** | 21 | Big Five component health, SLO strip, error budget |
| **CEO Executive Summary** | 20 | SLO scorecard, 30d compliance trend |
| **SLA Business Impact** | 12 | 3-decimal SLA, error budget gauge, MTBI |
| **Risk & Incident Intelligence** | 13 | Burn rate (5m/1h/6h), latency risk bands |
| **Service Health Matrix** | 16 | Flight-status board for all LGTM components |
| **Anomaly Detection** | 16 | stddev bands, z-score, configurable sigma |
| **Predictive Forecasting** | 10 | predict_linear(), days-to-double |
| **SLO Error Budget Burn** | 19 | Multi-window burn rate (Google SRE) |
| **Cross-Signal Volume** | 19 | Unified bytes/sec, WoW growth comparison |
| **Cross-Stack Capacity** | 11 | Resource forecasting across services |
| **Multi-Tenant Analytics** | 10 | Per-tenant usage, quotas, cardinality |
| **LGTM Stack Health** | 16 | Single pane of glass for entire stack |

### Grafana Admin (6 dashboards)

| Dashboard | Panels | Key Feature |
|-----------|--------|-------------|
| **Command Center** | 29 | HTTP analytics, DB pool, CPU/memory, goroutines |
| **Access & Security** | 13 | RBAC performance, login security, API patterns |
| **DB & Performance** | 13 | Connection pool, GC, heap, incident correlation |
| **User Activity** | 32 | Per-handler API analysis, session tracking |
| **Errors & API Health** | 30 | 4xx/5xx by handler, auth errors, proxy errors |
| **Platform UI QoS** | 15 | SLO: 95% of UI requests within 1.0s |

### Loki (5 dashboards)

| Dashboard | Panels | Key Feature |
|-----------|--------|-------------|
| **Write QoS** | 15 | SLO: 95% writes within 0.5s |
| **Log Query Experience** | 19 | User-perceived query latency via proxy |
| **Deep Dive** | 13 | Distributor, ingester, compactor health |
| **Ingestion Analytics** | 26 | Lines/bytes by namespace/tenant/job |
| **Errors & Rejections** | 14 | 4xx/5xx, discarded samples, rate limiting |

### Mimir (5 dashboards)

| Dashboard | Panels | Key Feature |
|-----------|--------|-------------|
| **Write QoS** | 18 | SLO: 95% writes within 0.5s, per-cluster |
| **Read QoS** | 18 | Query frontend enqueue latency |
| **Deep Dive** | 12 | Write/read path, compactor, querier |
| **Ingestion Analytics** | 26 | Samples/series by tenant, discards by reason |
| **Errors & Rejections** | 15 | Write/read path errors, query frontend rejections |

### Tempo (3 dashboards)

| Dashboard | Panels | Key Feature |
|-----------|--------|-------------|
| **Deep Dive** | 12 | Spans, traces, compaction, block storage |
| **Ingestion Analytics** | 23 | Spans by tenant, live traces per ingester |
| **Errors & Rejections** | 17 | Discarded spans, write/query path errors |

### Pyroscope (3 dashboards)

| Dashboard | Panels | Key Feature |
|-----------|--------|-------------|
| **Deep Dive** | 11 | Profiles, distributor, ingester, compactor |
| **Ingestion Analytics** | 11 | Profiles by service/tenant, active series |
| **Errors & Rejections** | 14 | Profile rejections, write errors |

### Volume Analytics (6 dashboards)

| Dashboard | Panels | Key Feature |
|-----------|--------|-------------|
| **Grafana Volume** | 13 | Request traffic by handler, proxy throughput |
| **Loki Volume** | 15 | Lines/bytes by namespace/tenant/cluster |
| **Mimir Volume** | 28 | Samples/series, write vs read, WoW growth |
| **Tempo Volume** | 25 | Spans/bytes, blocks, compaction, queries |
| **Pyroscope Volume** | 26 | Profiles by service, active series, storage |
| **Cross-Stack Summary** | 22 | Unified view, WoW growth, rejection rates |

### Observability KPI (7 dashboards)

| Dashboard | Panels | Key Feature |
|-----------|--------|-------------|
| **App Overview (4-Signal)** | 17 | Correlates Mimir + Loki + Tempo + Pyroscope |
| **Loki LogQL Deep Dive** | 13 | unwrap, pattern, quantile_over_time, log-to-trace |
| **Tempo TraceQL** | 22 | Native trace search, span RED metrics |
| **Pyroscope Flamegraph** | 14 | Native flamegraph, profile type selector |
| **Mimir Infrastructure** | 21 | USE method, HPA, pod lifecycle |
| **SLO / SLI Dashboard** | 16 | Multi-window burn rate, configurable targets |
| **User Journey** | 17 | Full user investigation across 5 signals |

---

## Architecture

### Folder Structure

```
Grafana-Dashbords/
├── L0-executive/          1 dashboard   L0 Executive Command Center
├── L1-domain/             3 dashboards  Infrastructure, Apps, Profiling
├── L2-service/            1 dashboard   Service Golden Signals
├── L3-deepdive/           4 dashboards  Traces, Logs, Profiles, K8s
├── grafana/               6 dashboards  Admin, Security, DB, Users, Errors, QoS
├── loki/                  5 dashboards  QoS, Query, Deep Dive, Ingestion, Errors
├── mimir/                 5 dashboards  Write/Read QoS, Deep Dive, Ingestion, Errors
├── tempo/                 3 dashboards  Deep Dive, Ingestion, Errors
├── pyroscope/             3 dashboards  Deep Dive, Ingestion, Errors
├── platform/             13 dashboards  Executive, SLO, KPI, Anomaly, Forecasting
├── observability-kpi/     7 dashboards  4-Signal, LogQL, TraceQL, Flamegraph, SLO
├── volume/                6 dashboards  Per-component & cross-stack volume
├── docker-compose.yml                   Grafana 11.6.4 + Prometheus + Renderer
├── provisioning/                        Auto-provisioning configs
├── validate.py                          6-phase validation suite
└── README.md
```

### Navigation Flow

Every dashboard has a **navigation bar** with links to related dashboards:

```
                         ┌──────────────┐
                         │  Home Page   │
                         └──────┬───────┘
                                │
                    ┌───────────┼───────────┐
                    ▼           ▼           ▼
             ┌──────────┐ ┌─────────┐ ┌─────────┐
             │Platform  │ │L0 Exec  │ │ Alerts  │
             │KPI       │ │Command  │ │         │
             └────┬─────┘ └────┬────┘ └─────────┘
                  │            │
    ┌─────────────┼────────────┼─────────────┐
    ▼             ▼            ▼             ▼
┌───────┐  ┌──────────┐ ┌──────────┐ ┌──────────┐
│Grafana│  │  Mimir   │ │  Loki    │ │Tempo/Pyro│
│Admin  │  │Write/Read│ │Write/Qry │ │Deep Dive │
└───┬───┘  └────┬─────┘ └────┬─────┘ └────┬─────┘
    │           │            │             │
    ▼           ▼            ▼             ▼
┌───────┐  ┌──────────┐ ┌──────────┐ ┌──────────┐
│Errors │  │Ingestion │ │Ingestion │ │Ingestion │
│Volume │  │Errors    │ │Errors    │ │Errors    │
│Users  │  │Volume    │ │Volume    │ │Volume    │
└───────┘  └──────────┘ └──────────┘ └──────────┘
```

### Cross-Dashboard Links

All dashboards include contextual navigation:
- **Up arrow links** → Platform KPI + L0 Command Center (always present)
- **Sibling links** → Other dashboards in the same component
- **Cross-component links** → Jump to Grafana, Mimir, Loki, Tempo, Pyroscope
- **Variable passthrough** → `includeVars: true`, `keepTime: true` preserves filters

---

## User Guide

### For Executives (CEO / CTO / VP)

Start here:
1. **Home** → See your starred dashboards and any firing alerts
2. **Platform KPI** → 5-second health check of everything
3. **CEO Summary** → SLO scorecard for board meetings
4. **SLA Report** → 3-decimal SLA with error budget gauge

### For SREs / On-Call Engineers

Start here:
1. **Home** → Check firing alerts
2. **L0 Command Center** → Overview with drill-down links
3. **Error dashboards** (grafana/loki/mimir/tempo) → 4xx/5xx analysis
4. **Anomaly Detection** → Spot deviations before they become incidents
5. **SLO Burn Rate** → Multi-window burn rate analysis

### For Platform Engineers

Start here:
1. **Volume dashboards** → Track ingestion rates across all signals
2. **Ingestion Analytics** → Top producers by namespace/tenant
3. **Predictive Forecasting** → Days until capacity limit
4. **Multi-Tenant Analytics** → Per-tenant resource usage

### For Developers

Start here:
1. **App Overview (4-Signal)** → Correlate metrics, logs, traces, profiles
2. **User Journey** → Enter a user email, see everything they did
3. **Service Golden Signals** → Rate, errors, duration per service
4. **LogQL Deep Dive** → Advanced log analysis with trace correlation

### Template Variables

Every dashboard includes dropdown filters:

| Variable | Description | Example |
|----------|-------------|---------|
| `datasource` | Select Prometheus/Mimir source | Any Prometheus instance |
| `cluster` | Kubernetes cluster | `prod-us-west-1` |
| `namespace` | K8s namespace | `payments`, `auth` |
| `tenant` | Multi-tenant identifier | `team-a`, `org-1` |
| `instance` | Grafana server instance | `grafana-0:3000` |
| `handler` / `route` | API endpoint filter | `/api/dashboards/*` |
| `sensitivity` | Anomaly detection sigma | `1σ`, `2σ`, `3σ` |
| `slo_target` | SLO compliance target | `99.9%`, `99.0%` |

### Color Guide

Consistent across all dashboards:

| Color | Meaning |
|-------|---------|
| **Green** (#73BF69) | Healthy, SLO met, budget remaining |
| **Yellow/Amber** (#FF9830) | Warning, approaching SLO boundary |
| **Red** (#F2495C) | Critical, SLO breached, action needed |
| **Blue** (#5794F2) | Informational, neutral metrics |
| **Purple** (#B877D9) | User-related, profiling metrics |

### HTTP Status Code Colors (Error Dashboards)

| Code | Color | Meaning |
|------|-------|---------|
| 400 | Amber | Bad request |
| 401 | Orange | Unauthorized |
| 403 | Dark Orange | Forbidden |
| 429 | Red | Rate limited |
| 500 | Dark Red | Internal server error |
| 502 | Red | Bad gateway |
| 503 | Light Red | Unavailable |

---

## Deployment Options

### Option 1: Docker Compose (Traditional)

```bash
git clone https://github.com/gpadidala/Grafana-Dashbords.git
cd Grafana-Dashbords
docker compose up -d
open http://localhost:3200    # admin / admin
```

### Option 2: Manual Import
Open **http://localhost:3200** (admin / admin)

### Option 2: Podman (Windows - Recommended for Corporate Environments)

**Step 1: Install Podman**
```powershell
# Option A: Use local PowerShell installer
.\Install-Podman.ps1

# Option B: Use local batch installer
.\install-podman-local.bat

# Option C: Use parent directory installer
& "..\Next-Gen-O11y-Onboarding-Platform\install-podman.bat"
```

**Step 2: Start Grafana Dashboards**
```powershell
# Recommended: TLS workaround for corporate networks
.\Start-Grafana-TLS-Fix.ps1

# Alternative: Standard start (if no TLS issues)
.\start-podman-dashboards-alt.bat

# Option: Use compose (if available)
.\start-podman-dashboards.bat
```

**Step 3: Fix Dashboard Mounts (if needed)**
```powershell
# If dashboards don't appear, run this fix
.\Fix-Dashboard-Mounts.ps1
```

Open **http://localhost:3200** (admin / admin)

**Podman Command Reference:**
- `Install-Podman.ps1` - PowerShell Podman installer
- `Start-Grafana-TLS-Fix.ps1` - Start with TLS workarounds (recommended)
- `start-podman-dashboards-alt.bat` - Start using individual commands
- `Fix-Dashboard-Mounts.ps1` - Fix dashboard volume mounts
- `Stop-Podman-Dashboards.ps1` - Stop all services (PowerShell)
- `check-dashboards.bat` - Verify dashboard loading
- `setup-podman.bat` - One-time environment setup

**Troubleshooting:**
- **TLS Certificate Errors:** Use `.\Start-Grafana-TLS-Fix.ps1`
- **Missing Dashboards:** Run `.\Fix-Dashboard-Mounts.ps1`
- **PATH Issues:** Restart PowerShell after Podman installation
- **Machine Not Running:** Run `podman machine start`

### Option 3: Manual Import

1. Go to **Dashboards → New → Import**
2. Upload any `.json` file
3. Select your Prometheus datasource
4. Click **Import**

### Option 3: Kubernetes Provisioning

```bash
# Copy to your Grafana provisioning path
kubectl cp grafana/ grafana-pod:/var/lib/grafana/dashboards/grafana/
kubectl cp loki/ grafana-pod:/var/lib/grafana/dashboards/loki/
# ... repeat for each folder

# Or mount as a ConfigMap / PersistentVolume
```

### Option 4: Grafana API Bulk Import

```bash
# Import all dashboards via API
for f in **/*.json; do
  curl -s -u admin:admin -H "Content-Type: application/json" \
    -X POST "http://localhost:3200/api/dashboards/db" \
    -d "{\"dashboard\": $(cat "$f" | python3 -c "import sys,json; d=json.load(sys.stdin); d['id']=None; print(json.dumps(d))"), \"overwrite\": true}"
done
```

---

## Grafana MCP Server (AI Integration)
## Podman Setup Guide (Windows)

This project includes comprehensive Podman support for Windows environments, especially useful in corporate networks where Docker Desktop may not be available or TLS certificate issues occur.

### Features

- ✅ **Automated Podman Installation** - PowerShell and batch installers
- ✅ **TLS Certificate Workarounds** - For corporate firewall/proxy environments  
- ✅ **Proper Dashboard Mounting** - All 33 dashboards organized in folders
- ✅ **PATH Resolution** - Automatic Podman path detection and fixing
- ✅ **Machine Management** - Automated VM creation and startup
- ✅ **Multiple Startup Methods** - Compose, individual commands, and PowerShell

### Quick Start (Podman)

```powershell
# 1. Install Podman
.\Install-Podman.ps1

# 2. Start Grafana (with TLS fix for corporate networks)
.\Start-Grafana-TLS-Fix.ps1

# 3. Access dashboards
# Open: http://localhost:3200 (admin/admin)
```

### File Overview

| File | Purpose |
|------|---------|
| `Install-Podman.ps1` | PowerShell installer for Podman |
| `Start-Grafana-TLS-Fix.ps1` | Start with TLS certificate workarounds |
| `Fix-Dashboard-Mounts.ps1` | Fix dashboard volume mounting issues |
| `start-podman-dashboards-alt.bat` | Alternative startup using individual commands |
| `check-dashboards.bat` | Verify dashboard loading status |
| `podman-compose.yml` | Compose file with proper volume mounts |

### Common Issues & Solutions

**Problem: TLS Certificate Errors**
```
Error: x509: certificate signed by unknown authority
```
**Solution:** Use the TLS fix script
```powershell
.\Start-Grafana-TLS-Fix.ps1
```

**Problem: Dashboards Not Appearing**
```
Grafana loads but no dashboards in folders
```
**Solution:** Fix dashboard mounts
```powershell
.\Fix-Dashboard-Mounts.ps1
```

**Problem: Podman Not Found in PATH**
```
ERROR: Podman is not installed or not in PATH
```
**Solution:** Restart PowerShell or fix PATH manually
```powershell
$env:Path += ";C:\Users\$env:USERNAME\AppData\Local\Programs\Podman"
```

**Problem: Machine Not Running**
```
Error: unable to connect to podman socket
```
**Solution:** Start the Podman machine
```powershell
podman machine start
```

---

## User Guide

This project includes configuration for the [official Grafana MCP server](https://github.com/grafana/mcp-grafana), enabling AI-powered dashboard search and exploration.

### Setup

```bash
# 1. Install the MCP server
npm install -g mcp-grafana-npx

# 2. Create a Grafana service account (Viewer role)
curl -s -u admin:admin -X POST -H "Content-Type: application/json" \
  "http://localhost:3200/api/serviceaccounts" \
  -d '{"name":"mcp-readonly","role":"Viewer"}'

# 3. Create a token
curl -s -u admin:admin -X POST -H "Content-Type: application/json" \
  "http://localhost:3200/api/serviceaccounts/2/tokens" \
  -d '{"name":"mcp-token"}'

# 4. Add to .claude/settings.local.json (gitignored)
{
  "mcpServers": {
    "grafana": {
      "command": "mcp-grafana-npx",
      "env": {
        "GRAFANA_URL": "http://localhost:3200",
        "GRAFANA_SERVICE_ACCOUNT_TOKEN": "<your-token>"
      }
    }
  }
}
```

### What MCP Provides

| Tool | Description |
|------|-------------|
| `search_dashboards` | Search dashboards by name, tag, or folder |
| `list_datasources` | List all configured data sources |
| `get_dashboard` | Get full dashboard JSON by UID |
| `list_alerts` | List firing/pending alerts |

---

## Validation

```bash
# Validate all dashboards against running Grafana
python3 validate.py --url http://localhost:3200 --dashboard-dir .

# Quick local JSON validation
python3 -c "
import json, glob
for f in sorted(glob.glob('**/*.json', recursive=True)):
    try:
        json.load(open(f))
        print(f'OK {f}')
    except Exception as e:
        print(f'FAIL {f}: {e}')
"
```

---

## Design Principles

- **No invented metrics** — every query uses real Prometheus/Grafana metrics
- **No hardcoded datasource UIDs** — all dashboards use `${datasource}` variable
- **Grafana 11 safe** — no range value mappings in stat panels
- **Portable** — import into any Grafana instance, pick your datasource
- **`$__rate_interval`** in timeseries for adaptive resolution
- **Division-by-zero safe** — `+ 0.001` on all denominators
- **Schema version 39** — compatible with Grafana 10.x and 11.x
- **Google SRE methodology** — multi-window burn rates, error budgets

---

## Alert & Recording Rules

Located in `observability-kpi/`:

| File | Rules | Coverage |
|------|-------|---------|
| `mimir-alert-rules.yaml` | 12 | SLO burn, P99 latency, OOM, CPU throttle, memory |
| `loki-alert-rules.yaml` | 10 | Error log rate, panic, OOM, timeout, connection refused |
| `mimir-recording-rules.yaml` | 26 | Pre-aggregated request rates, latency percentiles, SLO ratios |

---

## Stats

```
Dashboards:    57
Panels:       991
Folders:       11
Alert Rules:   22
Recording Rules: 26
Grafana:     11.6.4
MCP Server:  v0.11.4
```

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add dashboard JSON to the appropriate folder
4. Run validation: `python3 validate.py`
5. Open a Pull Request

---

## Author

**Gopal Padidala** — Platform Engineering

Built with assistance from Claude (Anthropic) for enterprise observability at scale.

---

## License

MIT License
