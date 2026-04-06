@echo off
echo ===============================================
echo Stopping Grafana Dashboards (Podman - Alt)
echo ===============================================

echo Stopping containers...
podman stop grafana-executive-dashboards grafana-renderer prometheus-stub 2>nul

echo Removing containers...
podman rm grafana-executive-dashboards grafana-renderer prometheus-stub 2>nul

echo Removing network...
podman network rm grafana-network 2>nul

echo.
echo Cleaning up unused volumes (optional)...
set /p cleanup="Do you want to remove data volumes? This will delete all Grafana data (y/N): "
if /i "%cleanup%"=="y" (
    echo Removing volumes...
    podman volume rm grafana-storage 2>nul
    echo ✓ Volumes removed - all data deleted
) else (
    echo Volumes preserved for next startup
)

echo.
echo ✓ Grafana Dashboards stopped successfully!
echo.
echo To restart, run: start-podman-dashboards-alt.bat
pause
