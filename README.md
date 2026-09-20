# code-server ML Container

A Docker-based [code-server](https://github.com/coder/code-server) (VS Code in the browser)
environment with CUDA support for machine learning workloads.

## Features

- CUDA 12.6 support with GPU acceleration
- VS Code UI with notebooks (Jupyter extension, kernels run from `/app/.venv`)
- Python environment managed with `uv`
- `ty` language server and `ruff` lint/format
- Built-in terminal runs zsh with oh-my-zsh and Powerlevel10k
- HTTPS via a dedicated Caddy container (automatic certificates)

## Architecture

```
nginx-proxy (SNI passthrough :443) --> jupyter-caddy (TLS, ACME) --> jupyter-code-server:8080
```

No host port is published. `../network/nginx-proxy` routes by SNI to `jupyter-caddy`,
which owns the certificate (TLS-ALPN-01) and proxies to code-server. HTTPS is required:
VS Code webviews, which render notebook outputs, only work in a secure context.

## Persistence

The home directory and the extensions directory are named volumes, so the container
behaves like a real machine: what you change at runtime survives rebuilds.

| Volume | Path | Contents |
|--------|------|----------|
| `home` | `/root` | zsh config (`.zshrc`, `.p10k.zsh`) and history, code-server settings and keybindings, Claude Code login and settings, git / ssh config, ... |
| `code_server_extensions` | `/opt/code-server/extensions` | Extensions (installed or updated from the UI) |

`./notebooks` (workspace) and `./notebooks/.cache` (`/root/.cache`) are bind mounts.

The image only provides the **initial contents**: Docker copies `/root` and the default
extensions ([Open VSX](https://open-vsx.org), see `docker/cuda-126/dockerfile`) into a volume
when it is first created. After that the volume wins, so later changes to
`docker/cuda-126/zshrc`, `p10k.zsh` or `code-server/settings.json` do not reach an existing
volume; edit the files inside the container instead, or reset the volume:

```bash
docker compose down
docker volume rm jupyter_home          # or jupyter_code_server_extensions
docker compose up -d
```

`docker compose down -v` deletes these volumes (and the TLS certificate); avoid `-v`.

Not persisted: packages installed into `/app/.venv` at runtime. Add them to
`docker/cuda-126/pyproject.toml` (`uv add`) and rebuild. The uv-managed interpreter lives in
`/opt/uv/python`, outside the home volume, so image updates cannot leave the venv pointing
at a stale interpreter.

## Terminal

The integrated terminal uses zsh:

- Plugins: `git`, `sudo`, `zsh-completions`, `zsh-autosuggestions`, `zsh-syntax-highlighting`
- Defaults come from `docker/cuda-126/p10k.zsh` and `docker/cuda-126/zshrc`; at runtime they are
  `~/.p10k.zsh` and `~/.zshrc` in the `home` volume (`p10k configure` persists)
- `/app/.venv` is activated automatically, so `python` and `pip` match the kernel environment
- Terminals start in `ROOT_DIR` (the container's `working_dir`)

Powerlevel10k needs a Nerd Font installed on the client machine. The default settings use
`MesloLGS NF` (`terminal.integrated.fontFamily`); without it the prompt shows placeholder glyphs.

## Quick Start

1. Copy environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and set `DOMAIN`, `ACME_EMAIL` and `PASSWORD`

3. Point a grey-cloud (DNS only) record for `DOMAIN` at this host, and route it in
   `../network/nginx-proxy/conf/routes/jupyter.conf` (see that directory's README):
   ```
   jupyter.yuufeng.com jupyter-caddy:443;
   ```
   ```bash
   docker kill -s HUP nginx-proxy   # graceful reload, no dropped connections
   ```

4. Build and start the containers:
   ```bash
   docker compose up -d --build
   ```

5. Open `https://<DOMAIN>` and log in with `PASSWORD`

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `DOMAIN` | Public hostname served by Caddy | - |
| `ACME_EMAIL` | Contact email for certificate issuance | - |
| `PASSWORD` | code-server login password | - |
| `ROOT_DIR` | Folder opened by code-server | /jupyter |
| `HUGGINGFACE_HUB_TOKEN` | Optional Hugging Face token | - |

## Requirements

- Docker with NVIDIA Container Toolkit
- NVIDIA GPU with CUDA support
- The external `proxy` Docker network (created by `../network/caddy-proxy`)
