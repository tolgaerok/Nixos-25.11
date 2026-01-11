{ config, lib, pkgs, ... }: {
  # User account
  users.users.tolga = {
    isNormalUser = true;
    description = "tolga erok";
    extraGroups = [

      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ kdePackages.kate ];
  };
  users.defaultUserShell = pkgs.bash;
}
