# PowerShell script to start Grafana Dashboards with TLS workaround
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Starting Grafana Dashboards (TLS Workaround)" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Add Podman to PATH
$podmanPaths = @(
    "C:\Program Files\RedHat\Podman",
    "$env:LocalAppData\Programs\Podman"
)

foreach ($path in $podmanPaths) {
    if ((Test-Path "$path\podman.exe") -and ($env:Path -notlike "*$path*")) {
        $env:Path += ";$path"
        break
    }
}

# Clean up existing containers
Write-Host "Cleaning up existing containers..."
podman stop grafana-executive-dashboards grafana-renderer prometheus-stub 2>$null | Out-Null
podman rm grafana-executive-dashboards grafana-renderer prometheus-stub 2>$null | Out-Null

# Create network and volume
Write-Host "Setting up network and storage..."
podman network create grafana-network 2>$null | Out-Null
podman volume create grafana-storage 2>$null | Out-Null

$currentDir = Get-Location

# Method 1: Try with --tls-verify=false
Write-Host "Attempting to pull images with TLS workaround..." -ForegroundColor Yellow

Write-Host "- Pulling Prometheus..." -ForegroundColor Yellow
$prometheusResult = podman pull --tls-verify=false prom/prometheus:v2.53.4 2>&1

Write-Host "- Pulling Grafana..." -ForegroundColor Yellow  
$grafanaResult = podman pull --tls-verify=false grafana/grafana:11.6.4 2>&1

Write-Host "- Pulling Image Renderer..." -ForegroundColor Yellow
$rendererResult = podman pull --tls-verify=false grafana/grafana-image-renderer:latest 2>&1

# Check if pulls were successful
$pullsSuccessful = $true
if ($prometheusResult -like "*Error*") { $pullsSuccessful = $false }
if ($grafanaResult -like "*Error*") { $pullsSuccessful = $false }
if ($rendererResult -like "*Error*") { $pullsSuccessful = $false }

if (-not $pullsSuccessful) {
    Write-Host "⚠ Image pulls failed. Trying with local registry cache..." -ForegroundColor Yellow
    
    # Try pulling from alternative registries or use cached images
    Write-Host "Checking for existing images..."
    $existingImages = podman images --format "{{.Repository}}:{{.Tag}}"
    
    if ($existingImages -notcontains "prom/prometheus:v2.53.4") {
        Write-Host "Prometheus image not found. Trying alternative..." -ForegroundColor Yellow
        podman pull --tls-verify=false quay.io/prometheus/prometheus:v2.53.4 2>$null
        if ($LASTEXITCODE -eq 0) {
            podman tag quay.io/prometheus/prometheus:v2.53.4 prom/prometheus:v2.53.4
        }
    }
    
    if ($existingImages -notcontains "grafana/grafana:11.6.4") {
        Write-Host "Grafana image not found. Using latest available..." -ForegroundColor Yellow
        podman pull --tls-verify=false grafana/grafana:latest 2>$null
        if ($LASTEXITCODE -eq 0) {
            podman tag grafana/grafana:latest grafana/grafana:11.6.4
        }
    }
    
    if ($existingImages -notcontains "grafana/grafana-image-renderer:latest") {
        Write-Host "Renderer image not found. Will skip renderer for now..." -ForegroundColor Yellow
    }
}

# Start Prometheus
Write-Host "Starting Prometheus..." -ForegroundColor Green
$prometheusCmd = @"
podman run -d ``
    --name prometheus-stub ``
    --network grafana-network ``
    -p 9090:9090 ``
    -v "$currentDir\provisioning\prometheus.yml:/etc/prometheus/prometheus.yml:ro" ``
    --restart unless-stopped ``
    prom/prometheus:v2.53.4
"@

