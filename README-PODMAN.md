# Grafana Dashboards - Podman Setup Guide

This guide explains how to run the Enterprise Grafana Observability Platform Dashboards using **Podman** instead of Docker on Windows.

## Prerequisites

- Windows 10/11
- PowerShell or Command Prompt
- Internet connection for downloading images

## Installation

### 1. Install Podman

From the parent directory, run:
```batch
..\install-podman.bat
```

This script will:
- Check if Podman is already installed
- Install Podman via winget or direct download
- Configure Podman for the current user
- Set up a Podman machine with proper resources
- Configure user-specific settings

### 2. Setup Podman Environment

Navigate to the Grafana-Dashboards directory and run:
```batch
setup-podman.bat
```

This will:
- Verify Podman installation
- Install podman-compose (if Python/pip available)
- Start the Podman machine
- Test basic functionality

## Running the Dashboards

### Method 1: Using Podman Compose (Recommended)

```batch
start-podman-dashboards.bat
```

This method uses `podman-compose` to manage all services together, similar to Docker Compose.

### Method 2: Individual Podman Commands (Fallback)

If podman-compose is not available or working:
```batch
start-podman-dashboards-alt.bat
```

This method starts each container individually using native Podman commands.

## Accessing the Dashboards

Once started, access the dashboards at:
- **Grafana UI**: http://localhost:3200
- **Username**: admin
- **Password**: admin
- **Prometheus**: http://localhost:9090
- **Renderer**: http://localhost:8081

## Services Included

The Podman setup includes the same services as the Docker version:

| Service | Container Name | Port | Purpose |
|---------|---------------|------|---------|
| Grafana | grafana-executive-dashboards | 3200 | Main dashboard UI |
| Grafana Renderer | grafana-renderer | 8081 | PDF/PNG export |
| Prometheus | prometheus-stub | 9090 | Sample metrics source |

## Managing Services

### Stop Services

**Method 1 (Compose):**
```batch
stop-podman-dashboards.bat
```

**Method 2 (Individual):**
```batch
stop-podman-dashboards-alt.bat
```

### View Running Containers

```batch
podman ps
```

### View Logs

```batch
# View all service logs
podman logs grafana-executive-dashboards
podman logs grafana-renderer
podman logs prometheus-stub

# Follow logs in real-time
podman logs -f grafana-executive-dashboards
```

### Restart Services

```batch
# Stop first
stop-podman-dashboards.bat
# Then start
start-podman-dashboards.bat
```

## Validation

Test that all dashboards are working correctly:
```batch
validate-dashboards-podman.bat
```

This will:
- Check Grafana connectivity
- Validate dashboard configurations
- Report any issues

## Data Persistence

Dashboard data is stored in a Podman volume named `grafana-storage`. This persists between container restarts.

To remove all data and start fresh:
```batch
podman volume rm grafana-storage
```

## Troubleshooting

### Podman Machine Issues

If the Podman machine fails to start:
```batch
# Stop and remove existing machine
podman machine stop
podman machine rm

# Create new machine with different settings
podman machine init --cpus 2 --memory 2048 --disk-size 10
podman machine start
```

### Port Conflicts

If ports 3200, 8081, or 9090 are already in use, edit `podman-compose.yml` and change the port mappings:
```yaml
ports:
  - "3201:3000"  # Change 3200 to 3201
```

### Network Issues

If containers cannot communicate:
```batch
# Recreate the network
podman network rm grafana-network
podman network create grafana-network
```

### Permission Issues

If volume mounts fail:
```batch
# Ensure the current directory is accessible
cd /d "C:\Users\%USERNAME%\path\to\Grafana-Dashboards"
```

### podman-compose Not Available

If podman-compose installation fails, use the alternative scripts:
- `start-podman-dashboards-alt.bat`
- `stop-podman-dashboards-alt.bat`

These use individual `podman run` commands instead of compose.

## Performance Optimization

### Adjust Resource Limits

Edit the Podman machine configuration for better performance:
```batch
# Stop the machine
podman machine stop

# Remove and recreate with more resources
podman machine rm
podman machine init --cpus 4 --memory 8192 --disk-size 50
podman machine start
```

### Cleanup Unused Resources

Regularly clean up unused images and containers:
```batch
# Remove stopped containers
podman container prune

# Remove unused images
podman image prune

# Remove unused volumes
podman volume prune
```

## Differences from Docker

1. **Machine Required**: Podman on Windows requires a Linux VM (machine)
2. **Rootless**: Runs without elevated privileges by default
3. **No Daemon**: Podman doesn't use a background daemon
4. **Compose**: Requires separate podman-compose installation

## Files Created

The Podman setup creates these additional files:

| File | Purpose |
|------|---------|
| `podman-compose.yml` | Podman compose configuration |
| `setup-podman.bat` | One-time environment setup |
| `start-podman-dashboards.bat` | Start services (compose method) |
| `start-podman-dashboards-alt.bat` | Start services (individual commands) |
| `stop-podman-dashboards.bat` | Stop services (compose method) |
| `stop-podman-dashboards-alt.bat` | Stop services (individual commands) |
| `validate-dashboards-podman.bat` | Dashboard validation |
| `README-PODMAN.md` | This file |

## Support

For Podman-specific issues:
1. Check the Podman machine status: `podman machine list`
2. View container logs: `podman logs <container-name>`
3. Verify network connectivity: `podman network ls`
4. Test basic Podman functionality: `podman run --rm hello-world`

For dashboard issues, use the same troubleshooting steps as the Docker version.
