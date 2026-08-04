# ⚡ Lullaby Modular v14.1

A highly modular, open-source Roblox utility script featuring an asynchronous execution engine and powered by the **WindUI** library. Lullaby is designed to be failsafe, anti-crash, and highly customizable.

---

## 🛠️ Features

*   **🎯 Aimbot Core**
    *   Customizable FOV size and visibility.
    *   Smooth camera locking (adjustable aiming speed).
    *   Advanced targeting rules (Players vs. MCP/Bots).
    *   Specific body part targeting (Head, Torso, Limbs).
*   **👁️ ESP Visuals (Anti-Freeze)**
    *   Asynchronous map scanning to prevent game freezes.
    *   Customizable overlays: Boxes, Names, Distance, and Health bars.
    *   Skeletal rendering and customizable Tracer lines.
    *   Dynamic color coding based on Entity State (Player, MCP, Item).
*   **🪄 Magic & Exploits**
    *   **Movement Core:** Adjustable Speed Boost, Jump Power, and Air Jump (Multi-jump).
    *   **God Mode:** Bypasses bot/MCP FOV targeting (Renames Humanoid) and disables physical damage from entities.
    *   **Trap Immunity:** Safely destroys touch-transmitters on map traps/items without triggering them.
    *   **Invisibility (Ghost Mode):** Leaves a fake clone behind while letting you roam undetected.
*   **📍 Teleportation System**
    *   Save custom map waypoints.
    *   Instantly travel to saved locations.
    *   Clean UI for managing and deleting waypoints.
*   **🗺️ Debug Roadmap Engine**
    *   Global entity registry for tracking all objects in the game.
    *   Manually force-assign entities to specific rendering layers (ESP/Green, MCP/Red, Item/Orange).

---

## 🚀 How to Execute

Copy and paste the following `loadstring` into your Roblox executor:

```lua
loadstring(game:HttpGet("[https://raw.githubusercontent.com/RAFSUN-BOSS-ACTIV/Roblox/refs/heads/main/main.lua](https://raw.githubusercontent.com/RAFSUN-BOSS-ACTIV/Roblox/refs/heads/main/main.lua)"))()