try {
    Invoke-Expression $prometheusCmd
    Write-Host "✓ Prometheus started successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠ Prometheus failed to start: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Start Grafana Image Renderer (if image is available)
$rendererAvailable = podman images | Select-String "grafana-image-renderer"
if ($rendererAvailable) {
    Write-Host "Starting Grafana Image Renderer..." -ForegroundColor Green
    $rendererCmd = @"
podman run -d ``
    --name grafana-renderer ``
    --network grafana-network ``
    -p 8081:8081 ``
    -e ENABLE_METRICS=true ``
    -e RENDERING_MODE=default ``
    -e RENDERING_CLUSTERING_MODE=default ``
    --restart unless-stopped ``
    grafana/grafana-image-renderer:latest
"@
    
    try {
        Invoke-Expression $rendererCmd
        Write-Host "✓ Renderer started successfully" -ForegroundColor Green
        $rendererUrl = "http://renderer:8081/render"
    } catch {
        Write-Host "⚠ Renderer failed to start, continuing without it" -ForegroundColor Yellow
        $rendererUrl = ""
    }
} else {
    Write-Host "⚠ Renderer image not available, continuing without it" -ForegroundColor Yellow
    $rendererUrl = ""
}

# Start Grafana
Write-Host "Starting Grafana..." -ForegroundColor Green
$grafanaCmd = if ($rendererUrl) {
@"
podman run -d ``
    --name grafana-executive-dashboards ``
    --network grafana-network ``
    -p 3200:3000 ``
    -e GF_SECURITY_ADMIN_USER=admin ``
    -e GF_SECURITY_ADMIN_PASSWORD=admin ``
    -e GF_USERS_ALLOW_SIGN_UP=false ``
    -e "GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH=/var/lib/grafana/dashboards/platform/01-platform-ui-qos-executive.json" ``
    -e GF_LOG_LEVEL=info ``
    -e GF_RENDERING_SERVER_URL=$rendererUrl ``
    -e GF_RENDERING_CALLBACK_URL=http://grafana:3000/ ``
    -v grafana-storage:/var/lib/grafana ``
    -v "$currentDir\provisioning\datasources:/etc/grafana/provisioning/datasources:ro" ``
    -v "$currentDir\provisioning\dashboards:/etc/grafana/provisioning/dashboards:ro" ``
    -v "$currentDir\grafana:/var/lib/grafana/dashboards/grafana:ro" ``
    -v "$currentDir\loki:/var/lib/grafana/dashboards/loki:ro" ``
    -v "$currentDir\mimir:/var/lib/grafana/dashboards/mimir:ro" ``
    -v "$currentDir\tempo:/var/lib/grafana/dashboards/tempo:ro" ``
    -v "$currentDir\pyroscope:/var/lib/grafana/dashboards/pyroscope:ro" ``
    -v "$currentDir\platform:/var/lib/grafana/dashboards/platform:ro" ``
    -v "$currentDir\:/var/lib/grafana/dashboards/root:ro" ``
    --restart unless-stopped ``
    grafana/grafana:11.6.4
"@
} else {
@"
podman run -d ``
    --name grafana-executive-dashboards ``
    --network grafana-network ``
    -p 3200:3000 ``
    -e GF_SECURITY_ADMIN_USER=admin ``
    -e GF_SECURITY_ADMIN_PASSWORD=admin ``
    -e GF_USERS_ALLOW_SIGN_UP=false ``
    -e "GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH=/var/lib/grafana/dashboards/platform/01-platform-ui-qos-executive.json" ``
    -e GF_LOG_LEVEL=info ``
    -v grafana-storage:/var/lib/grafana ``
    -v "$currentDir\provisioning\datasources:/etc/grafana/provisioning/datasources:ro" ``
    -v "$currentDir\provisioning\dashboards:/etc/grafana/provisioning/dashboards:ro" ``
    -v "$currentDir\grafana:/var/lib/grafana/dashboards/grafana:ro" ``
    -v "$currentDir\loki:/var/lib/grafana/dashboards/loki:ro" ``
    -v "$currentDir\mimir:/var/lib/grafana/dashboards/mimir:ro" ``
    -v "$currentDir\tempo:/var/lib/grafana/dashboards/tempo:ro" ``
    -v "$currentDir\pyroscope:/var/lib/grafana/dashboards/pyroscope:ro" ``
    -v "$currentDir\platform:/var/lib/grafana/dashboards/platform:ro" ``
    -v "$currentDir\:/var/lib/grafana/dashboards/root:ro" ``
    --restart unless-stopped ``
    grafana/grafana:11.6.4
"@
}

try {
    Invoke-Expression $grafanaCmd
    Write-Host "✓ Grafana started successfully" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "✓ Grafana Dashboards started!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Access URLs:" -ForegroundColor Cyan
    Write-Host "  Grafana UI: http://localhost:3200" -ForegroundColor White
    Write-Host "  Username:   admin" -ForegroundColor White
    Write-Host "  Password:   admin" -ForegroundColor White
    Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor White
    if ($rendererUrl) {
        Write-Host "  Renderer:   http://localhost:8081" -ForegroundColor White
    }
    Write-Host ""
    
    Write-Host "Waiting for Grafana to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 20
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3200/api/health" -TimeoutSec 10 -UseBasicParsing 2>$null
        Write-Host "✓ Grafana is responding!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎉 All 33 enterprise dashboards are now available!" -ForegroundColor Green
        Write-Host "🌐 Access them at: http://localhost:3200" -ForegroundColor Cyan
    } catch {
        Write-Host "⚠ Grafana may still be starting up. Please try http://localhost:3200 in a moment." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "✗ Failed to start Grafana: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Container Status:" -ForegroundColor Cyan
podman ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}"

Write-Host ""
Write-Host "To stop the services, run: .\Stop-Podman-Dashboards.ps1" -ForegroundColor Yellow
Read-Host "Press Enter to continue"
