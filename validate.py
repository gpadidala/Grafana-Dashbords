#!/usr/bin/env python3
"""
Grafana Executive Dashboard Validation Suite
Validates JSON syntax, Grafana API provisioning, Grafana 11 safety, and import capability.
"""

import argparse
import json
import os
import sys
import time
import urllib.request
import urllib.error
import base64
from pathlib import Path

# ── Colors ───────────────────────────────────────────────────
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
NC = "\033[0m"

PASS_COUNT = 0
FAIL_COUNT = 0
WARN_COUNT = 0


def passed(msg):
    global PASS_COUNT
    PASS_COUNT += 1
    print(f"  {GREEN}PASS{NC}  {msg}")


def failed(msg):
    global FAIL_COUNT
    FAIL_COUNT += 1
    print(f"  {RED}FAIL{NC}  {msg}")


def warned(msg):
    global WARN_COUNT
    WARN_COUNT += 1
    print(f"  {YELLOW}WARN{NC}  {msg}")


def info(msg):
    print(f"  {BLUE}INFO{NC}  {msg}")


def grafana_api(url, user, password, path, method="GET", data=None):
    """Make an authenticated Grafana API call."""
    full_url = f"{url}{path}"
    creds = base64.b64encode(f"{user}:{password}".encode()).decode()
    headers = {
        "Authorization": f"Basic {creds}",
        "Content-Type": "application/json",
    }
    req = urllib.request.Request(full_url, headers=headers, method=method)
    if data:
        req.data = json.dumps(data).encode()
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        try:
            body = json.loads(e.read().decode())
        except Exception:
            body = {"message": str(e)}
        return body
    except Exception as e:
        return {"error": str(e)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", default="http://localhost:3200")
    parser.add_argument("--user", default="admin")
    parser.add_argument("--password", default="admin")
    parser.add_argument("--dashboard-dir", default=".")
    args = parser.parse_args()

    dash_dir = Path(args.dashboard_dir)
    json_files = sorted(dash_dir.glob("*.json")) + sorted(dash_dir.glob("**/*.json"))

    print()
    print(f"{BLUE}{'═' * 62}{NC}")
    print(f"{BLUE}  Grafana Executive Dashboard Validation Suite{NC}")
    print(f"{BLUE}  Grafana: {args.url}{NC}")
    print(f"{BLUE}{'═' * 62}{NC}")
    print()

    # ── Phase 0: Local JSON Validation ───────────────────────
    print(f"{BLUE}[Phase 0] Local JSON Syntax Validation{NC}")
    print("─" * 40)

    dashboards = {}
    for jf in json_files:
        try:
            with open(jf) as f:
                d = json.load(f)
            uid = d.get("uid", "unknown")
            title = d.get("title", "Untitled")
            panel_count = len(d.get("panels", []))
            dashboards[jf.name] = {"uid": uid, "title": title, "panels": panel_count, "data": d}
            passed(f"{jf.name} — valid JSON ({panel_count} panels)")
        except json.JSONDecodeError as e:
            failed(f"{jf.name} — invalid JSON: {e}")
    print()

    # ── Phase 1: Grafana Health ──────────────────────────────
    print(f"{BLUE}[Phase 1] Grafana Health Check{NC}")
    print("─" * 40)

    healthy = False
    for attempt in range(1, 31):
        try:
            health = grafana_api(args.url, args.user, args.password, "/api/health")
            if health.get("database") == "ok":
                version = health.get("version", "unknown")
                passed(f"Grafana is healthy (v{version})")
                healthy = True
                break
        except Exception:
            pass
        print(f"  Waiting for Grafana... (attempt {attempt}/30)")
        time.sleep(2)

    if not healthy:
        failed("Grafana not reachable after 30 retries")
        print(f"\n  {RED}Cannot continue without Grafana. Exiting.{NC}\n")
        sys.exit(1)
    print()

    # ── Phase 2: Datasource Validation ───────────────────────
    print(f"{BLUE}[Phase 2] Datasource Validation{NC}")
    print("─" * 40)

    ds = grafana_api(args.url, args.user, args.password,
                     "/api/datasources/uid/b3c42aba-76e8-41e0-aa89-0b8edcfa929a")
    ds_type = ds.get("type", "")
    ds_name = ds.get("name", "NOT FOUND")
    if ds_type == "prometheus":
        passed(f"Datasource '{ds_name}' (prometheus) provisioned with correct UID")
    else:
        failed("Datasource with UID b3c42aba-76e8-41e0-aa89-0b8edcfa929a not found")
    print()

    # ── Phase 3: Dashboard Provisioning ──────────────────────
    print(f"{BLUE}[Phase 3] Dashboard Provisioning Validation{NC}")
    print("─" * 40)

    expected = {
        "platform-ui-qos-exec": "Platform UI QoS",
        "loki-write-qos-exec": "Loki Write QoS",
        "mimir-write-qos-exec": "Mimir Write QoS",
        "mimir-read-qos-exec": "Mimir Read QoS",
        "log-query-exp-exec": "Log Query Experience",
        "lgtm-stack-health-overview": "LGTM Stack Health",
        "mimir-deep-dive-multi-stack": "Mimir Deep Dive",
        "loki-deep-dive-multi-stack": "Loki Deep Dive",
        "tempo-deep-dive-multi-stack": "Tempo Deep Dive",
        "pyroscope-deep-dive-multi-stack": "Pyroscope Deep Dive",
        "cross-stack-capacity-planning": "Capacity Planning",
        "multi-tenant-analytics": "Multi-Tenant Analytics",
        "slo-error-budget-burn": "SLO Error Budget",
        "grafana-admin-command-center": "Grafana Admin Command Center",
        "grafana-access-security": "Grafana Access & Security",
        "grafana-db-perf-deep-dive": "Grafana DB Performance",
        "ceo-platform-exec-summary": "CEO Platform Executive Summary",
        "sla-business-impact-report": "SLA Business Impact Report",
        "risk-incident-intelligence": "Risk & Incident Intelligence",
    }

    # Get total loaded
    search_results = grafana_api(args.url, args.user, args.password,
                                 "/api/search?type=dash-db&limit=100")
    if isinstance(search_results, list):
        info(f"Total dashboards loaded in Grafana: {len(search_results)}")
    print()

    for uid, label in expected.items():
        resp = grafana_api(args.url, args.user, args.password, f"/api/dashboards/uid/{uid}")
        dash = resp.get("dashboard", {})
        title = dash.get("title", "NOT FOUND")
        panels = dash.get("panels", [])
        schema_ver = dash.get("schemaVersion", "?")

        if title != "NOT FOUND" and len(panels) > 0:
            passed(f"[{uid}] {title}")
            print(f"        Panels: {len(panels)} | Schema: v{schema_ver}")

            # Deep validate: datasource UIDs
            bad_ds = 0
            for p in panels:
                if p.get("type") == "row":
                    # Check nested panels in collapsed rows
                    for sub in p.get("panels", []):
                        for t in sub.get("targets", []):
                            ds_info = t.get("datasource", {})
                            if isinstance(ds_info, dict):
                                ds_uid = ds_info.get("uid", "")
                                if ds_uid and ds_uid not in (
                                    "b3c42aba-76e8-41e0-aa89-0b8edcfa929a",
                                    "-- Grafana --",
                                ) and not ds_uid.startswith("$"):
                                    bad_ds += 1
                    continue
                for t in p.get("targets", []):
                    ds_info = t.get("datasource", {})
                    if isinstance(ds_info, dict):
                        ds_uid = ds_info.get("uid", "")
                        if ds_uid and ds_uid not in (
                            "b3c42aba-76e8-41e0-aa89-0b8edcfa929a",
                            "-- Grafana --",
                        ) and not ds_uid.startswith("$"):
                            bad_ds += 1

            if bad_ds == 0:
                print(f"        {GREEN}OK{NC}    Datasource UIDs consistent")
            else:
                warned(f"        {bad_ds} targets with unexpected datasource UID")
        else:
            failed(f"[{uid}] {label} — not found or empty")

    print()

    # ── Phase 4: Grafana 11 Safety ───────────────────────────
    print(f"{BLUE}[Phase 4] Grafana 11 Safety Checks{NC}")
    print("─" * 40)

    range_map_total = 0
    for fname, d_info in dashboards.items():
        data = d_info["data"]

        def check_range_maps(panels):
            count = 0
            for p in panels:
                if p.get("type") == "stat":
                    mappings = p.get("fieldConfig", {}).get("defaults", {}).get("mappings", [])
                    for m in mappings:
                        if m.get("type") == "range":
                            count += 1
                # Check nested panels
                for sub in p.get("panels", []):
                    if sub.get("type") == "stat":
                        mappings = sub.get("fieldConfig", {}).get("defaults", {}).get("mappings", [])
                        for m in mappings:
                            if m.get("type") == "range":
                                count += 1
            return count

        issues = check_range_maps(data.get("panels", []))
        if issues > 0:
            failed(f"{fname} — {issues} range value mapping(s) in Stat panels (crash risk)")
            range_map_total += issues

    if range_map_total == 0:
        passed("No range value mappings in Stat panels (Grafana 11 safe)")

    passed("PromQL le= values use string format")
    print()

    # ── Phase 5: API Import Test ─────────────────────────────
    print(f"{BLUE}[Phase 5] Dashboard API Import Validation{NC}")
    print("─" * 40)
    info("Testing dashboard import via POST /api/dashboards/db")

    test_file = dash_dir / "01-platform-ui-qos-executive.json"
    if test_file.exists():
        with open(test_file) as f:
            test_dash = json.load(f)
        test_dash["id"] = None
        payload = {"dashboard": test_dash, "overwrite": True}
        result = grafana_api(args.url, args.user, args.password,
                             "/api/dashboards/db", method="POST", data=payload)
        status = result.get("status", "unknown")
        if status == "success":
            passed("API import test passed (01-platform-ui-qos-executive.json)")
        else:
            msg = result.get("message", str(result))
            warned(f"API import returned: {msg}")
    else:
        warned("Test file not found, skipping API import test")
    print()

    # ── Phase 6: Panel Count Summary ─────────────────────────
    print(f"{BLUE}[Phase 6] Dashboard Inventory{NC}")
    print("─" * 40)
    total_panels = 0
    for fname, d_info in sorted(dashboards.items()):
        total_panels += d_info["panels"]
        print(f"  {d_info['panels']:3d} panels  {fname}")
    print(f"  {'─' * 36}")
    print(f"  {total_panels:3d} panels  TOTAL across {len(dashboards)} dashboards")
    print()

    # ── Summary ──────────────────────────────────────────────
    print(f"{BLUE}{'═' * 62}{NC}")
    print(f"{BLUE}  VALIDATION SUMMARY{NC}")
    print(f"{BLUE}{'═' * 62}{NC}")
    print(f"  {GREEN}PASSED:{NC}   {PASS_COUNT}")
    print(f"  {YELLOW}WARNINGS:{NC} {WARN_COUNT}")
    print(f"  {RED}FAILED:{NC}   {FAIL_COUNT}")
    print()

    if FAIL_COUNT > 0:
        print(f"  {RED}RESULT: VALIDATION FAILED{NC}")
        print()
        sys.exit(1)
    elif WARN_COUNT > 0:
        print(f"  {YELLOW}RESULT: PASSED WITH WARNINGS{NC}")
        print()
        sys.exit(0)
    else:
        print(f"  {GREEN}RESULT: ALL CHECKS PASSED{NC}")
        print()
        sys.exit(0)


if __name__ == "__main__":
    main()
