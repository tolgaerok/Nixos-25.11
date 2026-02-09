{ config, pkgs, lib, ... }:

let username = "tolga";
in with lib; {

  # ── Install necessary packages
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    docker-client
    fuse-overlayfs
    kvmtool
    lazydocker
    libvirt
    qemu
    qemu-user
    qemu-utils
    qemu_full
    qemu_kvm
    qtemu
    spice
    spice-gtk
    spice-protocol
    spice-vdagent
    swtpm
    uefi-run
    virglrenderer
    virt-viewer
    virtio-win
    win-spice
  ];

  # ── Virt-manager (NixOS module handles dconf/GSettings)
  programs.virt-manager.enable = true;

  # ── Virtualisation services
  virtualisation = {

    # ── Libvirt / KVM / QEMU
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;
      };
    };

    spiceUSBRedirection.enable = true;

    # ── Docker (disable podman when docker is active)
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
    podman.enable = false;

    # ── VirtualBox (disabled)
    virtualbox = {
      host.enable = false;
      host.enableExtensionPack = false;
      guest.enable = false;
      guest.dragAndDrop = false;
    };

    # ── VM variant settings
    vmVariant = {
      virtualisation = {
        cores = 10;
        memorySize = 12000;
      };
    };
  };

  # ── User groups
  users.extraGroups.vboxusers.members = [ "${username}" ];
  users.users.${username}.extraGroups = [ "libvirt" "kvm" "docker" ];

  # ── Environment / services
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";
  services.spice-vdagentd.enable = true;
  systemd.services.libvirtd.restartIfChanged = false;
}
