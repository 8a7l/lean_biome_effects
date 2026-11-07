# Lean Biome Effects

A lightweight, lag-free mod for Luanti that changes player physics based on the surrounding climate (Heat and Humidity).

No `globalstep`, no heavy calculations, no visual screen overlays — just pure gameplay mechanics and a clean HUD.

## Features

- **Climate-based physics:** Uses Luanti's built-in `heat` and `humidity` biome data. Works with any biome mod without needing to hardcode biome names.
- **Cold (Snow):** Reduces movement speed by 20% (hard to walk in deep snow).
- **Desert:** Increases movement speed by 15% (easy to run on sand).
- **Jungle:** Reduces jump height, increases gravity, and slightly slows movement (hard to navigate through dense foliage).
- **Cave awareness:** Automatically disables all surface biome effects when the player goes below `y = -10`. The underground climate is stable.
- **Smart HUD:** Displays the active biome effect in the bottom-center of the screen. The HUD disappears in normal biomes (like forests or plains) and in caves.
- **Zero overhead:** The mod checks the player's biome once every 2 seconds. If the biome hasn't changed, it does nothing.

## Configuration

You can easily tweak the thresholds, speed multipliers, and HUD colors in the `biome_effects` logic inside `init.lua`. 

By default:
- **Cold:** `heat < 25`
- **Desert:** `heat > 65` and `humidity < 35`
- **Jungle:** `heat > 65` and `humidity > 65`

## License

- **Code:** GPL-3.0-only (Copyright (C) 2026 8a7l)

Feel free to use, modify, and distribute this mod under the terms of this license.