{ config, lib, pkgs, ... }:
let
  name = "tolga";
  email = "kingtolga@gmail.com";
in {
  users = {
    users.${name} = {
      createHome = true;
      description = "KingTolga";
      home = "/home/${name}";
      homeMode = "0755";
      isNormalUser = true;
      uid = 1000;

      extraGroups = [
        "wheel" # sudo access
        "networkmanager" # network control
        "docker" # Docker access
        "libvirtd" # VMs
        "audio" # audio devices
        "video" # video devices
        "input" # input devices
        "scanner" # scanners
        "lp" # printers
        "samba" # Samba shares
        "storage" # storage management
        "disk" # disk access
        "systemd-journal" # view logs
      ];

      packages = with pkgs; [ kdePackages.kate home-manager ];

      hashedPassword =
        "$6$RkM04ju2XIwmd0Mz$/R4JlSLKNWPUeiIzd/.OXY805JvY35Oh4t/NIObZUFGts8xPmCwhYgWzfWNB6hVSOelFZwOs.MIRsrbdwOn.I0";

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGaXQOMwKzMvs8Ex5qNniomFX60Zu7U2YcA0B0LO4HLm ${email}"
      ];
    };

    defaultUserShell = pkgs.bash;
  };

  system.activationScripts = {
    setupSSHKeys = {
      text = ''
        ssh_dir="/home/${name}/.ssh"

        # Create SSH directory
        if [ ! -d "$ssh_dir" ]; then
          mkdir -p "$ssh_dir"
          chown ${name}:users "$ssh_dir"
          chmod 700 "$ssh_dir"
        fi

        # Generate ed25519 key
        if [ ! -f "$ssh_dir/id_ed25519" ]; then
          ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "${email}" -f "$ssh_dir/id_ed25519" -N ""
          chown ${name}:users "$ssh_dir/id_ed25519" "$ssh_dir/id_ed25519.pub"
          chmod 600 "$ssh_dir/id_ed25519"
          chmod 644 "$ssh_dir/id_ed25519.pub"
        fi

        # Generate RSA key (backup)
        if [ ! -f "$ssh_dir/id_rsa" ]; then
          ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -C "${email}" -f "$ssh_dir/id_rsa" -N ""
          chown ${name}:users "$ssh_dir/id_rsa" "$ssh_dir/id_rsa.pub"
          chmod 600 "$ssh_dir/id_rsa"
          chmod 644 "$ssh_dir/id_rsa.pub"
        fi
      '';
    };

    thank-you.text = ''
      cat << EOF > /home/${name}/THANK-YOU
      Tolga Erok - NixOS Configuration
      11 Jan 2026

      Thank you for using my personal NixOS configuration.
      If you encounter issues: ${email}

      Last rebuilt: $(date '+%a %b %d %l:%M %p')
      EOF
      chown ${name}:users /home/${name}/THANK-YOU
    '';

    nixos-ownership = ''
      # Set ownership of /etc/nixos to current user
      ${pkgs.coreutils}/bin/chown -R ${name}:users /etc/nixos
      ${pkgs.coreutils}/bin/chmod -R 755 /etc/nixos
      ${pkgs.findutils}/bin/find /etc/nixos -type f -name "*.nix" -exec ${pkgs.coreutils}/bin/chmod 644 {} \;

      # Create ownership confirmation file
      cat << EOF > /home/${name}/NIXOS-OWNERSHIP
      ╔════════════════════════════════════════════════════════╗
      ║        NixOS Configuration - Ownership Granted         ║
      ╚════════════════════════════════════════════════════════╝

      ✓ User: ${name}
      ✓ Path: /etc/nixos
      ✓ Permissions: rwxr-xr-x (755)
      ✓ File Mode: rw-r--r-- (644)

      You can now edit NixOS configs without sudo!

      ───────────────────────────────────────────────────────
      System rebuilt: $(date '+%a %b %d, %Y at %l:%M %p')
      Configuration by: Tolga Erok
      Contact: ${email}
      ───────────────────────────────────────────────────────
      EOF

      ${pkgs.coreutils}/bin/chown ${name}:users /home/${name}/NIXOS-OWNERSHIP
      ${pkgs.coreutils}/bin/chmod 644 /home/${name}/NIXOS-OWNERSHIP
    '';
  };
}
