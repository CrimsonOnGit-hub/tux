# Tux Universal Package Manager

A fast, lightweight, and colored package manager built for Linux, WSL, and Debian-based systems. **Tux** pulls directly from remote repositories like `tux_repository`, resolves device architecture (x86_64, arm64, i386), downloads payloads, and installs packages seamlessly.

---

## Features

- **Multi-Architecture Resolution**: Automatically maps payloads for AMD64 (`url_amd64`), ARM64 (`url_arm64`), Raspberry Pi, and i386 (`url_i386`).
- **Flexible Package Formats**: Supports `.deb` packages (via `dpkg`), `.tar.gz`/`.pkg`/`.tgz` system tarballs, and executable installation scripts (`.sh`, `.bin`).
- **Rich Terminal Styling**: Color-coded architecture badges, environment tags (WSL, Mac, Raspberry Pi), and package status indicators.
- **Package State Tracking**: Maintains an installed package manifest at `/var/lib/tux/lock.json`.
- **Zero Third-Party Dependencies**: Written entirely in pure Python 3 using standard library modules.

---

## Installation

### Quick Install (curl)
```bash
curl -fsSL https://raw.githubusercontent.com/CrimsonOnGit-hub/tux/main/install.sh | sudo bash
```

### Manual Install
```bash
git clone https://github.com/CrimsonOnGit-hub/tux.git
cd tux
sudo ./install.sh
```

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
      "url_amd64": "https://raw.githubusercontent.com/CrimsonOnGit-hub/tux_repository/main/fastfetchamd.deb",
      "url_arm64": "https://raw.githubusercontent.com/CrimsonOnGit-hub/tux_repository/main/fastfetcharm.deb",
      "desc": "System info tool",
      "tags": "Made for WSL"
    }
  }
}
```
