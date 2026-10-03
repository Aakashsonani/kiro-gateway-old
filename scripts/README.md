# KiroGateway Windows Service

The gateway runs as a Windows Service named **KiroGateway**, installed via [NSSM](https://nssm.cc/).
It auto-starts on boot (no login required) and auto-restarts if the process crashes.

- Binary: `.venv\Scripts\python.exe main.py`
- Working directory: project root
- Startup type: Automatic
- Runs as: LocalSystem
- Env vars set on the service: `PYTHONIOENCODING=utf-8`, `PYTHONUTF8=1`
  (required — the startup banner prints an emoji that crashes under the service's
  default console codepage without these)
- Logs: `service_logs\stdout.log` / `service_logs\stderr.log` (auto-rotated at 10MB)
  - App logs (loguru) go to **stderr.log**, not stdout.log

## View logs

```powershell
# Live tail of app logs (default: stderr, follows new lines)
.\scripts\service-logs.ps1

# Live tail of stdout only
.\scripts\service-logs.ps1 -Stream stdout

# Live tail of both stdout and stderr interleaved
.\scripts\service-logs.ps1 -Stream both

# Just show the last 100 lines, don't follow
.\scripts\service-logs.ps1 -Tail 100 -Follow:$false
```

Or directly with PowerShell, no script needed:

```powershell
Get-Content "service_logs\stderr.log" -Wait -Tail 20
```

Press `Ctrl+C` to stop following.

## Manage the service

```powershell
Get-Service KiroGateway                 # check status
Start-Service KiroGateway                # start (needs admin)
Stop-Service KiroGateway                 # stop (needs admin)
Restart-Service KiroGateway              # restart (needs admin)
```

Admin-elevated one-liner if you're in a non-elevated shell:

```powershell
Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `"Restart-Service KiroGateway`""
```

## Troubleshooting

If the service shows status `Paused`, it usually means NSSM is in a restart backoff
loop because the process keeps exiting quickly. Check `service_logs\stderr.log`
(or the rotated `stderr-<timestamp>.log` files) for the actual Python traceback.

Check Windows Event Viewer → Windows Logs → Application, filtered for "KiroGateway",
for service-level start/stop/restart/crash events.
