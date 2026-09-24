# Tux Universal Package Manager

A fast, lightweight, and colored package manager built for Linux, WSL, and Debian-based systems. **Tux** pulls directly from remote repositories like `tuxrepository`, resolves device architecture (x86_64, arm64, i386), downloads payloads, and installs packages seamlessly.

---

## Features

- **Multi-Architecture Resolution**: Automatically maps payloads for AMD64 (`url_amd64`), ARM64 (`url_arm64`), Raspberry Pi, and i386 (`url_i386`).
- **Flexible Package Formats**: Supports `.deb` packages (via `dpkg`), `.tar.gz`/`.pkg`/`.tgz` system tarballs, and executable installation scripts (`.sh`, `.bin`).
- **Rich Terminal Styling**: Color-coded architecture badges, environment tags (WSL, Mac, Raspberry Pi), and package status indicators.
- **Package State Tracking**: Maintains an installed package manifest at `/var/lib/tux/lock.json`.
- **Zero Third-Party Dependencies**: Written entirely in pure Python 3 using standard library modules.

---

## Installation (Linux / WSL)

### One-Line Install via APT (Recommended)
Download and install the official `.deb` package directly with APT in a single command:

```bash
curl -fsSL https://github.com/CrimsonOnGit-hub/tux/releases/download/v1.0.0/tux_1.0.0_all.deb -o tux.deb && sudo apt install -y ./tux.deb && rm tux.deb
```

### Build from Source via Installer
Alternatively, you can clone the repository and run `install.sh`:

```bash
git clone https://github.com/CrimsonOnGit-hub/tux.git
cd tux
sudo ./install.sh
```

Once installed, you can execute Tux from any directory simply with:
```bash
tux list
# or
Tux list
```

---

## Building .deb Package for APT

To build a standalone `.deb` package installable directly via `apt`:

```bash
chmod +x build_deb.sh
./build_deb.sh
```

This generates `dist/tux_1.0.0_all.deb`. You or other users can then install Tux using APT:

```bash
sudo apt install ./dist/tux_1.0.0_all.deb
```

APT will automatically verify package dependencies, install `/usr/local/bin/tux`, initialize `/var/lib/tux`, and create the `Tux` alias automatically!

---

## Usage & Commands

| Command | Description |
|---|---|
| `tux list` | List all available packages in the repository catalog |
| `tux info <package>` | Show detailed package version, description, tags, and install status |
| `tux refresh` (or `update`) | Re-sync latest catalog definitions from remote repository |
| `sudo tux install <package>` | Download and install package across system framework |
| `sudo tux remove <package>` | Uninstall and purge package from system database |
| `tux help` | Display available commands |

### Examples
```bash
# View available software
tux list

# Inspect a package
tux info fastfetch

# Install a package
sudo tux install fastfetch

# Remove a package
sudo tux remove fastfetch
```

---

## Repository Schema (`info.json`)

Tux interfaces with repositories through an `info.json` manifest:

```json
{
  "repo_name": "Tux Repository",
  "version": "1.0",
  "packages": {
    "fastfetch": {
      "version": "2.30.1",
      "url_amd64": "https://raw.githubusercontent.com/CrimsonOnGit-hub/tuxrepository/main/fastfetchamd.deb",
      "url_arm64": "https://raw.githubusercontent.com/CrimsonOnGit-hub/tuxrepository/main/fastfetcharm.deb",
      "desc": "System info tool",
      "tags": "Made for WSL"
    }
  }
}
```
