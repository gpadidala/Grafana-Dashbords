@echo off
setlocal enabledelayedexpansion

echo ===============================================
echo Grafana Dashboards Universal Launcher
echo ===============================================

REM Check for Podman first
echo Checking container runtime availability...
podman version >nul 2>&1
if !errorlevel! equ 0 (
    echo ✓ Podman detected
    set "USE_PODMAN=1"
    goto check_podman_setup
)

REM Check for Docker
docker version >nul 2>&1
if !errorlevel! equ 0 (
    echo ✓ Docker detected
    set "USE_DOCKER=1"
    goto start_docker
)

REM Neither found
echo ✗ Neither Podman nor Docker found
echo Please install one of the following:
echo   - Podman: Run ..\install-podman.bat
echo   - Docker Desktop: https://www.docker.com/products/docker-desktop
pause
exit /b 1

:check_podman_setup
echo Verifying Podman setup...
podman machine list | find "Running" >nul
if !errorlevel! neq 0 (
    echo Podman machine is not running. Setting up...
    call setup-podman.bat
)

REM Check which Podman method to use
podman-compose --version >nul 2>&1
if !errorlevel! equ 0 (
    echo Using Podman with podman-compose...
    call start-podman-dashboards.bat
) else (
    echo Using Podman with individual commands...
    call start-podman-dashboards-alt.bat
)
goto end

:start_docker
echo Using Docker Compose...
docker compose up -d
if !errorlevel! equ 0 (
    echo ✓ Docker services started successfully!
    echo Access Grafana at: http://localhost:3200
    echo Username: admin / Password: admin
) else (
    echo ✗ Failed to start Docker services
)
goto end

:end
echo.
echo Services should now be running at:
echo   http://localhost:3200 (Grafana)
echo   http://localhost:9090 (Prometheus)
echo   http://localhost:8081 (Renderer)
pause
