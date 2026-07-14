# Codex Windows Runtime Repair

[中文](README.md)

修复 Windows 上 Codex 更新后不显示 GPT-5.6 等模型的问题：诊断并安全处理桌面运行时、CLI 与模型缓存版本不同步。

Fix Codex on Windows when GPT-5.6 or newer models do not appear after an update by safely diagnosing desktop runtime, CLI, and model-cache version mismatches.

This is a safety-first troubleshooting skill for Codex. It addresses a common local mismatch: a newer standalone CLI can see newer models while the Codex Desktop model picker stays old because Desktop is still using an older local runtime or model cache.

## What It Helps With

- Collect read-only locations and versions for multiple Windows `codex.exe` installations.
- Distinguish a standalone CLI from the Codex Desktop runtime, so PATH is not mistaken for the Desktop runtime.
- Guide a manual, verifiable, reversible refresh.
- Require a saved handoff note with diagnostics, next commands, and rollback commands before the user closes Codex.

## What It Does Not Do

- It cannot grant unavailable models or bypass service rollout, region, plan, or account-entitlement limits.
- It never automatically closes Codex, edits configuration, renames folders, deletes caches, installs software, or reads authentication data.
- It is not a substitute for official support. If newer models are absent from a current CLI and other official clients too, first verify account access and service availability.

## Update the CLI First, Then Decide Whether Desktop Repair Is Needed

For this issue, `codex-cli 0.144.3` or later is a known GPT-5.6 CLI baseline, but it is not an account-entitlement guarantee and does not mean Codex Desktop has updated. Confirm the model is actually visible in the CLI's own model list.

The user can first try:

```powershell
codex update
```

If it reports that it cannot detect the installation method, do not retry it repeatedly. Follow the official [Codex CLI getting-started page](https://learn.chatgpt.com/docs/codex/cli#getting-started) and run this command manually:

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```

Run `codex --version` again and confirm whether GPT-5.6 is visible in the CLI. **Even when the CLI is `0.144.3` or later and can use GPT-5.6, continue with this skill's Desktop repair if the Windows Desktop model picker still does not show it: back up the old runtime/cache with a timestamp, then let Desktop regenerate it.**

## Safety Contract

All repair actions are manual and follow this order:

1. Save a handoff note outside Codex.
2. Fully exit Codex Desktop manually.
3. When the CLI is updated but Desktop is still missing models, rename the existing runtime or cache to a timestamped backup before allowing regeneration.
4. Show the rollback command before the repair command.
5. Never touch authentication files, tokens, chats, or credentials.

See the full bilingual [Recovery workflow](references/recovery-workflow.md).

## Use

Install this repository as a Codex skill, then ask for help such as:

```text
Codex Desktop on Windows is missing GPT-5.6 after an update while my CLI is newer. Use codex-windows-runtime-repair for read-only diagnostics first, then give me a saved handoff and rollback instructions before any repair.
```

You can also run the read-only diagnostic script first:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\collect-diagnostics.ps1
```

Read the output before sharing it: local paths can contain a username.

## Repository Contents

| File | Purpose |
| --- | --- |
| `SKILL.md` | Required manual-operation and rollback rules for Codex. |
| `references/recovery-workflow.md` | Bilingual diagnosis, recovery, and rollback procedure. |
| `scripts/collect-diagnostics.ps1` | Read-only diagnostics; no writes, installs, or configuration changes. |
| `README.md` | Chinese documentation. |

## Contributing and Privacy

Before opening an issue or pull request, remove usernames, complete local paths, logs, authentication data, tokens, cookies, and cache contents. Never commit a `.codex` directory, `auth.json`, or diagnostic output.

Licensed under the [MIT License](LICENSE).
