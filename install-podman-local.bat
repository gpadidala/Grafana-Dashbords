@echo off
echo Running Podman installation from parent directory...
echo.

REM Check if the parent install script exists
if exist "..\Next-Gen-O11y-Onboarding-Platform\install-podman.bat" (
    echo Found install-podman.bat in parent directory
    echo Running installation...
    call "..\Next-Gen-O11y-Onboarding-Platform\install-podman.bat"
) else (
    echo Parent install script not found at expected location
    echo Checking current directory...
    
    if exist "Install-Podman.ps1" (
        echo Found PowerShell version. Running...
        powershell -ExecutionPolicy Bypass -File "Install-Podman.ps1"
    ) else (
        echo No installation script found!
        echo Please run one of the following:
        echo   1. From PowerShell: ^& "..\Next-Gen-O11y-Onboarding-Platform\install-podman.bat"
        echo   2. From CMD: call "..\Next-Gen-O11y-Onboarding-Platform\install-podman.bat"
        echo   3. From PowerShell: .\Install-Podman.ps1
        pause
        exit /b 1
    )
)

echo.
echo Installation complete! You can now run setup-podman.bat
pause
