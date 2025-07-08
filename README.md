# Remote Support Installer

![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20macOS%20%7C%20Linux-blue)
![Apps](https://img.shields.io/badge/Apps-AnyDesk%20%7C%20RustDesk-green)


A simple cross-platform installer for remote support applications. Quickly install AnyDesk or RustDesk with one command for easy remote PC support and troubleshooting.

## Features

- 🚀 Single-command installation
- ⏱️ Fully automated Windows installation
- 🖥️ Supports Windows, macOS and Linux
- 🔒 Secure downloads from official sources
- 🔄 Always installs latest stable versions
- 🧹 Automatic cleanup after installation

## Supported Platforms & Applications

| Platform | AnyDesk | RustDesk |
|----------|---------|----------|
| **Windows** | ✅ | ✅ |
| **macOS** | ✅ | ✅ |
| **Linux (Debian / Ubuntu)** | ✅ | ✅ |

## Installation Instructions

### For Windows
1. **Run as Administrator**:
   - Right-click PowerShell and select "Run as Administrator"
   
2. **Execute this command**:
```powershell
irm https://raw.githubusercontent.com/[yourname]/[repo]/main/RemoteInstaller-Windows.ps1 | iex
```

### For macOS and Linux
1. **Open Terminal**
2. **Run this command**:
```bash
curl -sL https://raw.githubusercontent.com/[yourname]/[repo]/main/RemoteInstaller-Unix.sh | bash
```
    Follow prompts to select your application and complete installation

Requirements

    Windows:
        PowerShell 5.1+
        Administrator privileges
        .NET Framework 4.5+

    macOS:

        macOS 10.13+

        Terminal access

        May require security exceptions

    Linux:

        Debian/Ubuntu-based distributions

        sudo privileges

        Standard build tools

Security Notes

    🔐 All downloads use HTTPS from official sources

    🔍 Scripts are open-source and can be audited

    🧩 No persistent components installed

    ⚠️ Windows requires admin rights due to system installation

FAQ

Q: Is an internet connection required?
A: Yes, the installer downloads applications from official sources

Q: Can I use this for enterprise deployment?
A: Absolutely! The Windows version supports silent installations

Q: How do I uninstall applications?
A: Use standard system uninstall methods:

    Windows: Control Panel > Programs

    macOS: Drag to Trash

    Linux: sudo apt remove anydesk or sudo apt remove rustdesk

Q: Why does macOS installation show security warnings?
A: macOS requires manual approval for apps from unidentified developers. Go to:
System Preferences > Security & Privacy > General > Click "Open Anyway"

Q: Can I install both applications?
A: Yes, but you need to run the installer twice and select different apps each time
Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss proposed changes.
