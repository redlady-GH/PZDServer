# 🧟 Project Zomboid Dedicated Server Scripts (Ubuntu)

Automated setup and management scripts for a high-performance, low-maintenance Project Zomboid (Build 41) Dedicated Server on Ubuntu 24.04 LTS.

## ✨ Features

- **Triple-Layer Data Protection**:
  - **Instant Save**: Saves immediately upon player damage.
  - **Auto-Save**: 30-minute interval world saving.
  - **Hourly Backup**: Full server backup with 7-day retention.
- **Smart Update**: Automatically updates the server at 3 AM only if no players are online.
- **Easy Management**: Simple scripts for announcements, logs, and manual saves.
- **Mod Management**: CSV-based mod list (`mods_list.txt`) with automatic configuration generation.

## 🚀 Quick Start

### 1. Prerequisites
- Ubuntu 24.04 LTS (Recommended)
- Root access (or sudo)

### 2. Setup
1.  Clone this repository:
    ```bash
    git clone https://github.com/yourusername/pz-server-scripts.git z
    cd z
    ```
2.  Set your Admin Password:
    ```bash
    cp scripts/pz_admin_pw.txt.example scripts/pz_admin_pw.txt
    nano scripts/pz_admin_pw.txt
    # Enter your desired admin password
    ```
3.  Configure Server Details:
    Edit `scripts/setup_mods.sh` to set your Server Name, World Name, and Password.
    ```bash
    nano scripts/setup_mods.sh
    ```
4.  Add Mods (Optional):
    Edit `scripts/mods_list.txt` to add your mods (Name, WorkshopID, ModID).

### 3. Install & Run
Run the rebuild script to install dependencies, SteamCMD, Project Zomboid, and start the server.
```bash
sudo bash scripts/rebuild.sh --confirm
```

## 🛠️ Operations

- **Check Status**: `sudo systemctl status pzserver`
- **View Logs**: `bash scripts/logs.sh`
- **Manual Save**: `bash scripts/save.sh`
- **Send Announcement**: `bash scripts/announce.sh "Hello World"`
- **Attach to Console**: `sudo screen -r pzserver`

## 📂 File Structure
- `scripts/`: All management scripts.
- `backups/`: Auto-generated backups.

## 📝 License
MIT License
