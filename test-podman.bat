@echo off
echo Testing Podman setup...
echo.

REM Add Podman to PATH if needed
if exist "C:\Users\gpadi40\AppData\Local\Programs\Podman\podman.exe" (
    set "PATH=%PATH%;C:\Users\gpadi40\AppData\Local\Programs\Podman"
)

echo Podman version:
podman version
echo.

echo Machine status:
podman machine list
echo.

echo Testing basic functionality:
podman run --rm hello-world
echo.

echo Ready to start Grafana Dashboards!
pause
