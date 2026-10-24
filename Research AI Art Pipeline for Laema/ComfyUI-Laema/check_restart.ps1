$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$queue=Invoke-RestMethod -Uri 'http://127.0.0.1:8188/queue'
if ($queue.queue_running.Count -gt 0 -or $queue.queue_pending.Count -gt 0) { throw 'A generation is active; restart check will not interrupt it.' }
$before=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'server.local.json') -Raw | ConvertFrom-Json
$saved=@{}
Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'user\default\workflows') -Filter '*.json' -File | ForEach-Object {
    $saved[$_.Name]=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
}
& $env:ComSpec /d /c (Join-Path $repoRoot 'Stop-Laema-Art.cmd')
if ($LASTEXITCODE -ne 0) { throw 'Stop launcher failed.' }
$stillRunning=$false
try { $null=Invoke-RestMethod -Uri 'http://127.0.0.1:8188/system_stats' -TimeoutSec 2; $stillRunning=$true } catch { }
if ($stillRunning) { throw 'The old service still responds after Stop.' }
& $env:ComSpec /d /c (Join-Path $repoRoot 'Start-Laema-Art.cmd') -NoBrowser
if ($LASTEXITCODE -ne 0) { throw 'Start launcher failed.' }
$stats=Invoke-RestMethod -Uri 'http://127.0.0.1:8188/system_stats'
$after=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'server.local.json') -Raw | ConvertFrom-Json
if ($before.pid -eq $after.pid) { throw 'The service did not receive a new process identity.' }
foreach($name in $saved.Keys) {
    $path=Join-Path (Join-Path $PSScriptRoot 'user\default\workflows') $name
    if((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $saved[$name]) { throw "Saved workflow changed during restart: $name" }
}
$report=[ordered]@{
    status='passed'; root_start_and_stop_launchers_executed=$true; old_pid=$before.pid; new_pid=$after.pid
    stopped_endpoint_unavailable=$true; restarted_endpoint_available=$true; saved_workflows_preserved=$saved.Count
    app_count=@(Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'user\default\workflows') -Filter '*.app.json' -File).Count
    completed_utc=[DateTime]::UtcNow.ToString('o')
}
$report | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'evidence\restart-check.json') -Encoding utf8
$report | ConvertTo-Json -Depth 4
