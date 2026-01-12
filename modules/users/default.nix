# ============================================
# MY USER CONFIG WITH SSH KEY AUTO-GENERATION
# ============================================

{ config, lib, pkgs, username, ... }:

with lib;
let
  username = builtins.getEnv "USER";
  name = "tolga";

in {
  # user account
  users.users.tolga = {
    createHome = true;
    description = "KingTolga";
    home = "/home/tolga/";
    homeMode = "0755";
    isNormalUser = true;
    uid = 1000;

    extraGroups = [
      "adbusers"
      "audio"
      "corectrl"
      "disk"
      "docker"
      "input"
      "libvirtd"
      "lp"
      "minidlna"
      "mongodb"
      "mysql"
      "network"
      "networkmanager"
      "postgres"
      "power"
      "samba"
      "scanner"
      "smb"
      "sound"
      "storage"
      "systemd-journal"
      "udev"
      "users"
      "usershares"
      "video"
      "wheel"
    ];

    packages = with pkgs; [

      kdePackages.kate
      pkgs.home-manager
    ];

    hashedPassword =
      "$6$RkM04ju2XIwmd0Mz$/R4JlSLKNWPUeiIzd/.OXY805JvY35Oh4t/NIObZUFGts8xPmCwhYgWzfWNB6hVSOelFZwOs.MIRsrbdwOn.I0";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGaXQOMwKzMvs8Ex5qNniomFX60Zu7U2YcA0B0LO4HLm kingtolga@gmail.com"
    ];
  };

  users.defaultUserShell = pkgs.bash;

  # auto-generate ssh keys and some autostarters on system activation
  system.activationScripts = {

    setupSSHKeys = {
      text = ''
        ssh_dir="/home/tolga/.ssh"
        email="kingtolga@gmail.com"

        # create ssh directory
        if [ ! -d "$ssh_dir" ]; then
          mkdir -p "$ssh_dir"
          chown tolga:users "$ssh_dir"
          chmod 700 "$ssh_dir"
        fi

        # generate ed25519 key
        if [ ! -f "$ssh_dir/id_ed25519" ]; then
          ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "$email" -f "$ssh_dir/id_ed25519" -N ""
          chown tolga:users "$ssh_dir/id_ed25519" "$ssh_dir/id_ed25519.pub"
          chmod 600 "$ssh_dir/id_ed25519"
          chmod 644 "$ssh_dir/id_ed25519.pub"
        fi

        # generate rsa key
        if [ ! -f "$ssh_dir/id_rsa" ]; then
          ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -C "$email" -f "$ssh_dir/id_rsa" -N ""
          chown tolga:users "$ssh_dir/id_rsa" "$ssh_dir/id_rsa.pub"
          chmod 600 "$ssh_dir/id_rsa"
          chmod 644 "$ssh_dir/id_rsa.pub"
        fi
      '';
      deps = [ ];
    };

    #---------------------------------------------
    # Create Thank-you
    #---------------------------------------------
    thank-you = {
      text = ''
        cat << EOF > /home/${name}/THANK-YOU
        Tolga Erok
        11 Jan 2026

        Thank you for using my personal NixOS configuration.

        I hope you will enjoy my setup as much as I do.

        If you encounter any issues, please contact me via email: kingtolga@gmail.com


        ¯\_(ツ)_/¯  Date and time of system rebuild
        --------------------------------------------
        $(date '+%a - %b %d %l:%M %p')
        EOF
      '';
    };

    #---------------------------------------------
    # Create AutoStart shortcuts
    #---------------------------------------------
    megasync-start = {
      text = ''
        autostart_dir="/home/${name}/.config/autostart"
        desktop_file="$autostart_dir/megasync.desktop"
            
        # create autostart directory if it doesn't exist
        if [ ! -d "$autostart_dir" ]; then
          mkdir -p "$autostart_dir"
          chown ${name}:users "$autostart_dir"
          chmod 755 "$autostart_dir"
        fi

        # create desktop file
        cat << EOF > "$desktop_file"
        [Desktop Entry]
        Type=Application
        Name=MEGAsync
        Exec=megasync
        Icon=mega
        Terminal=false
        X-GNOME-Autostart-enabled=true
        EOF
            
        # set ownership and make executable
        chown ${name}:users "$desktop_file"
        chmod 755 "$desktop_file"
      '';
      deps = [ ];
    };

  };
}
