# python-wrapper
### Environment stability wrapper for general Python executions

A base template project providing reproducible Python execution environments via two independent methods:

1. **Bare metal** - `shell/run.sh` runs directly on the local machine
2. **Containerized** - `shell/run_docker.sh` builds, maintains, and runs a Docker container that executes `shell/run.sh`

**The `python/main.py` entry point is a placeholder — replace it with production code. This project is intended as a base for other Python projects.**

---

### Project Structure
```
python-wrapper/
├── Dockerfile                          # Docker image definition
├── requirements.txt                    # Python dependencies (empty by default)
├── configuration/
│   ├── environment.properties          # Configuration / environment variables
│   └── README.md                       # Environment variable documentation
├── python/
│   └── main.py                         # Python application entry point
└── shell/
    ├── run.sh                          # Core bare-metal execution script
    ├── run_docker.sh                   # Docker orchestration script
    ├── build_image.sh                  # Docker image build script
    ├── helpers.sh                      # Shared helper functions (repo root, env sourcing, SHA, venv path)
    ├── pre_run.sh                      # Pre-execution hook (placeholder)
    └── post_run.sh                     # Post-execution hook (placeholder)
```

---

### Key Features

- **Dependency hashing** — SHA-256 hash of `requirements.txt` (first 16 chars) is appended to the venv directory name (e.g. `py_venv_a1b2c3d4e5f6g7h8`). When requirements change, a new venv is created automatically. SHA calculation is portable across Linux (`sha256sum`), macOS (`shasum`), and any system with `openssl`.
- **Smart rebuilds** — Docker images only rebuild when the git HEAD changes, the image is missing, or `FORCE_DOCKER_REBUILD=TRUE`. Venvs only rebuild when requirements change or `FORCE_VENV_REBUILD=TRUE`.
- **Pre/post hooks** — `shell/pre_run.sh` and `shell/post_run.sh` run before and after `python/main.py` for custom setup/teardown logic.
- **Configurable logging** — Console and optional file logging via `LOG_LEVEL` and `LOG_LOCATION` environment variables.

---

### Order of Execution

#### Docker path (`shell/run_docker.sh`)
1. Validate `docker` is installed
2. Source environment variables from `configuration/environment.properties`
3. Calculate `requirements.txt` SHA-256 hash for venv versioning
4. Determine if rebuild is needed:
   - Docker image does not exist
   - Repository HEAD has changed (new git commit)
   - `FORCE_DOCKER_REBUILD` is set to `TRUE`
5. If rebuild needed → **execute `shell/build_image.sh`**:
   1. Source environment variables
   2. Deactivate and delete any existing bare-metal venv
   3. Pull latest `python:latest` image (if `AUTO_UPDATE=TRUE`)
   4. Remove old Docker image
   5. Build new Docker image
6. Otherwise → delete any existing bare-metal venv to prevent conflicts
7. Run disposable container → executes `shell/run.sh` inside container

#### Bare-metal path (`shell/run.sh`)
1. Determine repository root (via `git` or script path fallback)
2. Source environment variables from `configuration/environment.properties`
3. Execute `shell/pre_run.sh`
4. Calculate `requirements.txt` SHA-256 hash and derive venv name
5. Create/activate Python venv (or reuse existing if hash matches and `FORCE_VENV_REBUILD != TRUE`)
6. Install/upgrade pip and packages from `requirements.txt`
7. Optionally refreeze requirements (if `REFREEZE_REQUIREMENTS=TRUE`)
8. **Execute `python/main.py`** with any command-line arguments
9. Execute `shell/post_run.sh`

---

### Configuration

Environment variables are defined in `configuration/environment.properties`. See [`configuration/README.md`](configuration/README.md) for full documentation.

| Variable | Description | Default |
|---|---|---|
| `PYVENV_LOCATION` | Base name for the Python venv directory (hash appended) | `py_venv` |
| `LOG_LEVEL` | Python logging verbosity | `INFO` |
| `LOG_LOCATION` | Path to log file (omit for console-only) | *(unset)* |
| `REFREEZE_REQUIREMENTS` | Overwrite `requirements.txt` with current pip freeze | `FALSE` |
| `DOCKER_NAME` | Docker image name | `python-wrapper` |
| `FORCE_DOCKER_REBUILD` | Force Docker image rebuild on every run | `TRUE` |
| `FORCE_VENV_REBUILD` | Force venv rebuild on every run | `TRUE` |
| `AUTO_UPDATE` | Pull latest Python Docker image before builds | `TRUE` |
