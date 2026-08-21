# Opencode Development Environment

This repository contains a Dockerfile that sets up a development environment for [Opencode](https://opencode.ai), an AI-powered development assistant.

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
  ghcr.io/grvlbit/opencode-container:latest'
```

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

## Deployment Plan

This repository includes automation for keeping the Docker image updated and deployed using GitHub Actions with GitHub Container Registry (GHCR):

- Checks for updates daily at 2 AM UTC
- Rebuilds the Docker image with the latest opencode version
- Pushes the updated image to GitHub Container Registry

## License

This project is licensed under the MIT License - see the LICENSE file for details.
