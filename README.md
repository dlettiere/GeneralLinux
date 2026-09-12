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

### Resize Swap & Swappiness (`resize_swap.sh`)

Safely resizes or creates a swapfile and configures `vm.swappiness`:

```bash
sudo ./resize_swap.sh
```

- **Safety pre-checks**: verifies available RAM against currently used swap to prevent Out-Of-Memory (OOM) kills during `swapoff`.
- **Disk space validation**: verifies target filesystem space before allocating.
- **Interactive prompts**: includes sensible defaults (`8G` swap, `20` swappiness).
- **Safe allocation**: uses `fallocate` with automatic `dd` fallback, applies secure permissions (`chmod 600`), and formats with `mkswap`.
- **Reboot persistence**: ensures persistence in `/etc/fstab` and `/etc/sysctl.d/99-swappiness.conf`.

