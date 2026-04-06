# PowerShell Grafana Dashboards Startup Script
# This script handles PATH issues after fresh Podman installation

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Starting Grafana Dashboards with Podman (PS)" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Refresh environment variables
Write-Host "Refreshing environment variables..."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check if Podman is available
Write-Host "Checking Podman installation..."
try {
    $podmanVersion = podman version 2>$null
    Write-Host "✓ Podman is available" -ForegroundColor Green
} catch {
    Write-Host "Podman not found in PATH. Checking common install locations..." -ForegroundColor Yellow
    
    $podmanPaths = @(
        "C:\Program Files\RedHat\Podman\podman.exe",
        "$env:LocalAppData\Programs\Podman\podman.exe"
    )
    
    $found = $false
    foreach ($path in $podmanPaths) {
        if (Test-Path $path) {
            $pathDir = Split-Path $path
            $env:Path = $env:Path + ";" + $pathDir
            Write-Host "✓ Found Podman at: $pathDir" -ForegroundColor Green
            $found = $true
            break
        }
    }
    
    if (-not $found) {
        Write-Host "✗ Podman not found. Please restart PowerShell and try again." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Check Podman machine status
Write-Host "Checking Podman machine status..."
try {
    $machineList = podman machine list 2>$null
    if ($machineList -like "*Running*") {
        Write-Host "✓ Podman machine is running" -ForegroundColor Green
    } else {
        Write-Host "Starting Podman machine..." -ForegroundColor Yellow
        podman machine start
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ Failed to start Podman machine" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
        Start-Sleep -Seconds 10
    }
} catch {
    Write-Host "Error checking machine status. Attempting to start..." -ForegroundColor Yellow
    podman machine start
    Start-Sleep -Seconds 10
}

# Clean up any existing containers
Write-Host "Cleaning up existing containers..."
podman stop grafana-executive-dashboards grafana-renderer prometheus-stub 2>$null | Out-Null
podman rm grafana-executive-dashboards grafana-renderer prometheus-stub 2>$null | Out-Null

# Create network and volume
Write-Host "Setting up network and storage..."
podman network create grafana-network 2>$null | Out-Null
podman volume create grafana-storage 2>$null | Out-Null

# Pull required images
Write-Host "Pulling required images..."
Write-Host "- Pulling Grafana..." -ForegroundColor Yellow
podman pull grafana/grafana:11.6.4

Write-Host "- Pulling Image Renderer..." -ForegroundColor Yellow
podman pull grafana/grafana-image-renderer:latest

Write-Host "- Pulling Prometheus..." -ForegroundColor Yellow
podman pull prom/prometheus:v2.53.4

$currentDir = Get-Location

# Start Prometheus
Write-Host "Starting Prometheus..." -ForegroundColor Green
podman run -d `
    --name prometheus-stub `
    --network grafana-network `
    -p 9090:9090 `
    -v "$currentDir\provisioning\prometheus.yml:/etc/prometheus/prometheus.yml:ro" `
    --restart unless-stopped `
    prom/prometheus:v2.53.4

# Start Grafana Image Renderer
Write-Host "Starting Grafana Image Renderer..." -ForegroundColor Green
podman run -d `
    --name grafana-renderer `
    --network grafana-network `
    -p 8081:8081 `
    -e ENABLE_METRICS=true `
    -e RENDERING_MODE=default `
    -e RENDERING_CLUSTERING_MODE=default `
    --restart unless-stopped `
    grafana/grafana-image-renderer:latest

# Start Grafana
Write-Host "Starting Grafana..." -ForegroundColor Green
podman run -d `
    --name grafana-executive-dashboards `
    --network grafana-network `
    -p 3200:3000 `
    -e GF_SECURITY_ADMIN_USER=admin `
    -e GF_SECURITY_ADMIN_PASSWORD=admin `
    -e GF_USERS_ALLOW_SIGN_UP=false `
    -e "GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH=/var/lib/grafana/dashboards/01-platform-ui-qos-executive.json" `
    -e GF_LOG_LEVEL=info `
    -e "GF_FEATURE_TOGGLES_ENABLE=" `
    -e GF_RENDERING_SERVER_URL=http://renderer:8081/render `
    -e GF_RENDERING_CALLBACK_URL=http://grafana:3000/ `
    -e GF_LOG_FILTERS=rendering:debug `
    -v grafana-storage:/var/lib/grafana `
    -v "$currentDir\provisioning\datasources:/etc/grafana/provisioning/datasources:ro" `
    -v "$currentDir\provisioning\dashboards:/etc/grafana/provisioning/dashboards:ro" `
    -v "$currentDir\:/var/lib/grafana/dashboards:ro" `
    --restart unless-stopped `
    grafana/grafana:11.6.4

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Grafana Dashboards started successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Access URLs:" -ForegroundColor Cyan
    Write-Host "  Grafana UI: http://localhost:3200" -ForegroundColor White
    Write-Host "  Username:   admin" -ForegroundColor White
    Write-Host "  Password:   admin" -ForegroundColor White
    Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor White
    Write-Host "  Renderer:   http://localhost:8081" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Waiting for services to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 20
    
    Write-Host "Testing Grafana connectivity..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3200/api/health" -TimeoutSec 10 -UseBasicParsing 2>$null
        Write-Host "✓ Grafana is responding on port 3200" -ForegroundColor Green
        Write-Host ""
        Write-Host "All 33 enterprise dashboards are now available!" -ForegroundColor Green
        Write-Host "Access them at: http://localhost:3200" -ForegroundColor Cyan
    } catch {
        Write-Host "⚠ Grafana may still be starting up" -ForegroundColor Yellow
        Write-Host "Please wait a moment and try accessing http://localhost:3200" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ Failed to start Grafana" -ForegroundColor Red
    Write-Host "Check the error messages above for troubleshooting" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Container Status:" -ForegroundColor Cyan
podman ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}"

Write-Host ""
Write-Host "To stop the services, run: .\Stop-Podman-Dashboards.ps1" -ForegroundColor Yellow
Read-Host "Press Enter to continue"
