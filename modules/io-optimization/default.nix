# ───────────────────────────────────────────────────────────────────────────────────────────────────────────
# module:  io-optimization.nix
# author:  kingtolga
# date:    8 feb 26
# version: 1.0
# description: nixos module for i/o + cpu scheduler optimization
#              replaces imperative udev/sysctl/systemd from my fedora bash script
# ───────────────────────────────────────────────────────────────────────────────────────────────────────────

{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.tweaks.io-optimization;

  # ── resolve scx package — nixpkgs has scx.rusty, scx.lavd, scx.bpfland, etc. available on their pkg website ─────────────── 
  # ── use scx.full as fallback if individual scheduler not packaged separately as i found out the fucked up hard way ──────── 
  scxPkg = pkgs.scx.${cfg.scx.scheduler} or pkgs.scx.full;

  # ── my personal diagnostic script ─────────────────────────────────────────────────────────────── 
  # ── oCheckScript = pkgs.writeShellScriptBin "io-check" (builtins.readFile ./io-check.sh); ───────
  ioCheckScript =
    pkgs.writeScriptBin "io-check" (builtins.readFile ./io-check.sh);
in {

  options.tweaks.io-optimization = {

    enable = mkEnableOption "i/o and scheduler optimizations";

    ioScheduler = mkOption {
      type = types.str;
      default = "none";
      description = "io scheduler for ssds and nvme (none recommended)";
    };

    readAheadKB = mkOption {
      type = types.int;
      default = 512;
      description = "read-ahead in KB for ssds and nvme";
    };

    enableBBR = mkOption {
      type = types.bool;
      default = true;
      description = "enable tcp bbr congestion control + fq qdisc";
    };

    scx = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "enable scx cpu scheduler service";
      };

      scheduler = mkOption {
        type = types.enum [
          "rusty"
          "lavd"
          "bpfland"
          "flash"
          "rustland"
          "cosmos"
          "p2dq"
          "beerland"
          "tickless"
        ];
        default = "rusty";
        description = "which scx scheduler to run";
      };
    };

    enableAutogroup = mkOption {
      type = types.bool;
      default = true;
      description = "enable kernel sched_autogroup";
    };
  };

  config = mkIf cfg.enable {

    # ── udev rules ───────────────────────────────────────────────────────────
    services.udev.extraRules = ''
      # kingtolga - io scheduler: ${cfg.ioScheduler} for ssds and nvme
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="${cfg.ioScheduler}"
      ACTION=="add|change", KERNEL=="sd[a-z][a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="${cfg.ioScheduler}"
      ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="${cfg.ioScheduler}"

      # kingtolga - read-ahead ${toString cfg.readAheadKB}KB for ssds and nvme
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{bdi/read_ahead_kb}="${
        toString cfg.readAheadKB
      }"
      ACTION=="add|change", KERNEL=="sd[a-z][a-z]", ATTR{queue/rotational}=="0", ATTR{bdi/read_ahead_kb}="${
        toString cfg.readAheadKB
      }"
      ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{bdi/read_ahead_kb}="${
        toString cfg.readAheadKB
      }"
    '';

    # ── sysctl ─────────────────────────────────────────────────────────────── 
    boot.kernel.sysctl = mkMerge [
      (mkIf cfg.enableBBR {
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "fq";
      })
      (mkIf cfg.enableAutogroup { "kernel.sched_autogroup_enabled" = 1; })
    ];

    # ── bbr module ─────────────────────────────────────────────────────────── 
    boot.kernelModules = mkIf cfg.enableBBR [ "tcp_bbr" ];

    # ── packages (diagnostic script + optional scx) ────────────────────────── 
    environment.systemPackages = [ ioCheckScript ]
      ++ (optionals cfg.scx.enable [ scxPkg ]);

    # ── scx systemd service ────────────────────────────────────────────────── 
    systemd.services."scx-scheduler" = mkIf cfg.scx.enable {
      description = "SCX ${cfg.scx.scheduler} Scheduler";
      after = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${scxPkg}/bin/scx_${cfg.scx.scheduler}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
