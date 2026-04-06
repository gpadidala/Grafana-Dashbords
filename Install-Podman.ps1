# PowerShell Podman Installation Script
# Run this in PowerShell: .\Install-Podman.ps1

Write-Host "Installing Podman for user: $env:USERNAME..." -ForegroundColor Green

# Check if Podman is already installed
Write-Host "Checking if Podman is already installed..."
try {
    $podmanVersion = podman version
    Write-Host "✓ Podman is already installed!" -ForegroundColor Green
    Write-Host $podmanVersion
    goto configure
} catch {
    Write-Host "Podman not found. Installing for current user only..." -ForegroundColor Yellow
}

# Try winget first
Write-Host "Trying winget first..."
try {
    winget install --scope user RedHat.Podman
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Podman installed via winget" -ForegroundColor Green
    } else {
        throw "Winget installation failed"
    }
} catch {
    Write-Host "Winget failed. Downloading Podman directly..." -ForegroundColor Yellow
    
    # Create temporary directory
    $tempDir = "$env:TEMP\podman-install"
    if (!(Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir | Out-Null
    }
    Set-Location $tempDir
    
    # Download Podman installer
    Write-Host "Downloading Podman installer..."
    try {
        Invoke-WebRequest -Uri "https://github.com/containers/podman/releases/download/v5.7.1/podman-5.7.1.msi" -OutFile "podman-installer.msi"
        
        if (Test-Path "podman-installer.msi") {
            Write-Host "Installing Podman for current user..."
            Start-Process -FilePath "msiexec" -ArgumentList "/i", "podman-installer.msi", "/quiet", "ALLUSERS=2", "MSIINSTALLPERUSER=1" -Wait
            Start-Sleep -Seconds 30
            Set-Location "c:\Users\gpadi40\Gopal\ekscode\mcp-grafana\Grafana-Dashbords"
            Remove-Item -Path $tempDir -Recurse -Force
        } else {
            throw "Download failed"
        }
    } catch {
        Write-Host "✗ Download failed. Please install Podman manually from https://podman.io/" -ForegroundColor Red
        Read-Host "Press Enter to continue"
        exit 1
    }
}

# Setup user-specific directories
Write-Host "Setting up user-specific directories..."
$directories = @(
    "$env:APPDATA\containers",
    "$env:USERPROFILE\.local\share\containers\podman\machine",
    "$env:USERPROFILE\.config\containers\podman\machine"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Add Podman to user PATH
Write-Host "Adding Podman to user PATH..."
$podmanPaths = @(
    "$env:LocalAppData\Programs\Podman",
    "C:\Program Files\RedHat\Podman"
)

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathAdded = $false

foreach ($podmanPath in $podmanPaths) {
    if (Test-Path $podmanPath) {
        if ($currentPath -notlike "*$podmanPath*") {
            $newPath = $currentPath + ";" + $podmanPath
            [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
            $env:Path = $env:Path + ";" + $podmanPath
            Write-Host "✓ Added Podman to user PATH: $podmanPath" -ForegroundColor Green
            $pathAdded = $true
            break
        }
    }
}

if (-not $pathAdded) {
    Write-Host "Warning: Podman executable path not found" -ForegroundColor Yellow
}

# Configure Podman
:configure
Write-Host "Configuring Podman for user $env:USERNAME..." -ForegroundColor Green

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check if podman is now available
try {
    podman version | Out-Null
    Write-Host "✓ Podman is accessible" -ForegroundColor Green
} catch {
    Write-Host "Podman still not found in PATH. Trying alternative paths..." -ForegroundColor Yellow
    
    $altPaths = @(
        "C:\Program Files\RedHat\Podman\podman.exe",
        "$env:LocalAppData\Programs\Podman\podman.exe"
    )
    
    $found = $false
    foreach ($path in $altPaths) {
        if (Test-Path $path) {
            $pathDir = Split-Path $path
            $env:Path = $env:Path + ";" + $pathDir
            [Environment]::SetEnvironmentVariable("Path", ([Environment]::GetEnvironmentVariable("Path", "User") + ";" + $pathDir), "User")
            $found = $true
            break
        }
    }
    
    if (-not $found) {
        Write-Host "✗ Podman executable not found. Please restart your computer and try again." -ForegroundColor Red
        Read-Host "Press Enter to continue"
        exit 1
    }
}

# Create user-specific Podman machine
Write-Host "Creating user-specific Podman machine..."
try {
    podman machine init --cpus 4 --memory 4096 --disk-size 20
} catch {
    Write-Host "Machine init failed, trying with default settings..." -ForegroundColor Yellow
    podman machine init
}

# Start Podman machine
Write-Host "Starting Podman machine..."
podman machine start

# Create user configuration files
Write-Host "Creating user configuration files..."
$configContent = @"
[engine]
runtime = "crun"
image_default_transport = "docker://"
[network]
default_network = "podman"
"@

$configPath = "$env:APPDATA\containers\containers.conf"
Set-Content -Path $configPath -Value $configContent

# Test Podman installation
Write-Host "Testing Podman installation..."
try {
    podman version
    Write-Host "✓ Podman installed and configured successfully for user $env:USERNAME!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Restart your terminal or PowerShell"
    Write-Host "2. Run: .\start-podman-dashboards.bat to build and start the application"
} catch {
    Write-Host "✗ Podman installation failed" -ForegroundColor Red
    Write-Host "Please check the error messages above"
}

Read-Host "Press Enter to continue"
