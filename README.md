# Remote Support Installer

![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20macOS%20%7C%20Linux-blue)
![Apps](https://img.shields.io/badge/Apps-AnyDesk%20%7C%20RustDesk-green)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

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
| **Linux** | ✅ | ✅ |

## Installation Instructions

### For Windows
1. **Run as Administrator**:
   - Right-click PowerShell and select "Run as Administrator"
   
2. **Execute this command**:
```powershell
irm https://raw.githubusercontent.com/[yourname]/[repo]/main/RemoteInstaller-Windows.ps1 | iex
