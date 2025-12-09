# Hyprmixer Clone Project

A volume mixer and media controller for Hyprland, reimplemented in a systems language.

Reference: https://github.com/Torelli/hyprmixer

## Core Features to Implement

1. **Volume Control** - Get/set sink volumes via PipeWire/PulseAudio
2. **Media Control** - Play/pause/next/prev via MPRIS D-Bus
3. **GUI** - Sliders, buttons, media info display

## No playerctl Needed

MPRIS is just D-Bus. The interface is:
- Bus: `org.mpris.MediaPlayer2.*` (e.g., `org.mpris.MediaPlayer2.spotify`)
- Path: `/org/mpris/MediaPlayer2`
- Interface: `org.mpris.MediaPlayer2.Player`
- Methods: `Play`, `Pause`, `PlayPause`, `Next`, `Previous`, `Stop`
- Properties: `Metadata`, `PlaybackStatus`, `Volume`, `Position`

---

## Go Implementation

**Libraries:**
- `github.com/godbus/dbus/v5` - MPRIS/D-Bus
- `github.com/lawl/pulseaudio` - Volume control
- `github.com/diamondburned/gotk4` - GTK4 GUI

**Skeleton:**
```go
package main

import (
    "github.com/godbus/dbus/v5"
    "github.com/diamondburned/gotk4/pkg/gtk/v4"
)

func main() {
    conn, _ := dbus.SessionBus()

    // List active players
    var names []string
    conn.BusObject().Call("org.freedesktop.DBus.ListNames", 0).Store(&names)
    // Filter for org.mpris.MediaPlayer2.*

    // Control a player
    player := conn.Object("org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2")
    player.Call("org.mpris.MediaPlayer2.Player.PlayPause", 0)

    // Get metadata
    variant, _ := player.GetProperty("org.mpris.MediaPlayer2.Player.Metadata")
    metadata := variant.Value().(map[string]dbus.Variant)
    title := metadata["xesam:title"].Value().(string)

    // GTK4 app setup...
}
```

**Build:** `go build -o hyprmixer`

---

## C Implementation

**Libraries:**
- `libdbus-1` or `libgio-2.0` - D-Bus/MPRIS
- `libpulse` - PulseAudio volume
- `libpipewire-0.3` - PipeWire (alternative)
- `gtk4` - GUI

**Skeleton:**
```c
#include <gtk/gtk.h>
#include <gio/gio.h>
#include <pulse/pulseaudio.h>

// MPRIS via GDBus
void play_pause(const char *player_name) {
    GDBusConnection *conn = g_bus_get_sync(G_BUS_TYPE_SESSION, NULL, NULL);
    g_dbus_connection_call_sync(
        conn,
        player_name,  // e.g., "org.mpris.MediaPlayer2.spotify"
        "/org/mpris/MediaPlayer2",
        "org.mpris.MediaPlayer2.Player",
        "PlayPause",
        NULL, NULL,
        G_DBUS_CALL_FLAGS_NONE,
        -1, NULL, NULL
    );
}

// PulseAudio volume
static void sink_info_cb(pa_context *c, const pa_sink_info *i, int eol, void *userdata) {
    if (eol > 0) return;
    // i->volume, i->name, i->description
}

void get_volumes(pa_context *ctx) {
    pa_context_get_sink_info_list(ctx, sink_info_cb, NULL);
}

// GTK4 app
static void activate(GtkApplication *app, gpointer user_data) {
    GtkWidget *window = gtk_application_window_new(app);
    GtkWidget *scale = gtk_scale_new_with_range(GTK_ORIENTATION_HORIZONTAL, 0, 100, 1);
    // ...
}

int main(int argc, char **argv) {
    GtkApplication *app = gtk_application_new("com.example.mixer", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    return g_application_run(G_APPLICATION(app), argc, argv);
}
```

**Build:**
```bash
gcc -o hyprmixer main.c $(pkg-config --cflags --libs gtk4 libpulse gio-2.0)
```

**Nix dev shell:**
```nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [ gtk4 libpulseaudio glib pkg-config ];
}
```

---

## Odin Implementation

**Approach:** Bind to C libraries directly (Odin makes this easy)

**Skeleton:**
```odin
package main

import "core:fmt"
import "core:c"

// Bind to GIO for D-Bus
foreign import gio "system:gio-2.0"
foreign import gobject "system:gobject-2.0"

foreign gio {
    g_bus_get_sync :: proc(bus_type: c.int, cancellable: rawptr, error: ^rawptr) -> rawptr ---
    g_dbus_connection_call_sync :: proc(
        connection: rawptr,
        bus_name: cstring,
        object_path: cstring,
        interface_name: cstring,
        method_name: cstring,
        parameters: rawptr,
        reply_type: rawptr,
        flags: c.int,
        timeout_msec: c.int,
        cancellable: rawptr,
        error: ^rawptr,
    ) -> rawptr ---
}

G_BUS_TYPE_SESSION :: 2

play_pause :: proc(player: cstring) {
    err: rawptr = nil
    conn := g_bus_get_sync(G_BUS_TYPE_SESSION, nil, &err)
    g_dbus_connection_call_sync(
        conn,
        player,
        "/org/mpris/MediaPlayer2",
        "org.mpris.MediaPlayer2.Player",
        "PlayPause",
        nil, nil, 0, -1, nil, &err,
    )
}

main :: proc() {
    play_pause("org.mpris.MediaPlayer2.spotify")
}
```

**For GTK4:** Use `vendor:raylib` for simpler graphics, or create GTK4 bindings.

**Build:**
```bash
odin build . -out:hyprmixer -extra-linker-flags:"$(pkg-config --libs gio-2.0 gtk4 libpulse)"
```

---

## Effort Comparison

| Task                  | Go       | C        | Odin     |
|-----------------------|----------|----------|----------|
| MPRIS (D-Bus)         | 2-4 hrs  | 4-8 hrs  | 4-8 hrs  |
| Volume (PipeWire/PA)  | 4-8 hrs  | 4-8 hrs  | 8-16 hrs |
| GUI                   | 1-2 days | 1-2 days | 2-3 days |
| Total                 | 2-3 days | 1-2 wks  | 1-2 wks  |

## Why Skip Electron

- Hyprmixer (Electron): ~150-300MB RAM
- Native implementation: ~20-50MB RAM
- Startup: instant vs 1-2 seconds

## Resources

- MPRIS spec: https://specifications.freedesktop.org/mpris-spec/latest/
- PipeWire docs: https://docs.pipewire.org/
- GTK4 docs: https://docs.gtk.org/gtk4/
- Odin docs: https://odin-lang.org/docs/
