# Jupyter Notebook Container

A Docker-based Jupyter Lab environment with CUDA support for machine learning workloads.

## Features

- CUDA 12.6 support with GPU acceleration
- Jupyter Lab interface
- Python environment managed with `uv`
- Built-in terminal runs zsh with oh-my-zsh and Powerlevel10k

## Terminal

The Jupyter Lab terminal uses zsh instead of the default `sh`:

- Shell is selected via `--ServerApp.terminado_settings` in `docker-compose.yml`
- Plugins: `git`, `sudo`, `zsh-completions`, `zsh-autosuggestions`, `zsh-syntax-highlighting`
- Prompt config lives at `docker/cuda-126/p10k.zsh`, shell config at `docker/cuda-126/zshrc`
- `/app/.venv` is activated automatically, so `python` and `pip` match the kernel environment
- Terminals start in `ROOT_DIR` (the container's `working_dir`)

Powerlevel10k needs a Nerd Font. Set one in Jupyter Lab under
*Settings → Terminal → Font family* (e.g. `MesloLGS NF`), otherwise the prompt
shows placeholder glyphs.


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
