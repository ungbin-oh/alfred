# written by Ungbin_Oh
# project : [AWP] AI-Assistant-Workflow-Publishing
# created : 2026-10-06
# updated : 2026-10-06
#
# Alfred for Codex - Windows hook launcher
#
# On Windows, Codex runs hook commands through cmd.exe, where `bash` is usually WSL's Linux bash.
# WSL's bash can't open C:\ paths, so the bash hooks failed. hooks/hooks.json therefore gives each
# hook a commandWindows that runs this script. It finds Git Bash (part of Git for Windows) and runs
# the same .sh hook with it. The hook's stdin and stdout pass through as raw bytes, so nothing is
# re-encoded (Windows PowerShell 5.1 would otherwise mangle non-ASCII text).
#
# Usage: run-windows.ps1 <session-start | manual-mode | init-guard | guide-mode>
#
# Git Bash is looked up on every run, because its folder differs from PC to PC:
#   1. Next to `git` on PATH - walk up from git.exe to the folder that has bin\bash.exe
#   2. The Git for Windows registry key (InstallPath)
#   3. The usual install folders (Program Files, AppData\Local\Programs)
# WSL's bash (under Windows\System32 or WindowsApps) is never used.
#
# Without Git Bash: session-start prints one line so the model can tell the user to install
# Git for Windows; the other hooks print nothing. Either way it exits 0, so the session goes on.
#
# Written for Windows PowerShell 5.1 (the Windows default), so it uses no newer syntax.
# Keep this file ASCII-only: PowerShell 5.1 reads a file without BOM in the system code page.

param([string]$Hook)

$ErrorActionPreference = 'SilentlyContinue'

$known = @('session-start', 'manual-mode', 'init-guard', 'guide-mode')
if ($known -notcontains $Hook) { exit 0 }

# A candidate counts only if it exists and is not WSL's bash
function Test-GitBash([string]$path) {
  if (-not $path) { return $false }
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $false }
  $full = [System.IO.Path]::GetFullPath($path)
  if ($env:SystemRoot -and $full.StartsWith($env:SystemRoot, [System.StringComparison]::OrdinalIgnoreCase)) { return $false }
  if ($full -like '*\WindowsApps\*') { return $false }
  return $true
}

function Find-GitBash {
  # 1. Next to git on PATH. git.exe sits in Git\cmd, Git\bin or Git\mingw64\bin - walk up a few levels
  $git = Get-Command git.exe -CommandType Application | Select-Object -First 1
  if ($git -and $git.Source) {
    $dir = Split-Path -Parent $git.Source
    for ($i = 0; $i -lt 4 -and $dir; $i++) {
      $candidate = Join-Path $dir 'bin\bash.exe'
      if (Test-GitBash $candidate) { return $candidate }
      $parent = Split-Path -Parent $dir
      if ($parent -eq $dir) { break }
      $dir = $parent
    }
  }

  # 2. The Git for Windows registry key
  foreach ($key in @('HKLM:\SOFTWARE\GitForWindows', 'HKCU:\SOFTWARE\GitForWindows', 'HKLM:\SOFTWARE\WOW6432Node\GitForWindows')) {
    $item = Get-ItemProperty -Path $key -Name InstallPath
    if ($item -and $item.InstallPath) {
      $candidate = Join-Path $item.InstallPath 'bin\bash.exe'
      if (Test-GitBash $candidate) { return $candidate }
    }
  }

  # 3. The usual install folders
  $roots = @($env:ProgramFiles, $env:ProgramW6432, ${env:ProgramFiles(x86)})
  if ($env:LOCALAPPDATA) { $roots += (Join-Path $env:LOCALAPPDATA 'Programs') }
  foreach ($root in $roots) {
    if (-not $root) { continue }
    $candidate = Join-Path $root 'Git\bin\bash.exe'
    if (Test-GitBash $candidate) { return $candidate }
  }
  return $null
}

$stdout = [Console]::OpenStandardOutput()

function Write-Bytes([byte[]]$bytes) {
  if ($bytes -and $bytes.Length -gt 0) {
    $stdout.Write($bytes, 0, $bytes.Length)
    $stdout.Flush()
  }
}

$bash = Find-GitBash
if (-not $bash) {
  if ($Hook -eq 'session-start') {
    $msg = "ALFRED - Git Bash not found. On Windows, Alfred's hooks need Git for Windows (Git Bash), so the Alfred rules were not loaded this session. Tell the user: install Git for Windows (winget install --id Git.Git -e, or https://git-scm.com/download/win), then reopen Codex.`n"
    Write-Bytes ((New-Object System.Text.UTF8Encoding $false).GetBytes($msg))
  }
  exit 0
}

$script = Join-Path $PSScriptRoot "$Hook.sh"
if (-not (Test-Path -LiteralPath $script -PathType Leaf)) { exit 0 }

# Read the hook input (JSON from Codex) as raw bytes
$inBytes = New-Object byte[] 0
if ([Console]::IsInputRedirected) {
  $ms = New-Object System.IO.MemoryStream
  [Console]::OpenStandardInput().CopyTo($ms)
  $inBytes = $ms.ToArray()
}

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $bash
$psi.Arguments = '"' + $script + '"'
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$psi.RedirectStandardInput = $true
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true

$p = [System.Diagnostics.Process]::Start($psi)
if (-not $p) { exit 0 }

# stderr is drained in the background so a chatty hook can't block on a full pipe
$errTask = $p.StandardError.ReadToEndAsync()

# Hand the input over and close stdin; a hook that doesn't read stdin may already be gone
try {
  if ($inBytes.Length -gt 0) { $p.StandardInput.BaseStream.Write($inBytes, 0, $inBytes.Length) }
  $p.StandardInput.BaseStream.Flush()
} catch {}
try { $p.StandardInput.Close() } catch {}

# Relay the hook's stdout unchanged
$outMs = New-Object System.IO.MemoryStream
$p.StandardOutput.BaseStream.CopyTo($outMs)
$p.WaitForExit()
Write-Bytes $outMs.ToArray()

exit $p.ExitCode
