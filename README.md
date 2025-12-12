# Jupyter Notebook Container

A Docker-based Jupyter Lab environment with CUDA support for machine learning workloads.

## Features

- CUDA 12.6 support with GPU acceleration
- Jupyter Lab interface
- Python environment managed with `uv`

## Quick Start

1. Copy environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and set your `JUPYTER_TOKEN`

3. Build and start the container:
   ```bash
   docker compose up -d --build
   ```

4. Access Jupyter Lab at `http://localhost:8571`

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `HOST_PORT` | Port exposed on host | 8571 |
| `CONTAINER_PORT` | Internal container port | 8888 |
| `JUPYTER_TOKEN` | Authentication token | - |
| `ROOT_DIR` | Jupyter root directory | /jupyter |

## Requirements

- Docker with NVIDIA Container Toolkit
- NVIDIA GPU with CUDA support
