{ config, lib, pkgs, ... }:

{
  # ─────────────────────────────────────────────────────────
  # 🌐 Fully Automated Samba Config
  # Tolga Erok     
  # 28/7/2025
  # ─────────────────────────────────────────────────────────

  environment.systemPackages = with pkgs; [
    # Network & File Systems
    cifs-utils
    cups
    firewalld-gui
    nfs-utils
    nvme-cli

  ];

  users.groups.usershares = { };

  # ─────────────────────────────────────────────────────────
  # Samba Service Configuration
  # ─────────────────────────────────────────────────────────
  services.samba = {
    enable = true;
    package = pkgs.samba4Full;
    openFirewall = true;
    usershares.enable = true;

    settings = {
      global = {
        # ─────────────────────────────────────────────────────────
        # COMMON MANDATORY VARIBLES
        # ─────────────────────────────────────────────────────────
        "workgroup" = "WORKGROUP";
        "netbios name" = config.networking.hostName;
        "dns proxy" = "no";
        "name resolve order" = "lmhosts wins bcast host";
        "server role" = "standalone";
        "server string" = "Samba server (version: %v, protocol: %R)";
        "wins support" = "yes";

        "usershare path" = "/var/lib/samba/usershares";
        "usershare max shares" = "100";
        "usershare allow guests" = "yes";
        "usershare owner only" = "no";

        # ─────────────────────────────────────────────────────────
        # Logging
        # ─────────────────────────────────────────────────────────
        "ea support" = "yes";
        "log file" = "/var/log/samba/log.%m";
        "log level" = "1 auth:3 smb:3 smb2:3";
        "max log size" = "500";

        # ─────────────────────────────────────────────────────────
        # 🔥 TWEAKS AND MODS
        # ─────────────────────────────────────────────────────────
        "aio read size" = "16384";
        "aio write size" = "16384";
        "bind interfaces only" = "true";
        "deadtime" = "30";
        "guest account" = "nobody";
        "hosts allow" =
          "127.0.0.1 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 169.254.0.0/16 ::1 fd00::/8 fe80::/10";
        "inherit permissions" = "yes";
        "kernel oplocks" = "yes";
        "large readwrite" = "yes";
        "level2 oplocks" = "yes";
        "map to guest" = "bad user";
        "max xmit" = "65535";
        "min receivefile size" = "16384";
        "oplocks" = "yes";
        "pam password change" = "yes";
        "passdb backend" = "tdbsam";
        "read raw" = "yes";
        "security" = "user";
        "socket options" =
          "SO_KEEPALIVE SO_REUSEADDR SO_BROADCAST TCP_NODELAY IPTOS_LOWDELAY IPTOS_THROUGHPUT SO_SNDBUF=262144 SO_RCVBUF=131072";
        "use sendfile" = "yes";
        "write raw" = "yes";

        # ─────────────────────────────────────────────────────────
        # Protocol Settings
        # ─────────────────────────────────────────────────────────
        "client ipc max protocol" = "SMB3";
        "client ipc min protocol" = "COREPLUS";
        "client max protocol" = "SMB3";
        "client min protocol" = "COREPLUS";
        "server max protocol" = "SMB3";
        "server min protocol" = "COREPLUS";

        # ─────────────────────────────────────────────────────────
        # PRINTER RELATED
        # ─────────────────────────────────────────────────────────
        "cups options" = "raw";
        "disable spoolss" = "yes";
        "load printers" = "yes";
        "printcap name" = "cups";

        # ─────────────────────────────────────────────────────────
        # IOS AND APPLE CONFIG
        # ─────────────────────────────────────────────────────────
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:metadata" = "stream";
        "fruit:model" = "Macmini";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:zero_file_id" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };

      # ─────────────────────────────────────────────────────────
      # Samba Shares Configuration - Automated for all users
      # ─────────────────────────────────────────────────────────
      "homes" = {
        "comment" = "Home Directories";
        "valid users" = "%S, @users";
        "browseable" = "yes";
        "read only" = "no";
        "inherit acls" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force group" = "users";
      };

      "Public" = {
        "comment" = "Public Share - %U";
        "path" = "/home/%U/Public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "%U";
        "force group" = "users";
        "valid users" = "%U, @users";
      };

      "Mega" = {
        "comment" = "MEGA Share - %U";
        "path" = "/home/%U/Documents/MEGA";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "%U";
        "force group" = "users";
        "valid users" = "%U, @users";
      };
    };
  };

  # ─────────────────────────────────────────────────────────
  # Samba Related Services
  # Setup: sudo smbpasswd -a <username>
  # Verify: getent group users
  # ─────────────────────────────────────────────────────────
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # ─────────────────────────────────────────────────────────
  # Auto-create directories for all users
  # ─────────────────────────────────────────────────────────
  systemd.tmpfiles.rules = [ "d /var/spool/samba 1777 root root - -" ];

  # Auto-create user directories on rebuild
  system.activationScripts.sambaUserDirs = lib.mkAfter ''
    for user_home in /home/*; do
      if [ -d "$user_home" ]; then
        user=$(basename "$user_home")
        mkdir -p "$user_home/Public"
        mkdir -p "$user_home/Documents/MEGA"
        chown -R "$user:users" "$user_home/Public" "$user_home/Documents/MEGA"
        chmod 0755 "$user_home/Public" "$user_home/Documents/MEGA"
      fi
    done
  '';
}
