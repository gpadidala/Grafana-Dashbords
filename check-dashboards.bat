@echo off
echo ===============================================
echo Checking Grafana Dashboard Status
echo ===============================================

REM Add Podman to PATH if needed
if exist "C:\Users\gpadi40\AppData\Local\Programs\Podman\podman.exe" (
    set "PATH=%PATH%;C:\Users\gpadi40\AppData\Local\Programs\Podman"
)

echo Checking Grafana container status...
podman ps | find "grafana-executive-dashboards"
if %errorlevel% neq 0 (
    echo Grafana container is not running!
    echo Please start it first with: .\Start-Grafana-TLS-Fix.ps1
    pause
    exit /b 1
)

echo.
echo Grafana is running. Checking logs...
echo.
podman logs grafana-executive-dashboards --tail 20

echo.
echo Dashboard directory contents:
echo.
echo Grafana dashboards:
dir grafana\*.json /b 2>nul
echo.
echo Loki dashboards:
dir loki\*.json /b 2>nul
echo.
echo Mimir dashboards:
dir mimir\*.json /b 2>nul
echo.
echo Platform dashboards:
dir platform\*.json /b 2>nul

echo.
echo Access Grafana at: http://localhost:3200
echo Username: admin
echo Password: admin
echo.
pause
