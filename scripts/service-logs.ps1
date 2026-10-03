# service-logs.ps1
# Helper to view/tail logs of the KiroGateway Windows Service (installed via NSSM).
#
# Usage:
#   .\scripts\service-logs.ps1                # live tail (follow) of stderr.log (app logs)
#   .\scripts\service-logs.ps1 -Stream stdout  # live tail of stdout.log
#   .\scripts\service-logs.ps1 -Stream both    # live tail of both stdout.log and stderr.log
#   .\scripts\service-logs.ps1 -Follow:$false  # just print last N lines, don't follow
#   .\scripts\service-logs.ps1 -Tail 100       # show last 100 lines before following
#
# Note: the gateway (loguru) writes its application logs to stderr by default,
# so stderr.log is usually what you want for request/response activity.

param(
    [ValidateSet("stdout", "stderr", "both")]
    [string]$Stream = "stderr",

    [int]$Tail = 20,

    [bool]$Follow = $true
)

$logDir = Join-Path $PSScriptRoot "..\service_logs"
$stdout = Join-Path $logDir "stdout.log"
$stderr = Join-Path $logDir "stderr.log"

switch ($Stream) {
    "stdout" { $targets = @($stdout) }
    "stderr" { $targets = @($stderr) }
    "both"   { $targets = @($stdout, $stderr) }
}

foreach ($t in $targets) {
    if (-not (Test-Path $t)) {
        Write-Warning "Log file not found: $t (service may not have started yet)"
    }
}

if ($Follow) {
    Get-Content -Path $targets -Tail $Tail -Wait
} else {
    Get-Content -Path $targets -Tail $Tail
}
