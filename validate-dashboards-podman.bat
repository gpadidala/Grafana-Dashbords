@echo off
setlocal enabledelayedexpansion

REM ─────────────────────────────────────────────────────────────
REM Grafana Dashboard Validation Script (Podman Version)
REM Validates all provisioned dashboards via Grafana HTTP API
REM ─────────────────────────────────────────────────────────────

set "GRAFANA_URL=http://localhost:3200"
set "GRAFANA_USER=admin"
set "GRAFANA_PASS=admin"
set "SCRIPT_DIR=%~dp0"

echo ===============================================
echo Validating Grafana Dashboards (Podman)
echo ===============================================

REM Check if Python is available
python --version >nul 2>&1
if !errorlevel! neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.x to run dashboard validation
    pause
    exit /b 1
)

REM Check if Grafana is running
echo Checking Grafana connectivity at %GRAFANA_URL%...
curl -s %GRAFANA_URL%/api/health >nul 2>&1
if !errorlevel! neq 0 (
    echo ERROR: Cannot connect to Grafana at %GRAFANA_URL%
    echo Make sure Grafana is running: start-podman-dashboards.bat
    pause
    exit /b 1
)

echo ✓ Grafana is accessible
echo Running dashboard validation...

python "%SCRIPT_DIR%validate.py" --url "%GRAFANA_URL%" --user "%GRAFANA_USER%" --password "%GRAFANA_PASS%" --dashboard-dir "%SCRIPT_DIR%"

if !errorlevel! equ 0 (
    echo.
    echo ✓ Dashboard validation completed successfully!
) else (
    echo.
    echo ✗ Dashboard validation failed
    echo Check the error messages above for troubleshooting
)

pause
