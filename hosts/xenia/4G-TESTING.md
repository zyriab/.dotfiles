# 4G Module Testing Guide

## Prerequisites

- uConsole with 4G expansion module installed
- SIM card (nano-SIM)
- `hardware.uc-4g.enable = true;` in your config
- Rebuild completed: `nixos-rebuild switch`

## Testing Steps

### 1. Check if modem is detected

```bash
mmcli -L
```

Should show something like:
```
/org/freedesktop/ModemManager1/Modem/0 [Quectel] EG25-G
```

If nothing appears, the module may not be powered on.

### 2. Power on the 4G module

```bash
uc-4g on
```

Wait 10-15 seconds for the modem to initialize.

### 3. Verify modem status

```bash
mmcli -m 0
```

Look for:
- `state: enabled` or `registered`
- `signal quality: XX%`

### 4. Insert SIM card

Power off the 4G module first:
```bash
uc-4g off
```

Insert nano-SIM into the slot (under the battery), then power back on:
```bash
uc-4g on
```

### 5. Check SIM is detected

```bash
mmcli -m 0 --sim
```

Should show SIM details and operator info.

### 6. Connect via NetworkManager

```bash
nmtui
```

- Select "Activate a connection"
- Or "Add" → "Mobile Broadband"
- Select your carrier/country
- Enter APN if required (check with carrier)

### 7. Test connectivity

```bash
# Check IP
ip addr show wwan0

# Test internet
ping -c 4 8.8.8.8
curl ifconfig.me
```

## Troubleshooting

### Modem not detected
```bash
# Check USB devices
lsusb | grep -i quectel

# Check kernel messages
dmesg | grep -i modem
dmesg | grep -i quectel
```

### Module won't power on
```bash
# Check GPIO status
cat /sys/class/gpio/gpio*/value

# Try power cycle
uc-4g off
sleep 2
uc-4g on
```

### No signal
- Check antenna is connected
- Try moving to area with better coverage
- Verify SIM is active with carrier

### APN Issues

Common APNs:
- T-Mobile: `fast.t-mobile.com`
- AT&T: `broadband`
- Verizon: `vzwinternet`

Check with your carrier for correct APN settings.

## Power Management

```bash
# Power off to save battery
uc-4g off

# Check status
uc-4g status
```
