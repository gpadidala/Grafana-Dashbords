@echo off
setlocal enabledelayedexpansion

echo ===============================================
echo Starting Grafana Dashboards with Podman
echo (Alternative method - no compose required)
echo ===============================================

REM Check if Podman is installed and available
echo Checking Podman installation...

REM Refresh PATH from registry first
for /f "usebackq tokens=2,*" %%A in (`reg query HKCU\Environment /v PATH 2^>nul`) do set UserPath=%%B
for /f "usebackq tokens=2,*" %%A in (`reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul`) do set SystemPath=%%B
if defined UserPath set "PATH=%SystemPath%;%UserPath%"

podman version >nul 2>&1
if !errorlevel! neq 0 (
    echo Podman not found in current PATH. Checking common install locations...
    
    REM Try common Podman installation paths
    set "PODMAN_FOUND=0"
    if exist "C:\Program Files\RedHat\Podman\podman.exe" (
        set "PATH=%PATH%;C:\Program Files\RedHat\Podman"
        set "PODMAN_FOUND=1"
        echo ✓ Found Podman at: C:\Program Files\RedHat\Podman
    ) else if exist "%LocalAppData%\Programs\Podman\podman.exe" (
        set "PATH=%PATH%;%LocalAppData%\Programs\Podman"
        set "PODMAN_FOUND=1"
        echo ✓ Found Podman at: %LocalAppData%\Programs\Podman
    )
    
    if !PODMAN_FOUND! equ 0 (
        echo ERROR: Podman is not installed or not in PATH
        echo Please restart your terminal and try again
        pause
        exit /b 1
    )
    
    REM Test if podman works now
    podman version >nul 2>&1
    if !errorlevel! neq 0 (
        echo ERROR: Podman found but not working properly
        echo Please restart your terminal and try again
        pause
        exit /b 1
    )
)

REM Check if Podman machine is running
echo Checking Podman machine status...
podman machine list | find "Running" >nul
if !errorlevel! neq 0 (
    echo Starting Podman machine...
    
    REM Capture the output to check for "already running" message
    podman machine start 2>&1 | find "already running" >nul
    if !errorlevel! equ 0 (
        echo ✓ Podman machine is already running
    ) else (
        REM Try starting again and check exit code
        podman machine start >nul 2>&1
        if !errorlevel! neq 0 (
            REM Check if it's now running despite error
            podman machine list | find "Running" >nul
            if !errorlevel! equ 0 (
                echo ✓ Podman machine is now running
            ) else (
                echo ERROR: Failed to start Podman machine
                pause
                exit /b 1
            )
        ) else (
            echo ✓ Podman machine started successfully
        )
    )
    timeout /t 10 /nobreak >nul
) else (
    echo ✓ Podman machine is already running
)

REM Clean up any existing containers
echo Cleaning up existing containers...
podman stop grafana-executive-dashboards grafana-renderer prometheus-stub 2>nul
podman rm grafana-executive-dashboards grafana-renderer prometheus-stub 2>nul

REM Create network
echo Creating Podman network...
podman network create grafana-network 2>nul

REM Create volume
echo Creating storage volume...
podman volume create grafana-storage 2>nul

REM Pull images
echo Pulling required images...
echo - Grafana...
podman pull grafana/grafana:11.6.4
echo - Grafana Image Renderer...
podman pull grafana/grafana-image-renderer:latest
echo - Prometheus...
podman pull prom/prometheus:v2.53.4

REM Get current directory for volume mounts
set "CURRENT_DIR=%CD%"

REM Start Prometheus
echo Starting Prometheus...
podman run -d ^
    --name prometheus-stub ^
    --network grafana-network ^
    -p 9090:9090 ^
    -v "%CURRENT_DIR%\provisioning\prometheus.yml:/etc/prometheus/prometheus.yml:ro" ^
    --restart unless-stopped ^
    prom/prometheus:v2.53.4

