{ config, lib, pkgs, ... }: {
  # Memory optimization
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
}

# Note:
# Should show zram devices
# zramctl && cat /sys/module/zswap/parameters/enabled 2>/dev/null || echo "zswap not loaded ✓"

# Should show NO or N
# cat /sys/module/zswap/parameters/enabled 2>/dev/null || echo "zswap not loaded ✓"
