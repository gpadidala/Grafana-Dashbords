@echo off
setlocal enabledelayedexpansion

echo ===============================================
echo Podman Setup for Grafana Dashboards
echo ===============================================

REM Check if Podman is installed
echo Checking Podman installation...

REM Refresh PATH from registry
for /f "usebackq tokens=2,*" %%A in (`reg query HKCU\Environment /v PATH`) do set UserPath=%%B
for /f "usebackq tokens=2,*" %%A in (`reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH`) do set SystemPath=%%B
set "PATH=%SystemPath%;%UserPath%"

podman version >nul 2>&1
if !errorlevel! neq 0 (
    echo Podman command not found in current PATH. Trying common install locations...
    
    REM Try common Podman installation paths
    set "PODMAN_FOUND=0"
    if exist "C:\Program Files\RedHat\Podman\podman.exe" (
        set "PATH=%PATH%;C:\Program Files\RedHat\Podman"
        set "PODMAN_FOUND=1"
        echo Found Podman at: C:\Program Files\RedHat\Podman
    ) else if exist "%LocalAppData%\Programs\Podman\podman.exe" (
        set "PATH=%PATH%;%LocalAppData%\Programs\Podman"
        set "PODMAN_FOUND=1"
        echo Found Podman at: %LocalAppData%\Programs\Podman
    )
    
    if !PODMAN_FOUND! equ 0 (
        echo ERROR: Podman is not installed or cannot be found
        echo Please install Podman first:
        echo   - Run: .\Install-Podman.ps1
        echo   - Or run: .\install-podman-local.bat
        echo   - Or restart this terminal and try again
        pause
        exit /b 1
    )
)

echo ✓ Podman is installed
podman version

REM Check if podman-compose is available
echo.
echo Checking podman-compose availability...
podman-compose --version >nul 2>&1
if !errorlevel! neq 0 (
    echo podman-compose not found. Installing...
    
    REM Check if pip is available
    pip --version >nul 2>&1
    if !errorlevel! neq 0 (
        echo ERROR: pip is not available
        echo Please install Python and pip to install podman-compose
        echo Alternatively, you can use 'podman play kube' or individual podman commands
        pause
        exit /b 1
    )
    
    echo Installing podman-compose via pip...
    pip install podman-compose
    
    REM Verify installation
    podman-compose --version >nul 2>&1
    if !errorlevel! neq 0 (
        echo Warning: podman-compose installation may have failed
        echo The scripts will fall back to individual podman commands
    ) else (
        echo ✓ podman-compose installed successfully
    )
) else (
    echo ✓ podman-compose is available
    podman-compose --version
)

REM Check Podman machine status
echo.
echo Checking Podman machine status...
podman machine list | find "Running" >nul
if !errorlevel! neq 0 (
    echo Podman machine is not running. Starting...
    podman machine start
    if !errorlevel! neq 0 (
        echo ERROR: Failed to start Podman machine
        echo You may need to initialize it first: podman machine init
        pause
        exit /b 1
    )
    echo ✓ Podman machine started
) else (
    echo ✓ Podman machine is running
)

REM Test basic Podman functionality
echo.
echo Testing Podman functionality...
podman run --rm hello-world >nul 2>&1
if !errorlevel! equ 0 (
    echo ✓ Podman is working correctly
) else (
    echo Warning: Podman test failed, but continuing...
)

echo.
echo ===============================================
echo Podman Setup Complete!
echo ===============================================
echo.
echo Available commands:
echo   start-podman-dashboards.bat  - Start all services
echo   stop-podman-dashboards.bat   - Stop all services
echo   validate-dashboards-podman.bat - Validate dashboards
echo.
echo To start Grafana Dashboards, run:
echo   start-podman-dashboards.bat
echo.
pause
