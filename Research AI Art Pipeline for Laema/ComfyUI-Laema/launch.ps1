param([ValidateSet('Start','Stop','Status')][string]$Action='Start', [switch]$NoBrowser)
$ErrorActionPreference = 'Stop'
try {
    $configPath = Join-Path $PSScriptRoot 'config.local.json'
    if ($env:LAEMA_AI_CACHE) {
        $cacheRoot = $env:LAEMA_AI_CACHE
    } elseif (Test-Path -LiteralPath $configPath) {
        $cacheRoot = (Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json).cache_root
    } else {
        throw 'Local installation location is missing. Set LAEMA_AI_CACHE or configure config.local.json; see README.md.'
    }
    $pythonPath = Join-Path $cacheRoot '.runtime\venv\Scripts\python.exe'
    if (-not (Test-Path -LiteralPath $pythonPath)) { throw "Python installation not found at $pythonPath" }
    $arguments = @((Join-Path $PSScriptRoot 'studio.py'), $Action.ToLowerInvariant())
    if ($NoBrowser) { $arguments += '--no-browser' }
    & $pythonPath @arguments
    exit $LASTEXITCODE
} catch {
    Write-Error $_
    exit 1
}
