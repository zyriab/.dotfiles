# Waybar Custom Menus - Requirements & Implementation Plan

## Overview
Custom waybar modules with interactive submenus to replace hyprpanel functionality while maintaining low resource usage. Built in Go with TOML configuration and optional Lua embedding for extensibility.

## Tech Stack

### Core: Go
- Single binary per tool (bluetooth, wifi, volume, calendar)
- Direct D-Bus API access (no subprocess overhead)
- Fast compilation, easy distribution
- Built-in concurrency for monitoring
- Good Nix integration via `buildGoModule`

### Configuration: TOML with Go Templates
- Simple key-value configs in TOML
- **Go templating** for dynamic values
- **Go date formatting** for time displays
- Example:
  ```toml
  [clock]
  primary_format = "{{ .Now.Format \"Mon Jan 02, 15:04\" }}"
  secondary_format = "{{ .Now.In \"America/Denver\" | .Format \"15:04\" }} MST"

  [bluetooth]
  device_template = "{{ .Name }} {{ if .Battery }}({{ .Battery }}%){{ end }}"
  ```

### Scripting: Lua (embedded when needed)
- User-defined actions/filters
- Custom logic without recompiling
- Embedded via `github.com/yuin/gopher-lua`
- Optional - only add when actually needed

### UI: Rofi/Wofi
- Simple, keyboard-driven menus
- Integrates well with Wayland
- Already installed and configured

---

## Priority Order (Easiest → Hardest)

1. **Bluetooth controls** - Common pain point, good learning ground
2. **WiFi controls** - Similar patterns to bluetooth
3. **Volume/Audio controls** - More complex, multiple sliders
4. **Media controls** - Moderate complexity
5. **Calendar with Google** - Most complex, separate project

---

## 1. Bluetooth Controls

### Display (Waybar Module)
```toml
[bluetooth]
icon_connected = ""
icon_disconnected = ""
icon_off = ""
format = "{{ .Icon }} {{ if .Connected }}{{ .DeviceName }}{{ end }}"
```

### Submenu Features
- **List paired devices** with connection status
- **Connect/Disconnect** devices
- **Pair new devices**
  - Scan for available devices
  - Show pairable devices
  - Handle pairing flow
- **Unpair/Remove** devices from paired list
- **Toggle bluetooth adapter** on/off
- **Show device details**
  - Battery level (if supported)
  - Signal strength
  - Device type

### Technical Implementation
- **D-Bus API**: `org.bluez` (BlueZ 5.x)
- **Status monitoring**: Subscribe to D-Bus signals for real-time updates
- **Menu**: Rofi with custom formatting

### Go Libraries
- `github.com/godbus/dbus/v5` - D-Bus communication
- `github.com/BurntSushi/toml` - Config parsing

### Estimated Time
- Basic connect/disconnect: 4-6 hours
- Pairing flow: 2-3 hours
- Polish & config: 2 hours
- **Total: ~8-11 hours** (1-2 focused days)

---

## 2. WiFi Controls

### Display (Waybar Module)
```toml
[wifi]
format_connected = " {{ .SSID }} ({{ .Strength }}%)"
format_disconnected = " Disconnected"
format_ethernet = " {{ .Interface }}"
strength_icons = ["", "", "", "", ""]
```

### Submenu Features
- **List available networks**
  - SSID name
  - Signal strength indicator
  - Security type (WPA2, Open, etc.)
  - Currently connected network highlighted
- **Connect to network**
  - Password prompt for secured networks
  - Remember password option
- **Disconnect** from current network
- **Forget saved networks**
- **Toggle WiFi** on/off
- **Scan** for networks (manual refresh)
- **Show ethernet status** if connected
  - Interface name
  - Speed
  - IP address

### Technical Implementation
- **D-Bus API**: `org.freedesktop.NetworkManager`
- **Password input**: Rofi password mode or dmenu
- **Status monitoring**: NetworkManager D-Bus signals

### Go Libraries
- Same as bluetooth (godbus, toml)

### Estimated Time
- Basic connect/disconnect: 4-6 hours
- Password handling: 2-3 hours
- Saved networks management: 2 hours
- **Total: ~8-11 hours** (builds on bluetooth patterns)

---

## 3. Volume/Audio Controls

### Display (Waybar Module)
```toml
[volume]
format = "{{ .Icon }} {{ .Volume }}%"
format_muted = " {{ .Volume }}%"
icons = ["", "", ""]
volume_thresholds = [0, 33, 66]
```

