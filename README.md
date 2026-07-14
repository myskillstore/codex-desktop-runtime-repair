# Codex Windows Runtime Repair

[English](README.en.md)

修复 Windows 上 Codex 更新后不显示 GPT-5.6 等模型的问题：诊断并安全处理桌面运行时、CLI 与模型缓存版本不同步。

Fix Codex on Windows when GPT-5.6 or newer models do not appear after an update by safely diagnosing desktop runtime, CLI, and model-cache version mismatches.

这是一个面向 Codex 的安全排障 skill。它适用于一种常见情形：独立 CLI 已是较新版本并能看到新模型，但 Codex Desktop 的模型菜单仍停留在旧版本，因为桌面端仍在使用旧的本地 runtime 或模型缓存。

## 它能做什么

- 只读地收集 Windows 上多个 `codex.exe` 的位置和版本。
- 帮助区分独立 CLI 与 Codex Desktop runtime，避免把 PATH 上的 CLI 当成桌面端 runtime。
- 给出手动、可验证、可回滚的刷新流程。
- 在关闭 Codex 前要求保存诊断信息、下一步命令和回滚命令，防止对话中断后无从恢复。

## 它不能做什么

- 不能为账号开通未获得的模型或绕过服务端灰度、地区、套餐和权限限制。
- 不会自动关闭 Codex、修改配置、重命名文件夹、删除缓存、安装软件或读取认证信息。
- 不应替代官方支持渠道；如果新模型在当前 CLI 和其他官方客户端中也不存在，应优先确认服务端可用性与账号权限。

## 先更新 CLI，再判断是否需要修复桌面端

对于本问题，`codex-cli 0.144.3` 或更高可作为 GPT-5.6 CLI 支持的已知基线，但不等于账号一定有该模型，也不等于 Codex Desktop 已更新。请以 CLI 自己的模型列表为准。

用户可以先手动运行：

```powershell
codex update
```

如果它提示无法识别安装方式，请不要反复重试。按 [官方 Codex CLI 入门页](https://learn.chatgpt.com/docs/codex/cli#getting-started) 手动执行：

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```

更新后重新运行 `codex --version`，并在 CLI 中确认 GPT-5.6 是否实际可见。**即使 CLI 已是 `0.144.3` 或更高、且能使用 GPT-5.6，只要 Windows 桌面端菜单仍不显示它，就必须继续执行本 skill 的前端修复：先按时间戳备份旧 runtime/cache，再让 Desktop 重新生成。**

## 安全原则

这个 skill 的修复部分必须由用户手动执行。每个可能改变本地状态的操作都遵循：

1. 先保存交接说明到 Codex 外部的文本文件。
2. 用户手动完全退出 Codex Desktop。
3. CLI 已更新但 Desktop 仍缺模型时，先按时间戳重命名为备份，再让应用重新生成 runtime 或缓存。
4. 每一步先给出回滚命令，再给出修复命令。
5. 绝不触碰认证文件、令牌、聊天记录或凭据。

完整流程见 [恢复流程 / Recovery workflow](references/recovery-workflow.md)。

## 使用方式

将本仓库作为一个 skill 安装到 Codex 的 skills 目录中，然后在 Codex 中请求类似下面的帮助：

```text
Codex 更新后 Windows 桌面端不显示 GPT-5.6，但命令行版本较新。请使用 codex-windows-runtime-repair 先做只读诊断，并在任何修复前给我可保存的交接与回滚说明。
```

也可先在 PowerShell 中手动执行只读诊断：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\collect-diagnostics.ps1
```

请先阅读输出；路径中可能包含个人用户名，不要直接把原始结果公开发布。

## 仓库内容

| 文件 | 用途 |
| --- | --- |
| `SKILL.md` | Codex 必须遵守的人工操作与回滚安全规则。 |
| `references/recovery-workflow.md` | 中英对照的诊断、恢复和回滚流程。 |
| `scripts/collect-diagnostics.ps1` | 只读诊断脚本，不写入、不安装、不修改配置。 |
| `README.en.md` | 英文说明。 |

## 贡献与隐私

提交 issue 或 PR 前，请删除用户名、完整本地路径、日志、认证信息、令牌、Cookie 和缓存内容。不要提交 `.codex` 目录、`auth.json` 或诊断输出文件。

本项目采用 [MIT License](LICENSE)。
