# GitHub Dark Colorblind Theme

Personal theme based on GitHub Dark Colorblind palette, optimized for protanopia.

## Base Colors

| Name       | Hex         | Usage                        |
|------------|-------------|------------------------------|
| background | `#0d1117`   | Main background              |
| foreground | `#c9d1d9`   | Main text                    |
| selection  | `#1e4273`   | Selection background         |

## ANSI Colors (Normal)

| Index | Name    | Hex         | Usage                          |
|-------|---------|-------------|--------------------------------|
| 0     | black   | `#484f58`   | Dark gray                      |
| 1     | red     | `#ec8e2c`   | Orange (replaces red)          |
| 2     | green   | `#58a6ff`   | Blue (replaces green)          |
| 3     | yellow  | `#d29922`   | Yellow/Gold                    |
| 4     | blue    | `#58a6ff`   | Blue                           |
| 5     | magenta | `#bc8cff`   | Purple                         |
| 6     | cyan    | `#39c5cf`   | Cyan                           |
| 7     | white   | `#b1bac4`   | Light gray                     |

## ANSI Colors (Bright)

| Index | Name    | Hex         | Usage                          |
|-------|---------|-------------|--------------------------------|
| 0     | black   | `#6e7681`   | Gray                           |
| 1     | red     | `#fdac54`   | Bright orange (replaces red)   |
| 2     | green   | `#79c0ff`   | Bright blue (replaces green)   |
| 3     | yellow  | `#e3b341`   | Bright yellow                  |
| 4     | blue    | `#79c0ff`   | Bright blue                    |
| 5     | magenta | `#d2a8ff`   | Bright purple                  |
| 6     | cyan    | `#56d4dd`   | Bright cyan                    |
| 7     | white   | `#ffffff`   | White                          |

## Special/Accent Colors

| Name       | Hex         | Usage                                    |
|------------|-------------|------------------------------------------|
| neon_pink  | `#ef0fff`   | High visibility alerts (caps lock, etc.) |
| neon_green | `#38d878`   | High visibility success/search           |
| black      | `#000000`   | Pure black                               |
| white      | `#ffffff`   | Pure white                               |

## Semantic Colors

| Name    | Hex         | Usage                     |
|---------|-------------|---------------------------|
| info    | `#58a6ff`   | Information, links        |
| success | `#39c5cf`   | Success states            |
| warning | `#d29922`   | Warnings                  |
| error   | `#ec8e2c`   | Errors (orange, not red)  |
| accent  | `#79c0ff`   | Highlights, active states |
| muted   | `#8b949e`   | Disabled, secondary text  |

## UI Mappings

### Waybar / Hyprland
- Background: `#0d1117` (with opacity for floating effect)
- Text: `#c9d1d9`
- Active workspace: `#fdac54` (bright orange)
- Inactive workspace: `#c9d1d9`
- Border active: `#79c0ff`
- Border inactive: `#0d1117`
- Clock: `#58a6ff`
- CPU: `#39c5cf`
- Memory: `#bc8cff`
- Audio: `#bc8cff`

### Hyprlock
- Input border: `#79c0ff`
- Check/Success: `#39c5cf`
- Fail/Error: `#ec8e2c` (orange)
- Caps lock: `#ef0fff` (neon pink)

### Notifications (swaync)
- Background: `#0d1117` (0.8-0.9 opacity)
- Border: `#79c0ff` (0.3 opacity)
- Text: `#c9d1d9`
- Close button: `#ff9492`

## Notes

- **No red-green combinations**: Red is replaced with orange, green with blue/cyan
- **High contrast accents**: Neon pink/green for critical alerts
- **Consistent opacity**: 0.8-0.9 for backgrounds, creates floating effect
- **Border radius**: 6-8px for rounded corners throughout
