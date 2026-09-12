# GeneralLinux

Linux environment bootstrap and dotfiles configuration.

## Quick Install

Run directly via `curl` (recommended):
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/dlettiere/GeneralLinux/refs/heads/main/setup.sh)
```

Or via `wget`:
```bash
bash <(wget -qO- https://raw.githubusercontent.com/dlettiere/GeneralLinux/refs/heads/main/setup.sh)
```

### Unattended / Auto-Yes Mode
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/dlettiere/GeneralLinux/refs/heads/main/setup.sh) -y
```

## Utilities

### Mount Device by UUID (`mount_by_uuid.sh`)

Safely mounts a block device to a mount point using `/etc/fstab` and its UUID:

```bash
sudo ./mount_by_uuid.sh <device> <mount_point> [mount_options]
```

**Example:**
```bash
sudo ./mount_by_uuid.sh /dev/sda1 /mnt/data "defaults,nofail"
```

- Auto-detects device UUID and filesystem type.
- Creates a timestamped backup of `/etc/fstab` before modifying.
- Automatically validates with `mount -a` and restores backup on failure.

### Quick Git Push Helper (`push.sh`)

One-command helper to stage, commit, and push changes to the remote repository. It automatically shows current `git status`, prompts only for a commit message, and pushes without requiring manual commands:

```bash
./push.sh
```

Or pass a commit message directly:
```bash
./push.sh "Commit message"
```

- Automatically finds the repository root and active branch.
- Checks if working tree is clean before prompting.
- Sets upstream tracking branch automatically if not yet configured.

