@echo off
setlocal enabledelayedexpansion

echo ===============================================
echo Starting Grafana Dashboards with Podman
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
        echo Please try one of the following:
        echo   1. Restart your terminal/PowerShell and try again
        echo   2. Run: .\Install-Podman.ps1
        echo   3. Run: .\install-podman-local.bat
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
                echo Please try: podman machine init
                pause
                exit /b 1
            )
        ) else (
            echo ✓ Podman machine started successfully
        )
    )
    REM Wait a moment for the machine to fully start
    timeout /t 10 /nobreak >nul
) else (
    echo ✓ Podman machine is already running
)

REM Stop any existing containers
echo Stopping any existing containers...
podman-compose -f podman-compose.yml down 2>nul

REM Pull latest images
echo Pulling required images...
podman pull grafana/grafana:11.6.4
podman pull grafana/grafana-image-renderer:latest
podman pull prom/prometheus:v2.53.4

REM Create and start services
echo Starting Grafana Dashboard services...
podman-compose -f podman-compose.yml up -d

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
    timeout /t 15 /nobreak >nul
    
    REM Check if Grafana is responding
    echo Testing Grafana connectivity...
    curl -s http://localhost:3200/api/health >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✓ Grafana is responding on port 3200
        echo.
        echo You can now access the 33 enterprise dashboards at:
        echo http://localhost:3200
    ) else (
        echo ⚠ Grafana may still be starting up. Please wait a moment and try accessing http://localhost:3200
    )
) else (
    echo ✗ Failed to start services
    echo Check the error messages above for troubleshooting
)

echo.
echo To stop the services, run: stop-podman-dashboards.bat
pause
