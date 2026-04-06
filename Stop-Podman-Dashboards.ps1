# PowerShell script to stop Grafana Dashboards
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Stopping Grafana Dashboards (Podman)" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Add common Podman paths if needed
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

Write-Host "Stopping containers..."
podman stop grafana-executive-dashboards grafana-renderer prometheus-stub 2>$null | Out-Null

Write-Host "Removing containers..."
podman rm grafana-executive-dashboards grafana-renderer prometheus-stub 2>$null | Out-Null

Write-Host "Removing network..."
podman network rm grafana-network 2>$null | Out-Null

Write-Host ""
$cleanup = Read-Host "Do you want to remove data volumes? This will delete all Grafana data (y/N)"
if ($cleanup -eq "y" -or $cleanup -eq "Y") {
    Write-Host "Removing volumes..."
    podman volume rm grafana-storage 2>$null | Out-Null
    Write-Host "✓ Volumes removed - all data deleted" -ForegroundColor Green
} else {
    Write-Host "Volumes preserved for next startup" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✓ Grafana Dashboards stopped successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "To restart, run: .\Start-Podman-Dashboards.ps1" -ForegroundColor Cyan
Read-Host "Press Enter to continue"
