# Opencode Development Environment

This repository contains a Dockerfile that sets up a development environment for [Opencode](https://opencode.ai), an AI-powered development assistant.

The image ships **OpenCode 2** (installed from the [v2 installer](https://opencode.ai/v2/install)). It is
rebuilt daily by GitHub Actions, which pins the image tag to the newest stable OpenCode 2 release — OpenCode 2
is no longer tagged `latest` upstream, so the image tag (e.g. `:2.2.6`) is the authoritative version indicator.

## What is Opencode?

Opencode is an intelligent development assistant that helps developers write code, debug, and refactor applications. It leverages AI to provide contextual assistance throughout the development lifecycle.

## Features

- Pre-configured Opencode development environment
- Alpine Linux base with minimal footprint
- User-friendly development setup with proper permissions
- Ready-to-use opencode CLI tool
- `curl`, `git`, and `gh` (GitHub CLI) pre-installed

## GitHub Access with `gh`

The GitHub CLI reads the `GH_TOKEN` environment variable automatically. If your
`~/.opencode.env` file (loaded via `--env-file`) contains a `GH_TOKEN`, `gh` is
authenticated out of the box — no `gh auth login` needed:

```bash
# In ~/.opencode.env
GH_TOKEN=ghp_your_token_here
```

```bash
# Then, inside the container:
gh issue view 123 -R owner/repo
gh api /user
```

Note: `gh` only updates when a new opencode release triggers an image rebuild
(the image tag is keyed to the opencode version).

## Running the Container

```bash
docker run --rm -it \
  --env-file "$HOME/.opencode.env" \
  -v "$HOME/.config/opencode/opencode.json:/home/coder/.config/opencode/opencode.json:ro" \
  -v "$(pwd):/workspace:rw" \
  ghcr.io/grvlbit/opencode-container:latest
```

> [!NOTE]
> Existing OpenCode 1 configuration keeps working: OpenCode 2 reads the same
> config locations (`~/.config/opencode/opencode.json`, project `opencode.json`,
> `.opencode/`, etc.) and auto-migrates the V1 TUI config (`tui.json`) to the new
> global `cli.json` on first run. See the
> [V1 → V2 migration guide](https://opencode.ai/docs/migrate-v1/) for the full
> picture (plugins and the server API changed and need porting).

## Building the Image

```bash
docker build -t opencode-container .
```

### Customization

You can customize the UID/GID by passing build arguments:

```bash
docker build --build-arg UID=1001 --build-arg GID=1001 -t opencode-container .
```

or inject your local UID/GID using:

```bash
docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --no-cache -t opencode-container .
```

To build against a specific OpenCode 2 release instead of the newest one, pass
`OPENCODE_VERSION`:

```bash
docker build --build-arg OPENCODE_VERSION=2.2.6 -t opencode-container .
```

## Deployment Plan

This repository includes automation for keeping the Docker image updated and deployed using GitHub Actions with GitHub Container Registry (GHCR):

- Checks for updates daily at 2 AM UTC
- Rebuilds the Docker image when a new stable OpenCode 2 release is detected (tagged `latest` and the version, e.g. `:2.2.6`)
- Pushes the updated image to GitHub Container Registry

## License

This project is licensed under the MIT License - see the LICENSE file for details.
