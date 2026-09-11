[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Save', 'Load', 'Plan')]
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
    if ($LASTEXITCODE -ne 0) { throw "git $($GitArgs -join ' ') failed: $($output -join [Environment]::NewLine)" }
    return @($output | ForEach-Object { "$_" })
}

function Read-JsonFile {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "JSON file not found: $Path" }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable
}

function Assert-UnderCheckpointRoot {
    param([Parameter(Mandatory)][string]$Path)
    $fullPath = (Resolve-Path -LiteralPath $Path).Path
    $rootPath = ([IO.Path]::GetFullPath($CheckpointRoot)).TrimEnd('\') + '\'
    if (-not $fullPath.StartsWith($rootPath, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path must be stored under docs/checkpoints: $Path"
    }
    return $fullPath
}

function Normalize-Title {
    param([AllowNull()][string]$Value)
    if ($null -eq $Value) { return '' }
    return (($Value -replace '\s+', ' ').Trim().ToLowerInvariant())
}

function Get-TaskNotePath {
    param([Parameter(Mandatory)][string]$ManifestFullPath, [Parameter(Mandatory)][hashtable]$Task)
    $taskFile = [string]$Task['task_file']
    if ([string]::IsNullOrWhiteSpace($taskFile) -or [IO.Path]::IsPathRooted($taskFile) -or $taskFile.Contains('..')) {
        throw "Task '$($Task['task_key'])' has an invalid task_file."
    }
    $manifestDirectory = Split-Path -Parent $ManifestFullPath
    $candidate = [IO.Path]::GetFullPath((Join-Path $manifestDirectory $taskFile))
    $allowedRoot = ([IO.Path]::GetFullPath($manifestDirectory)).TrimEnd('\') + '\'
    if (-not $candidate.StartsWith($allowedRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Task '$($Task['task_key'])' note must stay beside its manifest."
    }
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) { throw "Task '$($Task['task_key'])' note not found: $taskFile" }
    return $candidate
}

function Assert-TaskNote {
    param([Parameter(Mandatory)][string]$TaskNotePath, [Parameter(Mandatory)][string]$TaskKey)
    $text = Get-Content -LiteralPath $TaskNotePath -Raw
    foreach ($heading in @('(?m)^## Since last checkpoint\s*$', '(?m)^## Carried context\s*$', '(?m)^## Resume point\s*$', '(?m)^## Sources\s*$')) {
        if ($text -notmatch $heading) { throw "Task '$TaskKey' note is missing a required compact-recovery heading." }
    }
    if ($text.Length -gt 5000) { throw "Task '$TaskKey' note is too long. Keep recovery notes compact." }
}

function Get-ExplicitProgressUid {
    param([AllowNull()][hashtable]$Value)

    if ($null -ne $Value -and $Value.ContainsKey('progress_uid')) {
        $uid = [string]$Value['progress_uid']
        if (-not [string]::IsNullOrWhiteSpace($uid)) {
            return $uid.Trim()
        }
    }
    return $null
}

function Get-ProgressUid {
    param([Parameter(Mandatory)][hashtable]$Task)

    $uid = Get-ExplicitProgressUid $Task
    if ($null -ne $uid) {
        return $uid
    }
    return [string]$Task['latest_turn_id']
}

function Assert-Manifest {
    param([Parameter(Mandatory)][hashtable]$Manifest)
    foreach ($key in @('schema_version', 'checkpoint_id', 'project_id', 'tasks')) {
        if (-not $Manifest.ContainsKey($key)) { throw "Manifest is missing required field '$key'." }
    }
    $schema = [int]$Manifest['schema_version']
    if ($schema -notin @(1, 2, 3)) { throw "Unsupported manifest schema_version '$schema'." }
    if ([string]::IsNullOrWhiteSpace([string]$Manifest['checkpoint_id'])) { throw 'Manifest checkpoint_id cannot be empty.' }
    if (@($Manifest['tasks']).Count -eq 0) { throw 'Manifest must contain at least one task.' }
    if ($schema -eq 3 -and [string]::IsNullOrWhiteSpace([string]$Manifest['previous_manifest'])) { throw 'Schema 3 manifests must name previous_manifest.' }

    $seenKeys = @{}
    foreach ($task in @($Manifest['tasks'])) {
        foreach ($key in @('task_key', 'canonical_title', 'aliases', 'changed', 'summary', 'latest_turn_id')) {
            if (-not $task.ContainsKey($key)) { throw "Task manifest entry is missing required field '$key'." }
        }
        $taskKey = [string]$task['task_key']
        if ([string]::IsNullOrWhiteSpace($taskKey) -or $seenKeys.ContainsKey($taskKey)) { throw 'Task keys must be non-empty and unique.' }
        $seenKeys[$taskKey] = $true
        if (@($task['aliases']).Count -eq 0) { throw "Task '$taskKey' requires at least one confirmed title alias." }
        if ($task.ContainsKey('progress_uid') -and [string]::IsNullOrWhiteSpace([string]$task['progress_uid'])) { throw "Task '$taskKey' progress_uid cannot be empty." }
        if ($task['changed'] -isnot [bool]) { throw "Task '$taskKey' changed must be true or false." }
        if ($task['changed'] -and [string]::IsNullOrWhiteSpace([string]$task['summary'])) { throw "Changed task '$taskKey' requires a compact summary." }
        if ([string]$task['summary'] -and ([string]$task['summary']).Length -gt 600) { throw "Task '$taskKey' summary exceeds 600 characters." }
        if ($schema -eq 3 -and -not $task.ContainsKey('task_file')) { throw "Task '$taskKey' requires task_file in schema 3." }
    }
}

function Get-PreviousManifest {
    param([Parameter(Mandatory)][hashtable]$Manifest, [Parameter(Mandatory)][string]$ManifestFullPath)
    if (-not $Manifest.ContainsKey('previous_manifest')) { return $null }
    $relativePath = [string]$Manifest['previous_manifest']
    if ([IO.Path]::IsPathRooted($relativePath) -or $relativePath.Contains('..')) { throw 'previous_manifest must be a repository-relative checkpoint path.' }
    $previousPath = Assert-UnderCheckpointRoot (Join-Path $ProjectRoot $relativePath)
    if ($previousPath -eq $ManifestFullPath) { throw 'previous_manifest cannot reference itself.' }
    $previous = Read-JsonFile $previousPath
    Assert-Manifest $previous
    return $previous
}

function Assert-ChangedTaskSummaries {
    param([Parameter(Mandatory)][hashtable]$Manifest, [AllowNull()][hashtable]$PreviousManifest)
    if ($null -eq $PreviousManifest) { return }
    $previousByKey = @{}
    foreach ($task in @($PreviousManifest['tasks'])) { $previousByKey[$task['task_key']] = $task }
    foreach ($task in @($Manifest['tasks'])) {
        if (-not $previousByKey.ContainsKey($task['task_key'])) {
            if (-not $task['changed']) { throw "New task '$($task['task_key'])' must be marked changed and summarized." }
            continue
        }
        $previousTask = $previousByKey[$task['task_key']]
        $previousExplicitUid = Get-ExplicitProgressUid $previousTask
        $currentExplicitUid = Get-ExplicitProgressUid $task
        if ($null -ne $previousExplicitUid -and $null -ne $currentExplicitUid) {
            $previousIdentity = $previousExplicitUid
            $currentIdentity = $currentExplicitUid
        }
        else {
            # Legacy manifests predate progress_uid; use their turn binding only for this migration comparison.
            $previousIdentity = [string]$previousTask['latest_turn_id']
            $currentIdentity = [string]$task['latest_turn_id']
        }
        if ($previousIdentity -ne $currentIdentity -and -not $task['changed']) {
            throw "Task '$($task['task_key'])' has a newer turn but is not marked changed."
        }
        if ($previousIdentity -eq $currentIdentity -and $task['changed'] -and $null -ne $previousExplicitUid -and $null -ne $currentExplicitUid) {
            throw "Task '$($task['task_key'])' is marked changed but progress_uid did not change."
        }
    }
}

function Resolve-LocalBinding {
    param([Parameter(Mandatory)][hashtable]$Task, [Parameter(Mandatory)][hashtable]$Bindings)
    $allowedTitles = @($Task['canonical_title']) + @($Task['aliases'])
    $allowedTitles = @($allowedTitles | ForEach-Object { Normalize-Title ([string]$_) } | Where-Object { $_ })
    $matches = @($Bindings['tasks'] | Where-Object {
        $_['task_key'] -eq $Task['task_key'] -and $allowedTitles -contains (Normalize-Title ([string]$_['title']))
    })
    if ($matches.Count -eq 1) { return $matches[0] }
    return $null
}

function New-RestorePrompt {
    param([Parameter(Mandatory)][hashtable]$Task, [Parameter(Mandatory)][string]$TaskNotePath, [Parameter(Mandatory)][bool]$Legacy)
    if ($Legacy) {
        return "Restore the latest Laema $($Task['canonical_title']) context from $TaskNotePath. This is a legacy summary-only checkpoint: read its referenced records and current canonical sources, carry forward compatible context, report any missing context or material conflict, and end with the resume point. Do not edit files or start new work."
    }
    return "Restore the latest Laema $($Task['canonical_title']) context from $TaskNotePath. Compare its Since last checkpoint and Carried context with your current task history and the current canonical sources it names. Carry forward compatible context. If authority does not resolve a material conflict, state it plainly for the user. Reply briefly with Carried, Changed, Conflict (or none), and Resume point. Do not edit files or start new work."
}

$manifestFullPath = Assert-UnderCheckpointRoot $ManifestPath
if ($Mode -eq 'Load') {
    $dirty = @(Invoke-Git @('status', '--porcelain=v1'))
    if ($dirty.Count -gt 0) { throw "load checkpoint blocked by local changes: $($dirty -join [Environment]::NewLine)" }
    Invoke-Git @('pull', '--ff-only', 'origin', $Branch) | Out-Null
}

$manifest = Read-JsonFile $manifestFullPath
Assert-Manifest $manifest
$schema = [int]$manifest['schema_version']
if ($schema -eq 3) {
    foreach ($task in @($manifest['tasks'])) {
        Assert-TaskNote -TaskNotePath (Get-TaskNotePath -ManifestFullPath $manifestFullPath -Task $task) -TaskKey $task['task_key']
    }
}

if ($Mode -eq 'Save') {
    if ($schema -ne 3) { throw 'New saves require schema_version 3 with one Markdown note per task.' }
    foreach ($task in @($manifest['tasks'])) {
        if ($null -eq (Get-ExplicitProgressUid $task)) { throw "New schema 3 saves require progress_uid for task '$($task['task_key'])'." }
    }
    $previous = Get-PreviousManifest -Manifest $manifest -ManifestFullPath $manifestFullPath
    Assert-ChangedTaskSummaries -Manifest $manifest -PreviousManifest $previous
    Invoke-Git @('diff', '--check') | Out-Null
    Invoke-Git @('add', '-A') | Out-Null
    Invoke-Git @('diff', '--cached', '--check') | Out-Null
    $stagedPaths = @(Invoke-Git @('diff', '--cached', '--name-only'))
    if ($stagedPaths.Count -eq 0) {
        [ordered]@{ mode = 'save'; checkpoint_id = $manifest['checkpoint_id']; published = $false; reason = 'no_changes_to_commit' } | ConvertTo-Json -Depth 8
        exit 0
    }
    $message = if ($CommitMessage) { $CommitMessage } else { "checkpoint: $($manifest['checkpoint_id'])" }
    Invoke-Git @('commit', '-m', $message) | Out-Null
    Invoke-Git @('push', 'origin', $Branch) | Out-Null
    $head = (Invoke-Git @('rev-parse', 'HEAD') | Select-Object -First 1).Trim()
    $remote = (Invoke-Git @('rev-parse', "origin/$Branch") | Select-Object -First 1).Trim()
    if ($head -ne $remote) { throw "Push completed without matching origin/$Branch. Local=$head Remote=$remote" }
    [ordered]@{
        mode = 'save'; checkpoint_id = $manifest['checkpoint_id']; published = $true; commit = $head
        task_count = @($manifest['tasks']).Count
        changed_task_count = @($manifest['tasks'] | Where-Object { $_['changed'] }).Count
        staged_path_count = $stagedPaths.Count
    } | ConvertTo-Json -Depth 8
    exit 0
}

if ([string]::IsNullOrWhiteSpace($BindingsPath)) { throw 'Load and Plan require transient bindings generated from the current Codex task list.' }
$bindings = Read-JsonFile $BindingsPath
foreach ($key in @('schema_version', 'tasks')) {
    if (-not $bindings.ContainsKey($key)) { throw "Bindings file is missing required field '$key'." }
}
if ([int]$bindings['schema_version'] -notin @(1, 2)) { throw 'Unsupported bindings schema_version.' }
if ($bindings.ContainsKey('checkpoint_project_id')) {
    if ($bindings['checkpoint_project_id'] -ne $manifest['project_id']) { throw 'Bindings do not identify this checkpoint project.' }
} elseif ($bindings.ContainsKey('project_id')) {
    if ($bindings['project_id'] -ne $manifest['project_id']) { throw 'Bindings project_id does not match manifest project_id.' }
} else { throw 'Bindings require checkpoint_project_id or project_id.' }

$updates = @()
$unresolved = @()
$skippedDormant = @()
foreach ($task in @($manifest['tasks'])) {
    $binding = Resolve-LocalBinding -Task $task -Bindings $bindings
    if ($null -eq $binding) {
        $unresolved += [ordered]@{ task_key = $task['task_key']; canonical_title = $task['canonical_title']; aliases = @($task['aliases']); reason = 'no_unique_local_binding' }
        continue
    }
    $sourceProgressUid = Get-ExplicitProgressUid $task
    $localProgressUid = Get-ExplicitProgressUid $binding
    if ($null -ne $sourceProgressUid -and $null -ne $localProgressUid -and $sourceProgressUid -eq $localProgressUid) {
        $skippedDormant += [ordered]@{
            task_key = $task['task_key']
            title = $binding['title']
            progress_uid = $sourceProgressUid
            reason = 'progress_uid_match'
        }
        continue
    }
    $taskNotePath = if ($schema -eq 3) { Get-TaskNotePath -ManifestFullPath $manifestFullPath -Task $task } else { $manifestFullPath }
    $updates += [ordered]@{
        task_key = $task['task_key']; title = $binding['title']; thread_id = $binding['thread_id']; host_id = $binding['host_id']
        changed = $task['changed']; summary = $task['summary']; task_file = $taskNotePath; requires_response = $true
        source_progress_uid = $sourceProgressUid; local_progress_uid = $localProgressUid
        delivery_message = New-RestorePrompt -Task $task -TaskNotePath $taskNotePath -Legacy ($schema -ne 3)
    }
}

[ordered]@{
    mode = $Mode.ToLowerInvariant(); checkpoint_id = $manifest['checkpoint_id']; task_count = @($manifest['tasks']).Count
    changed_task_count = @($manifest['tasks'] | Where-Object { $_['changed'] }).Count
    dormant_count = $skippedDormant.Count
    update_count = $updates.Count; updates = $updates; skipped_dormant = $skippedDormant; unresolved = $unresolved
} | ConvertTo-Json -Depth 12
