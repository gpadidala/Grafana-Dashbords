# Restart Grafana with correct dashboard mounts
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Restarting Grafana with Dashboard Fix" -ForegroundColor Cyan
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

# Stop and remove existing Grafana container
Write-Host "Stopping existing Grafana container..."
podman stop grafana-executive-dashboards 2>$null | Out-Null
podman rm grafana-executive-dashboards 2>$null | Out-Null

$currentDir = Get-Location

# Check what dashboard directories exist
Write-Host "Checking dashboard directories..."
$dashboardDirs = @("grafana", "loki", "mimir", "tempo", "pyroscope", "platform")
foreach ($dir in $dashboardDirs) {
    if (Test-Path $dir) {
        $count = (Get-ChildItem "$dir\*.json" -ErrorAction SilentlyContinue).Count
        Write-Host "✓ Found $count dashboards in $dir/" -ForegroundColor Green
    } else {
        Write-Host "⚠ Directory $dir/ not found" -ForegroundColor Yellow
    }
}

# Check for JSON files in root directory
$rootJsons = (Get-ChildItem "*.json" -ErrorAction SilentlyContinue).Count
if ($rootJsons -gt 0) {
    Write-Host "✓ Found $rootJsons dashboard files in root directory" -ForegroundColor Green
}

# Start new Grafana container with proper volume mounts
Write-Host "Starting Grafana with all dashboard directories mounted..."
$grafanaCmd = @"
podman run -d ``
    --name grafana-executive-dashboards ``
    --network grafana-network ``
    -p 3200:3000 ``
    -e GF_SECURITY_ADMIN_USER=admin ``
    -e GF_SECURITY_ADMIN_PASSWORD=admin ``
    -e GF_USERS_ALLOW_SIGN_UP=false ``
    -e "GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH=/var/lib/grafana/dashboards/platform/01-platform-ui-qos-executive.json" ``
    -e GF_LOG_LEVEL=debug ``
    -e GF_LOG_FILTERS=provisioning:debug ``
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

try {
    Invoke-Expression $grafanaCmd
    Write-Host "✓ Grafana restarted successfully!" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Waiting for Grafana to initialize..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    
    # Check if Grafana is responding
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3200/api/health" -TimeoutSec 10 -UseBasicParsing 2>$null
        Write-Host "✓ Grafana is responding!" -ForegroundColor Green
        
        # Check for provisioned dashboards
        Write-Host ""
        Write-Host "Checking dashboard provisioning..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        
        try {
            $dashboardsResponse = Invoke-WebRequest -Uri "http://localhost:3200/api/search?type=dash-folder" -Credential (New-Object System.Management.Automation.PSCredential("admin", (ConvertTo-SecureString "admin" -AsPlainText -Force))) -TimeoutSec 10 -UseBasicParsing 2>$null
            Write-Host "✓ Dashboard API is accessible" -ForegroundColor Green
        } catch {
            Write-Host "⚠ Dashboard API check failed, but Grafana is running" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "🎉 Grafana Dashboards are now available!" -ForegroundColor Green
        Write-Host "🌐 Access them at: http://localhost:3200" -ForegroundColor Cyan
        Write-Host "👤 Username: admin" -ForegroundColor White
        Write-Host "🔑 Password: admin" -ForegroundColor White
        Write-Host ""
        Write-Host "Expected dashboard folders:" -ForegroundColor Cyan
        Write-Host "  • Grafana (Grafana admin dashboards)" -ForegroundColor White
        Write-Host "  • Loki (Log analytics dashboards)" -ForegroundColor White
        Write-Host "  • Mimir (Metrics storage dashboards)" -ForegroundColor White
        Write-Host "  • Tempo (Tracing dashboards)" -ForegroundColor White
        Write-Host "  • Pyroscope (Profiling dashboards)" -ForegroundColor White
        Write-Host "  • Platform & Executive (Executive summary dashboards)" -ForegroundColor White
        
    } catch {
        Write-Host "⚠ Grafana may still be starting up. Please try http://localhost:3200 in a moment." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "✗ Failed to start Grafana: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Check the container logs with: podman logs grafana-executive-dashboards" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Container Status:" -ForegroundColor Cyan
podman ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}" | Where-Object { $_ -match "grafana" }

Read-Host "Press Enter to continue"
