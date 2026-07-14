# Read-only diagnostic helper. It does not write files, install software, edit configuration,
# stop processes, or inspect authentication data. Review and redact local paths before sharing output.

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

function Show-CommandVersion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    Write-Host "`n[$Label]"
    Write-Host "Path: $Path"

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-Host 'Status: not found'
        return
    }

    try {
        $version = & $Path --version 2>&1
        Write-Host ('Version: ' + (($version | Out-String).Trim()))
    }
    catch {
        Write-Host ('Version check failed: ' + $_.Exception.Message)
    }
}

Write-Host 'Codex Windows diagnostic report (read-only)'
Write-Host ('PowerShell: ' + $PSVersionTable.PSVersion)

Write-Host "`n[PATH resolution]"
$command = Get-Command codex -ErrorAction SilentlyContinue
if ($null -eq $command) {
    Write-Host 'codex is not resolved from PATH.'
}
else {
    Write-Host ('Resolved command: ' + $command.Source)
    try {
        $version = & $command.Source --version 2>&1
        Write-Host ('Resolved version: ' + (($version | Out-String).Trim()))
    }
    catch {
        Write-Host ('Resolved version check failed: ' + $_.Exception.Message)
    }
}

Write-Host "`n[where.exe codex]"
& where.exe codex 2>&1 | ForEach-Object { Write-Host $_ }

$standalone = Join-Path $env:LOCALAPPDATA 'Programs\OpenAI\Codex\bin\codex.exe'
$desktop = Join-Path $env:LOCALAPPDATA 'OpenAI\Codex\bin\codex.exe'
Show-CommandVersion -Label 'Standalone CLI candidate' -Path $standalone
Show-CommandVersion -Label 'Desktop runtime candidate' -Path $desktop

Write-Host "`nNext: Save this output outside Codex before following any instruction that asks you to close the desktop app."
