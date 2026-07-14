---
name: codex-windows-runtime-repair
description: Use when Codex Desktop on Windows does not show GPT-5.6 or newer models after an update, when desktop and CLI versions disagree, or when a stale local runtime or model cache is suspected.
---

# Codex Windows Runtime Repair

Guide a user through a manual, reversible recovery of a Windows Codex Desktop runtime or model-cache mismatch. This skill diagnoses local state; it cannot grant models that the user's account or service has not enabled.

> **Platform scope: Windows only.** Do not use this skill's PowerShell commands, paths, runtime/cache repair steps, or rollback commands on macOS or Linux.

## Non-Negotiable Safety Boundary

Do not perform state-changing repair actions yourself. Do not terminate Codex, rename runtime or cache folders, delete files, edit configuration, reinstall anything, or launch the app. Do not read, copy, display, back up, or modify authentication files, tokens, cookies, chat data, or credentials.

Only run `scripts/collect-diagnostics.ps1`; it is read-only. Explain every other command, then require the user to run it manually after reviewing it.

## Required Handoff Gate

Before any instruction that requires closing Codex:

1. Run or show the read-only diagnostics.
2. Ask the user to copy the diagnostics, the next commands, the backup names, and rollback commands into a text file outside the Codex app.
3. State plainly: "The next step requires you to fully exit Codex Desktop manually. This conversation will not remain available while the app is closed. Return using your saved handoff note."
4. Wait for the user to confirm the note is saved and that they will close the app manually.

Never substitute your own process control for this handoff.

## Workflow

1. Read `references/recovery-workflow.md` before giving repair instructions.
2. Run the read-only diagnostics and identify whether multiple `codex.exe` locations or mismatched versions exist.
3. If the standalone CLI is old, tell the user to update it manually. The user may try `codex update`; if it reports that the installation method cannot be detected, direct the user to the official Windows standalone installer command in `references/recovery-workflow.md`.
4. Treat `codex-cli 0.144.3` or later as the known GPT-5.6 CLI baseline for this troubleshooting path, not as an entitlement guarantee. Confirm the CLI can actually list the newer model for the user's account.
5. If the updated standalone CLI can list GPT-5.6 but Windows Codex Desktop still cannot, continue to the Desktop runtime/cache recovery. A standalone CLI update does not update the Codex Desktop runtime.
6. Use the Required Handoff Gate.
7. Give one manual phase at a time: exit, verify no processes remain, rename a dated backup, reopen Codex, verify the regenerated runtime, then inspect the model picker.
8. Before each manual rename, show the exact rollback command that restores the dated backup.
9. Stop if the user cannot identify a stale runtime/cache, lacks a backup, sees an access error, or the model is also absent from a current CLI. Explain that this points to installation, rollout, account entitlement, or service availability rather than a local cache mismatch.

## Quick Reference

| Situation | Guidance |
| --- | --- |
| Older standalone CLI or `codex update` cannot detect its installation method | User updates the standalone CLI manually with the official installer, then verifies its version and model list. |
| CLI is `0.144.3` or later and can list GPT-5.6, but Desktop cannot | Continue with the timestamped Desktop runtime/cache backup and regeneration flow. |
| New CLI shows newer models, Desktop does not | Suspect Desktop runtime or model-cache mismatch. |
| `where.exe codex` shows multiple locations | Compare every reported version; do not assume PATH controls Desktop. |
| Desktop process is still open | User must close it manually before any rename. |
| A repair step fails | Stop, use the rollback command, and preserve diagnostics. |
| Newer models are absent everywhere | Do not perform cache repair as a model-access workaround. |

## Common Mistakes

- Treating a standalone CLI update as a Desktop runtime update.
- Stopping after the CLI sees GPT-5.6 while the Desktop model picker remains old.
- Editing `config.toml` repeatedly while the Desktop app rewrites it.
- Deleting a runtime/cache instead of renaming it to a timestamped backup.
- Closing Codex before saving the next commands and rollback instructions.
- Sharing diagnostic output publicly without redacting personal paths.
