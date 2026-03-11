# Development Environment Control

**Trigger**: `/dev $ARGUMENTS`

Control the local development environment: **$ARGUMENTS**

## Quick Reference

```bash
./scripts/dev-up.sh          # Start everything
./scripts/dev-up.sh --stop   # Stop everything
./scripts/dev-up.sh --status # Check status
```

## Actions

Parse `$ARGUMENTS` and execute the appropriate action:

| Input | Action |
|-------|--------|
| `up`, `start`, (empty) | Start full stack |
| `down`, `stop` | Stop all services |
| `status`, `ps` | Show status |
| `restart`, `refresh` | Stop then start |
| `docker` | Start only Docker services |
| `logs` | Open Dozzle log viewer |

## Execution Protocol

### For `up`, `start`, or no arguments:

```bash
./scripts/dev-up.sh
```

This starts:
- **Docker**: PostgreSQL (5433), Redis (6379), Dozzle (8080)
- **QF Chain**: Local solochain at ws://localhost:9944
- **Backend**: FastAPI at http://localhost:8000
- **Frontend**: Vite at http://localhost:5173

Each service opens in its own Terminal tab.

### For `down` or `stop`:

```bash
./scripts/dev-up.sh --stop
```

### For `status` or `ps`:

```bash
./scripts/dev-up.sh --status
```

### For `restart` or `refresh`:

```bash
./scripts/dev-up.sh --stop && sleep 2 && ./scripts/dev-up.sh
```

### For `docker`:

```bash
./scripts/dev-up.sh --docker-only
```

### For `logs`:

```bash
open http://localhost:8080
```

## Prerequisites

The script will check for:
- Docker Desktop running
- `qf-solochain` repo at `~/Documents/quantumFusion/qf-solochain`
- `server/.env.local` configured

## Service URLs

After startup:
- **Frontend**: http://localhost:5173
- **API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **Dozzle Logs**: http://localhost:8080
- **Chain RPC**: ws://localhost:9944

## Troubleshooting

If services fail to start:
```bash
# Check what's running
./scripts/dev-up.sh --status

# Check health of services
python scripts/check-local-env.py

# View Docker logs
docker compose -f docker-compose.dev.yml logs
```

## Examples

```bash
/dev              # Start everything
/dev up           # Start everything
/dev stop         # Stop everything
/dev restart      # Restart everything
/dev status       # Check what's running
/dev docker       # Just start Docker services
```
