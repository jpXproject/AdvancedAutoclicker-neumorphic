# Grok AutoClicker for Roblox

[![Lua](https://img.shields.io/badge/Lua-5.1-blue.svg)](https://www.lua.org/)
[![Roblox](https://img.shields.io/badge/Platform-Roblox-green.svg)](https://www.roblox.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Modern neumorphic-style **auto clicker** with recording & playback, made specifically for Roblox games.  
Designed to feel professional, clean, and user-friendly while keeping the classic "hacker green terminal" aesthetic.

## Features

- Adjustable click interval (hours / minutes / seconds / milliseconds)
- Left / Right / Middle mouse button support
- Single / Double / Triple click modes
- Infinite or limited repetitions
- Dynamic (current cursor) or Fixed position clicking
- Customizable hotkey (default: F6)
- Record mouse clicks → Save → Load → Playback automation
- Anti-detection mode (randomized human-like delays)
- Auto-farm toggle helper
- **Resizable neumorphic UI** with smooth shadows and modern layout
- Status indicator & clean visual feedback

## Quick Load (most popular executors)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/autoclicker.lua"))()
