[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Save', 'Load')]
    [string]$Mode,

    [Parameter(Mandatory)]
    [string]$ManifestPath,

    [string]$BindingsPath,

    [string]$Branch = 'main',

    [string]$CommitMessage
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$CheckpointRoot = Join-Path $ProjectRoot 'docs\checkpoints'

function Invoke-Git {
    param([Parameter(Mandatory)][string[]]$GitArgs)

    $output = & git -C $ProjectRoot @GitArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git $($GitArgs -join ' ') failed:`n$($output -join "`n")"
    }
    return @($output | ForEach-Object { "$_" })
}

function Read-JsonFile {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "JSON file not found: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable
}

function Assert-UnderCheckpointRoot {
    param([Parameter(Mandatory)][string]$Path)

    $fullPath = (Resolve-Path -LiteralPath $Path).Path
    $rootPath = ([IO.Path]::GetFullPath($CheckpointRoot)).TrimEnd('\') + '\'
    if (-not $fullPath.StartsWith($rootPath, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Manifest must be stored under docs/checkpoints: $Path"
    }
    return $fullPath
}

function Assert-Manifest {
    param([Parameter(Mandatory)][hashtable]$Manifest)

    foreach ($key in @('schema_version', 'checkpoint_id', 'project_id', 'tasks')) {
        if (-not $Manifest.ContainsKey($key)) {
            throw "Manifest is missing required field '$key'."
        }
    }
    if ([int]$Manifest['schema_version'] -ne 1) {
        throw "Unsupported manifest schema_version '$($Manifest['schema_version'])'."
    }
    if ([string]::IsNullOrWhiteSpace([string]$Manifest['checkpoint_id'])) {
        throw 'Manifest checkpoint_id cannot be empty.'
    }
    if (@($Manifest['tasks']).Count -eq 0) {
        throw 'Manifest must contain at least one task.'
    }

    foreach ($task in @($Manifest['tasks'])) {
        foreach ($key in @('task_key', 'canonical_title', 'changed', 'summary', 'latest_turn_id')) {
            if (-not $task.ContainsKey($key)) {
                throw "Task manifest entry is missing required field '$key'."
            }
        }
        if ([string]::IsNullOrWhiteSpace([string]$task['task_key'])) {
            throw 'Task task_key cannot be empty.'
        }
        if ($task['changed'] -isnot [bool]) {
            throw "Task '$($task['task_key'])' changed must be true or false."
        }
        if ($task['changed'] -and [string]::IsNullOrWhiteSpace([string]$task['summary'])) {
            throw "Changed task '$($task['task_key'])' requires a concise summary."
        }
        if ([string]$task['summary'] -and ([string]$task['summary']).Length -gt 1200) {
            throw "Task '$($task['task_key'])' summary exceeds 1200 characters."
        }
    }
}

function Get-PreviousManifest {
    param([Parameter(Mandatory)][string]$CurrentManifestPath)

    $previous = Get-ChildItem -LiteralPath $CheckpointRoot -File -Filter '*.thread-sync.json' |
        Where-Object { $_.FullName -ne $CurrentManifestPath } |
        Sort-Object Name -Descending |
        Select-Object -First 1
    if ($null -eq $previous) {
        return $null
    }
    $manifest = Read-JsonFile $previous.FullName
    Assert-Manifest $manifest
    return $manifest
}

function Assert-ChangedTaskSummaries {
    param(
        [Parameter(Mandatory)][hashtable]$Manifest,
        [AllowNull()][hashtable]$PreviousManifest
    )

    if ($null -eq $PreviousManifest) {
        return
    }

    $previousByKey = @{}
    foreach ($previousTask in @($PreviousManifest['tasks'])) {
        $previousByKey[$previousTask['task_key']] = $previousTask
    }

    foreach ($task in @($Manifest['tasks'])) {
        if (-not $previousByKey.ContainsKey($task['task_key'])) {
            if (-not $task['changed']) {
                throw "New task '$($task['task_key'])' must be marked changed and summarized."
            }
            continue
        }
        $previousTask = $previousByKey[$task['task_key']]
        if ($previousTask['latest_turn_id'] -ne $task['latest_turn_id'] -and -not $task['changed']) {
            throw "Task '$($task['task_key'])' has a newer turn but is not marked changed."
        }
    }
}

function Normalize-Title {
    param([AllowNull()][string]$Value)

    if ($null -eq $Value) {
        return ''
    }
    return (($Value -replace '\s+', ' ').Trim().ToLowerInvariant())
}

function Resolve-LocalBinding {
    param(
        [Parameter(Mandatory)][hashtable]$Task,
        [Parameter(Mandatory)][hashtable]$Bindings
    )

    $allowedTitles = @($Task['canonical_title']) + @($Task['aliases'])
    $allowedTitles = @($allowedTitles | ForEach-Object { Normalize-Title ([string]$_) } | Where-Object { $_ })

    $matches = @($Bindings['tasks'] | Where-Object {
        if ($_['task_key'] -eq $Task['task_key']) {
            return $true
        }
        $bindingTitle = Normalize-Title ([string]$_['title'])
        return $allowedTitles -contains $bindingTitle
    })

    if ($matches.Count -eq 1) {
        return $matches[0]
    }
    return $null
}

if ($Mode -eq 'Save') {
    $ManifestFullPath = Assert-UnderCheckpointRoot $ManifestPath
    $Manifest = Read-JsonFile $ManifestFullPath
    Assert-Manifest $Manifest
    $PreviousManifest = Get-PreviousManifest $ManifestFullPath
    Assert-ChangedTaskSummaries -Manifest $Manifest -PreviousManifest $PreviousManifest

    Invoke-Git @('diff', '--check') | Out-Null
    Invoke-Git @('add', '-A') | Out-Null
    Invoke-Git @('diff', '--cached', '--check') | Out-Null

    $stagedPaths = @(Invoke-Git @('diff', '--cached', '--name-only'))
    if ($stagedPaths.Count -eq 0) {
        [ordered]@{
            mode = 'save'
            checkpoint_id = $Manifest['checkpoint_id']
            published = $false
            reason = 'no_changes_to_commit'
        } | ConvertTo-Json -Depth 8
        exit 0
    }

    $message = if ($CommitMessage) { $CommitMessage } else { "checkpoint: $($Manifest['checkpoint_id'])" }
    Invoke-Git @('commit', '-m', $message) | Out-Null
    Invoke-Git @('push', 'origin', $Branch) | Out-Null

    $head = (Invoke-Git @('rev-parse', 'HEAD') | Select-Object -First 1).Trim()
    $remote = (Invoke-Git @('rev-parse', "origin/$Branch") | Select-Object -First 1).Trim()
    if ($head -ne $remote) {
        throw "Push completed without matching origin/$Branch. Local=$head Remote=$remote"
    }

    [ordered]@{
        mode = 'save'
        checkpoint_id = $Manifest['checkpoint_id']
        published = $true
        commit = $head
        changed_task_count = @($Manifest['tasks'] | Where-Object { $_['changed'] }).Count
        staged_path_count = $stagedPaths.Count
    } | ConvertTo-Json -Depth 8
    exit 0
}

$dirty = @(Invoke-Git @('status', '--porcelain=v1'))
if ($dirty.Count -gt 0) {
    throw "load checkpoint blocked by local changes:`n$($dirty -join "`n")"
}

Invoke-Git @('pull', '--ff-only', 'origin', $Branch) | Out-Null

$ManifestFullPath = Assert-UnderCheckpointRoot $ManifestPath
$Manifest = Read-JsonFile $ManifestFullPath
Assert-Manifest $Manifest

if ([string]::IsNullOrWhiteSpace($BindingsPath)) {
    throw 'Load requires -BindingsPath generated from the current local Codex task list.'
}

$Bindings = Read-JsonFile $BindingsPath
foreach ($key in @('schema_version', 'project_id', 'tasks')) {
    if (-not $Bindings.ContainsKey($key)) {
        throw "Bindings file is missing required field '$key'."
    }
}
if ([int]$Bindings['schema_version'] -ne 1) {
    throw "Unsupported bindings schema_version '$($Bindings['schema_version'])'."
}
if ($Bindings['project_id'] -ne $Manifest['project_id']) {
    throw "Bindings project_id '$($Bindings['project_id'])' does not match manifest project_id '$($Manifest['project_id'])'."
}

$updates = @()
$unresolved = @()
foreach ($task in @($Manifest['tasks'] | Where-Object { $_['changed'] })) {
    $binding = Resolve-LocalBinding -Task $task -Bindings $Bindings
    if ($null -eq $binding) {
        $unresolved += [ordered]@{
            task_key = $task['task_key']
            canonical_title = $task['canonical_title']
            aliases = @($task['aliases'])
            summary = $task['summary']
            reason = 'no_unique_local_binding'
        }
        continue
    }
    $updates += [ordered]@{
        task_key = $task['task_key']
        title = $binding['title']
        thread_id = $binding['thread_id']
        host_id = $binding['host_id']
        source_turn_id = $task['latest_turn_id']
        summary = $task['summary']
        delivery_message = "Checkpoint update ($($Manifest['checkpoint_id'])):`n$($task['summary'])"
    }
}

[ordered]@{
    mode = 'load'
    checkpoint_id = $Manifest['checkpoint_id']
    publication = 'no_op_read_only_load'
    changed_task_count = @($Manifest['tasks'] | Where-Object { $_['changed'] }).Count
    update_count = $updates.Count
    updates = $updates
    unresolved = $unresolved
} | ConvertTo-Json -Depth 12
