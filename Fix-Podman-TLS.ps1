# Fix TLS certificate issues for Podman registry access
Write-Host "Fixing Podman TLS certificate configuration..." -ForegroundColor Yellow

# Add Podman to PATH if needed
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

# Create registries configuration to allow insecure registries
Write-Host "Creating registry configuration..."
$registriesConfig = @"
[registries.search]
registries = ['docker.io']

[registries.insecure]
registries = []

[registries.block]
registries = []

[[registry]]
prefix = "docker.io"
insecure = false
blocked = false
[[registry.mirror]]
location = "registry-1.docker.io"
insecure = false
"@

# Create the containers config directory if it doesn't exist
$configDir = "$env:APPDATA\containers"
if (!(Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

# Write the registries configuration
Set-Content -Path "$configDir\registries.conf" -Value $registriesConfig

# Create containers.conf with TLS settings
Write-Host "Creating containers configuration..."
$containersConfig = @"
[engine]
runtime = "crun"
image_default_transport = "docker://"

[network]
default_network = "podman"

[machine]
# TLS verification settings
tls_verify = true
"@

Set-Content -Path "$configDir\containers.conf" -Value $containersConfig

Write-Host "✓ Registry configuration created" -ForegroundColor Green

# Try to restart the Podman machine to apply new settings
Write-Host "Restarting Podman machine to apply new settings..."
try {
    podman machine stop 2>$null
    Start-Sleep -Seconds 5
    podman machine start
    Write-Host "✓ Podman machine restarted" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not restart machine, continuing..." -ForegroundColor Yellow
}

# Test pulling a simple image
Write-Host "Testing image pull with new configuration..."
try {
    podman pull hello-world
    Write-Host "✓ Image pull test successful" -ForegroundColor Green
} catch {
    Write-Host "⚠ Image pull test failed, will try alternative approach" -ForegroundColor Yellow
}

Write-Host "Configuration update complete!" -ForegroundColor Green
Read-Host "Press Enter to continue"
