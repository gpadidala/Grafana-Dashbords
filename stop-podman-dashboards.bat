@echo off
echo ===============================================
echo Stopping Grafana Dashboards (Podman)
echo ===============================================

REM Check if podman-compose is available
podman-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Warning: podman-compose not found, using podman commands directly...
    
    echo Stopping individual containers...
    podman stop grafana-executive-dashboards grafana-renderer prometheus-stub 2>nul
    echo Removing containers...
    podman rm grafana-executive-dashboards grafana-renderer prometheus-stub 2>nul
    
    echo Removing network if exists...
    podman network rm grafana-dashboards_grafana-network 2>nul
    
) else (
    echo Stopping services using podman-compose...
    podman-compose -f podman-compose.yml down
)

echo Cleaning up unused volumes (optional)...
set /p cleanup="Do you want to remove data volumes? (y/N): "
if /i "%cleanup%"=="y" (
    echo Removing volumes...
    podman volume rm grafana-dashboards_grafana-storage 2>nul
    echo ✓ Volumes removed
) else (
    echo Volumes preserved for next startup
)

echo.
echo ✓ Grafana Dashboards stopped successfully!
echo.
echo To restart, run: start-podman-dashboards.bat
pause