### Submenu Features

#### Main View
- **Volume slider** for main output (0-100%)
- **Microphone input slider**
- **Mute toggles**
  - Click volume icon to mute/unmute output
  - Click mic icon to mute/unmute input
- **Device selection dropdowns**
  - Playback devices (speakers, headphones, etc.)
  - Input devices (mics)
  - Show current device highlighted

#### Advanced View (Toggle Button)
- **Per-application volume control**
  - List all active playback streams
  - Individual volume sliders per app
  - Mute button per app
  - Show app name and icon
- **Switch button** to toggle between simple/advanced view

#### Settings
- **Launch pwvucontrol** button for full audio settings

### Technical Implementation
- **D-Bus API**: `org.freedesktop.portal.Desktop` or WirePlumber directly
- **Command alternatives**: `wpctl` (WirePlumber) or `pactl` (PulseAudio compat)
- **Slider UI**: Custom rofi script or small GTK dialog

### Go Libraries
- godbus for WirePlumber/PipeWire
- Possibly `github.com/diamondburned/gotk4` for custom slider UI

### Challenges
- Slider implementation (may need GTK or custom rofi hack)
- Per-app volume requires stream enumeration
- Most complex of the "basic" tools

### Estimated Time
- Basic volume/mute: 6-8 hours
- Device selection: 3-4 hours
- Per-app control: 6-8 hours
- UI polish: 4-6 hours
- **Total: ~19-26 hours** (2-3 focused days)

---

## 4. Media Controls

### Display (Waybar Module)
```toml
[media]
format = "{{ .Icon }} {{ .Artist }} - {{ .Title }}"
format_paused = "{{ .Icon }} {{ .Title }}"
max_length = 50
icons = {
  playing = "",
  paused = ""
}
```

### Submenu Features
- **Current player info**
  - Album art (if available)
  - Title, Artist, Album
  - Progress bar
- **Playback controls**
  - Previous track
  - Play/Pause toggle
  - Next track
  - Stop (if supported)
- **Multiple players**
  - List all active media players
  - Switch active player
  - Control each independently
  - Show which is currently playing

### Technical Implementation
- **D-Bus API**: MPRIS2 (`org.mpris.MediaPlayer2.*`)
- **Players**: Spotify, Firefox, Chrome, VLC, etc. all support MPRIS
- **Fallback**: Can use `playerctl` if needed

### Go Libraries
- godbus for MPRIS

### Estimated Time
- Basic playback controls: 4-6 hours
- Multiple player support: 3-4 hours
- UI/polish: 2-3 hours
- **Total: ~9-13 hours** (1-2 days)

---

## 5. Calendar with Google Integration

### Display - Dual Clocks

#### Primary Clock (Local Time)
```toml
[clock.primary]
format = "{{ .Now.Format \"Mon Jan 02, 15:04\" }}"
timezone = "Local"
font_size = "14px"
```

#### Secondary Clock (MST)
```toml
[clock.secondary]
format = "{{ .Now.In \"America/Denver\" | .Format \"15:04\" }} MST"
timezone = "America/Denver"
font_size = "11px"
```

### Submenu Features

#### Calendar Grid
- **Interactive month view**
  - Current day highlighted/focused
  - Navigate months (< > arrows)
  - Navigate years (dropdown or buttons)
  - Quick "Today" button
- **Event indicators**
  - Dots/badges on dates with events
  - Color-coded by calendar (if multiple)
  - Show number of events if >1
- **Date selection**
  - Click date to select
  - Updates events section below

#### Events Section
- **Event list for selected date**
  - Time (formatted with Go templates)
  - Title
  - Location (if any)
  - Calendar name/color
- **Event details on click**
  - Full description
  - Attendees
  - Conference link (if virtual)
  - Edit in browser link
- **Navigation**
  - "Back to Today" button
  - "Open in Calendar" button (launches browser/app)

### Technical Implementation

#### Google Calendar API
- **OAuth 2.0 flow**
  - Initial authorization
  - Token storage (encrypted)
  - Token refresh
