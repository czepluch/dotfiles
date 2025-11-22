# Avante.nvim Guide

Cursor-like AI chat interface in Neovim, powered by OpenCode via ACP.

## Why This Setup Works

- ✅ Uses your Claude Pro/Max subscription (no separate API billing)
- ✅ No API keys needed (OAuth authentication already configured)
- ✅ Access to any model OpenCode supports (75+ providers)
- ✅ No Node.js dependencies - native ACP support

---

## Quick Test

Open Neovim and press `<leader>aa` to start chatting with OpenCode.

---

## Usage

**Open chat:** `<leader>aa`  
**Edit selection:** `<leader>ae` (visual mode)  
**Toggle sidebar:** `<leader>at`  

**Switch windows:**
- `<leader>af` - Focus Avante sidebar
- `<C-w>w` - Cycle back to code window
- `<C-w>h` / `<C-w>l` - Move left/right between windows
- `<Tab>` within sidebar - Switch between sidebar elements

**Review diffs** (legacy mode - manual approval required):
- `]x` / `[x]` - Jump between changes
- `ct` - Accept AI suggestion
- `co` - Keep your code
- `ca` - Accept all changes

Note: Config uses `mode = "legacy"` for manual diff review. Change to `mode = "agentic"` if you want auto-apply.

---

## Switching Models

```bash
opencode models              # List available models
opencode -m openai/gpt-4o    # Switch to different model
```

---

## Known Limitations

**ACP sessions don't persist:** When using OpenCode via ACP, sessions only last while Neovim is open. After restarting Neovim:
- Old conversations in the sidebar won't work
- Always start a new ask (`<leader>aa`) for fresh sessions
- This is an ACP protocol limitation, not specific to Avante/OpenCode

---

**Links:** [Avante](https://github.com/yetone/avante.nvim) · [OpenCode](https://opencode.ai/docs) · [ACP](https://opencode.ai/docs/acp/)
