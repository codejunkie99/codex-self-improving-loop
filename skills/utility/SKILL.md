---
name: utility
description: Show the utility-to-model menu for slash commands. Use when the user invokes /utility or asks for the model menu.
---

# Utility menu

Print this table and nothing else:

| Slash command | Utility | Model |
| --- | --- | --- |
| `/loop` | self-improving loop | DeepSeek runs, Luna watches, Sol rewrites |
| `/flash` | fast DeepSeek | `opencode-go/deepseek-v4-flash` |
| `/deepseek` | deep reasoning | `opencode-go/deepseek-v4-pro` |
| `/luna` | grade / watch / worker | `gpt-5.6-luna` |
| `/sol` | review / rewrite | `gpt-5.6-sol` |
| `/build` | implement and verify | `opencode-go/deepseek-v4-pro` |

The user can mention a utility name instead of configuring a model.
