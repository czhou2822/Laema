[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$GodotPath = $env:LAEMA_GODOT_PATH,

    [string]$LiveRepoPath = $env:LAEMA_LIVE_REPO_PATH,

    [string]$Preset = 'Web',

    [string]$LiveBranch = 'main',

    [string]$ArtifactPrefix = 'index',

    [string]$CommitMessage,

    [switch]$Interactive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

if ([string]::IsNullOrWhiteSpace($LiveRepoPath)) {
    $LiveRepoPath = Join-Path (Split-Path $ProjectRoot -Parent) 'laema-live'
}

function Invoke-Git {
    param(
        [Parameter(Mandatory)][string]$Repository,
        [Parameter(Mandatory)][string[]]$GitArgs
    )

    $output = & git -C $Repository @GitArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git -C $Repository $($GitArgs -join ' ') failed:`n$($output -join "`n")"
    }
    return @($output | ForEach-Object { "$_" })
}

function Assert-CleanRepository {
    param([Parameter(Mandatory)][string]$Repository)

    $status = @(Invoke-Git -Repository $Repository -GitArgs @('status', '--porcelain=v1'))
    if ($status.Count -gt 0) {
        throw "Repository has local changes and cannot publish safely: $Repository`n$($status -join "`n")"
    }
}

function Get-Revision {
    param([Parameter(Mandatory)][string]$Repository, [Parameter(Mandatory)][string]$Revision)

    return (Invoke-Git -Repository $Repository -GitArgs @('rev-parse', $Revision) | Select-Object -First 1).Trim()
}

function Test-EqualFile {
    param([Parameter(Mandatory)][string]$LeftPath, [Parameter(Mandatory)][string]$RightPath)

    if (-not (Test-Path -LiteralPath $RightPath -PathType Leaf)) {
        return $false
    }
    if ((Get-Item -LiteralPath $LeftPath).Length -ne (Get-Item -LiteralPath $RightPath).Length) {
        return $false
    }
    return (Get-FileHash -LiteralPath $LeftPath -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $RightPath -Algorithm SHA256).Hash
}

function Assert-PathInside {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Root)

    $fullPath = [IO.Path]::GetFullPath($Path)
    $fullRoot = [IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    if (-not $fullPath.StartsWith($fullRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is outside the intended live repository: $Path"
    }
}

function Exit-Prerequisite {
    param(
        [Parameter(Mandatory)][string]$Reason,
        [Parameter(Mandatory)][string]$Action,
        [string]$Details = ''
    )

    [ordered]@{
        published = $false
        reason = $Reason
        action = $Action
        details = $Details
    } | ConvertTo-Json -Depth 8
    exit 3
}

function ConvertTo-ProcessArgument {
    param([Parameter(Mandatory)][string]$Value)

    if ($Value -notmatch '[\s"]') {
        return $Value
    }
    return '"' + $Value.Replace('"', '\"') + '"'
}

if ([string]::IsNullOrWhiteSpace($GodotPath)) {
    $godotCommand = Get-Command godot -ErrorAction SilentlyContinue
    if ($null -ne $godotCommand) {
        $GodotPath = $godotCommand.Source
    }
    elseif ($Interactive) {
        $GodotPath = Read-Host 'Godot was not found on PATH. Enter the path to godot.exe, or leave blank to cancel'
    }
    else {
        Exit-Prerequisite -Reason 'missing_godot' -Action 'Install Godot or set LAEMA_GODOT_PATH, then run publish live version again.'
    }
}
if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    Exit-Prerequisite -Reason 'godot_path_not_found' -Action 'Provide a valid -GodotPath or set LAEMA_GODOT_PATH.' -Details $GodotPath
}

if (-not (Test-Path -LiteralPath $LiveRepoPath -PathType Container)) {
    Exit-Prerequisite -Reason 'missing_live_repository' -Action 'Clone the live repository as a sibling laema-live checkout or set LAEMA_LIVE_REPO_PATH.' -Details $LiveRepoPath
}
$LiveRepo = (Resolve-Path -LiteralPath $LiveRepoPath).Path
if ($LiveRepo -eq $ProjectRoot) {
    throw 'LiveRepoPath cannot be the source repository.'
}
if (-not (Test-Path -LiteralPath (Join-Path $LiveRepo '.git'))) {
    throw "LiveRepoPath is not a Git repository: $LiveRepo"
}

Assert-CleanRepository -Repository $LiveRepo

$sourceStatus = @(Invoke-Git -Repository $ProjectRoot -GitArgs @('status', '--porcelain=v1'))
$sourceDirty = $sourceStatus.Count -gt 0
$sourceHead = Get-Revision -Repository $ProjectRoot -Revision 'HEAD'

$tempExport = Join-Path ([IO.Path]::GetTempPath()) ("laema-live-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempExport -Force | Out-Null

try {
    $entryPoint = Join-Path $tempExport ("$ArtifactPrefix.html")
    $stdoutPath = Join-Path $tempExport '.godot.stdout.log'
    $stderrPath = Join-Path $tempExport '.godot.stderr.log'
    $godotArgs = @('--headless', '--path', $ProjectRoot, '--export-release', $Preset, $entryPoint) |
        ForEach-Object { ConvertTo-ProcessArgument $_ }
    $godotProcess = Start-Process -FilePath $GodotPath -ArgumentList $godotArgs -Wait -PassThru -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
    $exportOutput = @()
    if (Test-Path -LiteralPath $stdoutPath) {
        $exportOutput += Get-Content -LiteralPath $stdoutPath
    }
    if (Test-Path -LiteralPath $stderrPath) {
        $exportOutput += Get-Content -LiteralPath $stderrPath
    }
    if ($godotProcess.ExitCode -ne 0) {
        $exportText = $exportOutput -join "`n"
        if ($exportText -match '(?i)export template|templates?.*(missing|not found)|missing.*templates?') {
            Exit-Prerequisite -Reason 'missing_export_templates' -Action "Install Godot export templates matching this editor, including the $Preset preset, then retry publish live version." -Details $exportText
        }
        throw "Godot Web export failed:`n$($exportOutput -join "`n")"
    }
    if (-not (Test-Path -LiteralPath $entryPoint -PathType Leaf)) {
        throw "Godot export completed without creating ${entryPoint}:`n$($exportOutput -join "`n")"
    }

    $generated = @(Get-ChildItem -LiteralPath $tempExport -File | Where-Object { $_.Name -notlike '.godot.*.log' })
    $existing = @(Get-ChildItem -LiteralPath $LiveRepo -File -Filter "$ArtifactPrefix.*")
    $generatedNames = @($generated | ForEach-Object { $_.Name })
    $removedNames = @($existing | Where-Object { $generatedNames -notcontains $_.Name } | ForEach-Object { $_.Name })
    $changedNames = @($generated | Where-Object { -not (Test-EqualFile -LeftPath $_.FullName -RightPath (Join-Path $LiveRepo $_.Name)) } | ForEach-Object { $_.Name })
    $allChanges = @($changedNames + $removedNames | Sort-Object -Unique)

    if ($allChanges.Count -eq 0) {
        [ordered]@{
            published = $false
            reason = 'artifact_bytes_unchanged'
            source_commit = $sourceHead
            source_dirty = $sourceDirty
            source_change_count = $sourceStatus.Count
            live_commit = Get-Revision -Repository $LiveRepo -Revision 'HEAD'
        } | ConvertTo-Json -Depth 8
        exit 0
    }

    if (-not $PSCmdlet.ShouldProcess($LiveRepo, "replace $($allChanges.Count) generated $ArtifactPrefix artifacts and publish $LiveBranch")) {
        [ordered]@{
            published = $false
            reason = 'what_if'
            source_commit = $sourceHead
            source_dirty = $sourceDirty
            source_change_count = $sourceStatus.Count
            planned_changes = $allChanges
        } | ConvertTo-Json -Depth 8
        exit 0
    }

    foreach ($name in $removedNames) {
        $target = Join-Path $LiveRepo $name
        Assert-PathInside -Path $target -Root $LiveRepo
        Remove-Item -LiteralPath $target -Force
    }
    foreach ($file in $generated) {
        $target = Join-Path $LiveRepo $file.Name
        Assert-PathInside -Path $target -Root $LiveRepo
        Copy-Item -LiteralPath $file.FullName -Destination $target -Force
    }

    Invoke-Git -Repository $LiveRepo -GitArgs @('add', '-A') | Out-Null
    Invoke-Git -Repository $LiveRepo -GitArgs @('diff', '--cached', '--check') | Out-Null
    $sourceLabel = $sourceHead.Substring(0, 7)
    if ($sourceDirty) {
        $sourceLabel += '+working'
    }
    $message = if ($CommitMessage) { $CommitMessage } else { "Publish Laema working snapshot ($sourceLabel)" }
    Invoke-Git -Repository $LiveRepo -GitArgs @('commit', '-m', $message) | Out-Null
    Invoke-Git -Repository $LiveRepo -GitArgs @('push', 'origin', $LiveBranch) | Out-Null

    $liveHead = Get-Revision -Repository $LiveRepo -Revision 'HEAD'
    $liveRemote = Get-Revision -Repository $LiveRepo -Revision "origin/$LiveBranch"
    if ($liveHead -ne $liveRemote) {
        throw "Live push completed without matching origin/$LiveBranch. Local=$liveHead Remote=$liveRemote"
    }

    [ordered]@{
        published = $true
        source_commit = $sourceHead
        source_dirty = $sourceDirty
        source_change_count = $sourceStatus.Count
        live_commit = $liveHead
        changed_artifacts = $allChanges
    } | ConvertTo-Json -Depth 8
}
finally {
    if (Test-Path -LiteralPath $tempExport) {
        Remove-Item -LiteralPath $tempExport -Recurse -Force
    }
}
