# Windows Codex Desktop Recovery Workflow / Windows Codex Desktop 恢复流程

This reference is for manual use. Read every command before running it. It does not authorize an agent to run state-changing commands for the user.

本参考流程只能由用户手动执行。请在运行前阅读每条命令；它不授权任何 agent 代替用户执行会改变本地状态的命令。

## 1. Confirm the Symptom / 确认症状

Continue only when all of these are true:

- Codex Desktop on Windows does not list GPT-5.6 or a newer expected model after an update.
- A newer standalone CLI, another official client, or reliable evidence indicates the model should be available to the account.
- The issue appears local to the Desktop client rather than an account or service-wide availability issue.

仅当以上条件同时成立时继续。如果新模型在当前 CLI 和其他官方客户端中也没有出现，请停止本流程，优先确认账号权限、服务端灰度或官方状态。

## 2. Read-Only Diagnosis / 只读诊断

Run from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\collect-diagnostics.ps1
```

Look for more than one `codex.exe` location and compare versions. A newer command resolved from `PATH` does not prove that Codex Desktop is using it.

重点查看是否存在多个 `codex.exe` 路径，以及它们的版本是否不同。PATH 上的新版命令不等于桌面端正在使用新版 runtime。

## 3. Optional Standalone CLI Update / 可选：更新独立 CLI

For this workflow, `codex-cli 0.144.3` or later is a known GPT-5.6 CLI baseline. It does not grant model access and it does not update Codex Desktop's local runtime. Confirm that GPT-5.6 is actually visible in the standalone CLI before treating the CLI update as successful.

在本流程中，`codex-cli 0.144.3` 或更高可作为 GPT-5.6 CLI 支持的已知基线。它不能开通模型权限，也不会更新 Codex Desktop 的本地 runtime。只有当独立 CLI 中实际能看到 GPT-5.6 时，才算 CLI 更新完成。

First try the CLI's own updater manually:

```powershell
codex update
```

If it succeeds, run `codex --version` and inspect the CLI model list again. If it reports that it cannot detect the installation method, do not repeat the command. Use the official Windows standalone installer instead:

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```

如果 `codex update` 成功，重新运行 `codex --version` 并再次查看 CLI 模型列表。如果它提示无法识别安装方式，不要反复重试；改用上面的官方 Windows standalone 安装命令。

**Continue to the next section when the updated standalone CLI can list GPT-5.6 but the Windows Codex Desktop model picker still cannot. This is the expected branch for a stale Desktop runtime/cache mismatch.**

**当更新后的独立 CLI 已能列出 GPT-5.6、但 Windows Codex Desktop 菜单仍不能列出时，必须继续下一节。这正是 Desktop runtime/cache 过旧或不同步的典型分支。**

## 4. Mandatory Handoff Note / 必须保存交接说明

Before closing Codex, create a text file outside the Codex app. Copy into it:

1. The diagnostic output, after removing any details you do not want to retain.
2. The exact backup name selected below.
3. The repair command and its rollback command.
4. The expected verification result.

Do not continue until the note is saved. The next phase requires fully exiting Codex Desktop, so this conversation may not be available.

在退出 Codex 前，不要跳过此步骤。下一阶段需要完全退出桌面端，此对话可能无法继续显示。

## 5. Manually Exit and Verify / 手动退出并确认

Fully exit Codex Desktop, including any tray process, yourself. Open a new PowerShell window and inspect remaining processes:

```powershell
Get-Process *codex*,ChatGPT -ErrorAction SilentlyContinue | Select-Object Id,ProcessName,Path
```

If anything remains, close it manually through the application or Task Manager. Do not run a repair while Codex Desktop is still running.

如果还有进程残留，请通过应用界面或任务管理器手动关闭。桌面端仍在运行时，不要进行后续操作。

## 6. Back Up Before Refreshing / 刷新前先备份

The following default locations are common but not universal. Use the diagnostic output and inspect the paths before replacing anything. Never rename or remove an authentication file.

以下默认位置较常见，但并非所有安装都一致。替换前请对照诊断结果确认路径。不要重命名或删除任何认证文件。

```powershell
$runtimeRoot = Join-Path $env:LOCALAPPDATA 'OpenAI\Codex'
$modelsCache = Join-Path $env:USERPROFILE '.codex\models_cache.json'
$stamp = Get-Date -Format 'yyyyMMddHHmmss'
Test-Path -LiteralPath $runtimeRoot
Test-Path -LiteralPath $modelsCache
```

If the old Desktop runtime is present and you have confirmed it is the stale one, create a reversible backup by rename:

```powershell
Rename-Item -LiteralPath $runtimeRoot -NewName "Codex.bak.$stamp"
```

Rollback command, to use only after closing Codex again and only if a newly regenerated runtime must be replaced:

```powershell
Rename-Item -LiteralPath (Join-Path $env:LOCALAPPDATA 'OpenAI\Codex') -NewName "Codex.bad.$stamp"
Rename-Item -LiteralPath (Join-Path $env:LOCALAPPDATA "OpenAI\Codex.bak.$stamp") -NewName 'Codex'
```

If a stale model cache is present, back it up separately by rename; do not delete it:

```powershell
Rename-Item -LiteralPath $modelsCache -NewName "models_cache.json.bak.$stamp"
```

Rollback command:

```powershell
Rename-Item -LiteralPath (Join-Path $env:USERPROFILE '.codex\models_cache.json') -NewName "models_cache.json.bad.$stamp"
Rename-Item -LiteralPath (Join-Path $env:USERPROFILE ".codex\models_cache.json.bak.$stamp") -NewName 'models_cache.json'
```

If any path or backup name differs from the handoff note, stop and correct the note before continuing.

若路径或备份名称与交接说明不一致，请停止并先更新说明。

## 7. Regenerate and Verify / 重新生成并验证

Open Codex Desktop manually. Allow it to recreate its runtime/cache if it prompts for repair or installation. Then inspect the model picker.

You can compare the Desktop runtime version again only after it has been recreated:

```powershell
& (Join-Path $env:LOCALAPPDATA 'OpenAI\Codex\bin\codex.exe') --version
```

Success means the Desktop model picker now contains the expected newer models. It does not mean that every future model will be available without server-side access.

成功的标准是桌面端模型菜单出现预期的新模型；这不代表未来每个模型都无需服务端权限即可使用。

## Stop Conditions / 停止条件

Stop and use the rollback command or seek official support when:

- the model is absent from current CLI and other official clients;
- the diagnostic output does not show a Desktop/CLI mismatch;
- a target path is missing or differs from the saved handoff note;
- a rename reports access denied or the app remains running;
- authentication, chat, or other unrelated user data would need to be touched.

Do not replace executables manually and do not make configuration files read-only to fight app updates.

不要手动替换可执行文件，也不要把配置文件设为只读来对抗应用更新。