REM Start Grafana Image Renderer
echo Starting Grafana Image Renderer...
podman run -d ^
    --name grafana-renderer ^
    --network grafana-network ^
    -p 8081:8081 ^
    -e ENABLE_METRICS=true ^
    -e RENDERING_MODE=default ^
    -e RENDERING_CLUSTERING_MODE=default ^
    --restart unless-stopped ^
    grafana/grafana-image-renderer:latest

REM Start Grafana
echo Starting Grafana...
podman run -d ^
    --name grafana-executive-dashboards ^
    --network grafana-network ^
    -p 3200:3000 ^
    -e GF_SECURITY_ADMIN_USER=admin ^
    -e GF_SECURITY_ADMIN_PASSWORD=admin ^
    -e GF_USERS_ALLOW_SIGN_UP=false ^
    -e "GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH=/var/lib/grafana/dashboards/platform/38-enterprise-home-page.json" ^
    -e GF_LOG_LEVEL=info ^
    -e GF_FEATURE_TOGGLES_ENABLE= ^
    -e GF_RENDERING_SERVER_URL=http://renderer:8081/render ^
    -e GF_RENDERING_CALLBACK_URL=http://grafana:3000/ ^
    -e GF_LOG_FILTERS=rendering:debug ^
    -v grafana-storage:/var/lib/grafana ^
    -v "%CURRENT_DIR%\provisioning\datasources:/etc/grafana/provisioning/datasources:ro" ^
    -v "%CURRENT_DIR%\provisioning\dashboards:/etc/grafana/provisioning/dashboards:ro" ^
    -v "%CURRENT_DIR%\grafana:/var/lib/grafana/dashboards/grafana:ro" ^
    -v "%CURRENT_DIR%\loki:/var/lib/grafana/dashboards/loki:ro" ^
    -v "%CURRENT_DIR%\mimir:/var/lib/grafana/dashboards/mimir:ro" ^
    -v "%CURRENT_DIR%\tempo:/var/lib/grafana/dashboards/tempo:ro" ^
    -v "%CURRENT_DIR%\pyroscope:/var/lib/grafana/dashboards/pyroscope:ro" ^
    -v "%CURRENT_DIR%\platform:/var/lib/grafana/dashboards/platform:ro" ^
    -v "%CURRENT_DIR%\observability-kpi:/var/lib/grafana/dashboards/observability-kpi:ro" ^
    -v "%CURRENT_DIR%\volume:/var/lib/grafana/dashboards/volume:ro" ^
    -v "%CURRENT_DIR%\L0-executive:/var/lib/grafana/dashboards/L0-executive:ro" ^
    -v "%CURRENT_DIR%\L1-domain:/var/lib/grafana/dashboards/L1-domain:ro" ^
    -v "%CURRENT_DIR%\L2-service:/var/lib/grafana/dashboards/L2-service:ro" ^
    -v "%CURRENT_DIR%\L3-deepdive:/var/lib/grafana/dashboards/L3-deepdive:ro" ^
    -v "%CURRENT_DIR%\oci:/var/lib/grafana/dashboards/oci:ro" ^
    -v "%CURRENT_DIR%:/var/lib/grafana/dashboards/root:ro" ^
    --restart unless-stopped ^
    grafana/grafana:11.6.4

if !errorlevel! equ 0 (
    echo.
    echo ✓ Grafana Dashboards started successfully!
    echo.
    echo Access URLs:
    echo   Grafana UI: http://localhost:3200
    echo   Username:   admin
    echo   Password:   admin
    echo   Prometheus: http://localhost:9090
    echo   Renderer:   http://localhost:8081
    echo.
    echo Waiting for services to be ready...
    timeout /t 20 /nobreak >nul
    
    echo Testing Grafana connectivity...
    curl -s http://localhost:3200/api/health >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✓ Grafana is responding on port 3200
        echo.
        echo All 33 enterprise dashboards are now available!
        echo Access them at: http://localhost:3200
    ) else (
        echo ⚠ Grafana may still be starting up
        echo Please wait a moment and try accessing http://localhost:3200
    )
) else (
    echo ✗ Failed to start Grafana
    echo Check the error messages above for troubleshooting
)

echo.
echo Container Status:
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo To stop the services, run: stop-podman-dashboards-alt.bat
pause