- **API endpoints**
  - CalendarList.list (get user's calendars)
  - Events.list (get events for date range)
  - Events.get (get event details)
- **Caching**
  - Local SQLite database
  - Sync on startup + periodic refresh
  - Background sync every 15-30 min

#### UI
- **GTK4** for calendar widget
  - Native look and feel
  - Good date picker widgets
  - Can embed in popup window
- **Go templates** for event formatting

### Go Libraries
- `github.com/diamondburned/gotk4` - GTK4 bindings
- `golang.org/x/oauth2` - OAuth flow
- `google.golang.org/api/calendar/v3` - Google Calendar API
- `github.com/mattn/go-sqlite3` - Local caching

### Configuration
```toml
[calendar]
client_id = "{{ .Env.GOOGLE_CLIENT_ID }}"
client_secret_file = "~/.config/waybar-tools/google-secret.enc"

[calendar.display]
first_day_of_week = "Monday"
date_format = "{{ .Date.Format \"Jan 02\" }}"
time_format = "{{ .Time.Format \"15:04\" }}"
event_template = """
{{ .Time.Format "15:04" }} - {{ .Title }}
{{ if .Location }}  {{ .Location }}{{ end }}
"""

[calendar.sync]
interval_minutes = 15
cache_days = 30
```

### Challenges
- **OAuth flow** - Need to handle browser redirect
- **Token security** - Store encrypted tokens
- **UI complexity** - Calendar grid is non-trivial
- **Sync logic** - Handle offline, conflicts, etc.
- **Multiple calendars** - Merging events, colors
- **Timezone handling** - Event times vs display times

### Estimated Time
- OAuth + API integration: 6-10 hours
- Local caching/sync: 6-8 hours
- Calendar UI (GTK): 10-15 hours
- Event list UI: 4-6 hours
- Configuration/templating: 3-4 hours
- Testing/debugging: 6-8 hours
- **Total: ~35-51 hours** (5-7 focused days)

### Recommendation
**Build as separate project from other tools.** This is complex enough to be its own thing. Could even be useful as standalone calendar app.

---

## Implementation Strategy

### Phase 1: Foundation (Bluetooth) - Week 1
**Goal:** Working bluetooth menu, establish patterns

- Set up Go project structure
- Implement D-Bus bluetooth API wrapper
- Create rofi menu integration
- TOML config loading
- Build with Nix

**Deliverable:** `btctl` binary that shows menu and manages bluetooth

### Phase 2: WiFi - Week 2
**Goal:** Reuse bluetooth patterns for WiFi

- Implement NetworkManager D-Bus wrapper
- Password input handling
- Saved networks management
- Similar menu structure to bluetooth

**Deliverable:** `wifictl` binary with full WiFi management

### Phase 3: Volume - Week 3
**Goal:** More complex UI, sliders

- WirePlumber/PipeWire integration
- Device enumeration
- Slider UI (investigate GTK vs rofi hacks)
- Per-app volume (advanced feature)

**Deliverable:** `volctl` binary for audio control

### Phase 4: Media - Week 4
**Goal:** MPRIS integration, multiple players

- MPRIS D-Bus wrapper
- Multi-player handling
- Playback controls

**Deliverable:** `mediactl` binary for media control

### Phase 5: Calendar - Separate Project
**Goal:** Full-featured calendar with Google sync

- Plan separately
- Much larger scope
- Could be useful beyond waybar
- Consider using existing calendar apps instead for MVP

---

## Project Structure

```
waybar-tools/
├── cmd/
│   ├── btctl/           # Bluetooth controller
│   │   └── main.go
│   ├── wifictl/         # WiFi controller
│   │   └── main.go
│   ├── volctl/          # Volume controller
│   │   └── main.go
│   └── mediactl/        # Media controller
│       └── main.go
├── pkg/
│   ├── config/          # TOML loading + templating
│   │   ├── config.go
│   │   └── template.go
│   ├── dbus/            # D-Bus helpers
│   │   ├── bluetooth.go
│   │   ├── network.go
│   │   ├── audio.go
│   │   └── mpris.go
│   ├── ui/              # UI helpers (rofi, GTK)
│   │   ├── menu.go
│   │   └── dialog.go
│   └── common/          # Shared utilities
│       └── utils.go
├── configs/
│   └── waybar-tools.toml
├── flake.nix            # Nix build definition
├── go.mod
└── README.md
```

---

## Configuration Examples

### Main Config (waybar-tools.toml)
```toml
[bluetooth]
auto_connect = true
show_battery = true
device_template = "{{ .Name }}{{ if .Battery }} ({{ .Battery }}%){{ end }}"

[wifi]
scan_interval = 30
show_saved_networks = true
strength_template = "{{ .SSID }} {{ .StrengthBar }}"

[volume]
step = 5  # Volume change increment
show_percentage = true
default_view = "simple"  # or "advanced"

[media]
max_title_length = 50
show_album_art = true
preferred_player = "spotify"  # Focus this player if multiple

# Go templates can reference environment variables
[paths]
rofi_theme = "{{ .Env.HOME }}/.config/rofi/launcher.rasi"
```

### Waybar Integration
```json
{
  "modules-left": ["hyprland/workspaces"],
  "modules-center": ["custom/media"],
  "modules-right": [
    "custom/bluetooth",
    "custom/wifi",
    "custom/volume",
    "clock"
  ],

  "custom/bluetooth": {
    "exec": "btctl status",
    "on-click": "btctl menu",
    "interval": 5
  },

  "custom/wifi": {
    "exec": "wifictl status",
    "on-click": "wifictl menu",
    "interval": 5
  },

  "custom/volume": {
    "exec": "volctl status",
    "on-click": "volctl menu",
    "on-scroll-up": "volctl increase",
    "on-scroll-down": "volctl decrease"
  },

  "clock": {
    "format": "{:%a %b %d, %H:%M}",
    "format-alt": "{:%H:%M MST}",
    "timezone": "America/Denver"
  }
}
```

---

## Go Template Examples

### Device Formatting
```toml
# Bluetooth device display
device_template = """
{{ .Icon }} {{ .Name }}
{{- if .Connected }} ✓{{ end }}
{{- if .Battery }} ({{ .Battery }}%){{ end }}
"""

# WiFi network display
network_template = """
{{ .SignalIcon }} {{ .SSID }}
{{- if .Secured }} {{ end }}
{{- if .Saved }} ★{{ end }}
"""
```

### Time Formatting
```toml
# Using Go's time.Format
primary_clock = "{{ .Now.Format \"Mon Jan 02, 15:04\" }}"
secondary_clock = "{{ .Now.In \"America/Denver\" | .Format \"15:04\" }} MST"

# Event time in calendar
event_time = "{{ .Event.Start.Format \"3:04 PM\" }}"
```

### Conditional Logic
```toml
# Show different icons based on state
bluetooth_icon = """
{{ if .Powered }}
  {{ if .Connected }}{{ else }}{{ end }}
{{ else }}

{{ end }}
"""
```

---

## Next Steps

1. **Start with Bluetooth** - Best learning opportunity
2. **Set up project structure** - Get Go + Nix working
3. **Implement basic D-Bus** - Connect to BlueZ
4. **Create simple menu** - Rofi integration
5. **Add TOML config** - With Go templating
6. **Iterate and polish**

Once bluetooth is working, WiFi will be fast to add using the same patterns. Volume and media can come after, and calendar is a separate long-term project.

---

## Optional: Lua Embedding

If you find cases where users want to extend functionality without recompiling:

```go
// Example: User-defined device filter in Lua
func (b *BluetoothCtl) FilterDevices() []Device {
    if b.config.LuaFilter != "" {
        L := lua.NewState()
        defer L.Close()

        // Expose devices to Lua
        L.SetGlobal("devices", devicesToLuaTable(b.devices))

        // Run user's filter script
        L.DoString(b.config.LuaFilter)

        // Get filtered results
        return luaTableToDevices(L.GetGlobal("filtered"))
    }
    return b.devices
}
```

User config:
```toml
[bluetooth]
lua_filter = """
filtered = {}
for i, device in ipairs(devices) do
  if device.name:match("Headphones") then
    table.insert(filtered, device)
  end
end
"""
```

Only add this if you actually need it. Start with pure Go + templates.

---

## Feasibility Assessment

| Tool | Complexity | Time Estimate | Priority |
|------|-----------|---------------|----------|
| Bluetooth | Easy | 8-11 hours | P0 (Start here) |
| WiFi | Easy | 8-11 hours | P0 |
| Volume | Medium | 19-26 hours | P1 |
| Media | Medium | 9-13 hours | P1 |
| Calendar | Hard | 35-51 hours | P2 (Separate project) |

**Total for P0+P1: ~44-61 hours** (~6-8 focused days)

Totally doable! Start with bluetooth this weekend and you'll have a working prototype to iterate on.
