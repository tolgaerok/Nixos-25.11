{ config, pkgs, ... }: {

  # ── Enable the KDE PIM module  ─────────── 
  programs.kde-pim.enable = true;

  environment.systemPackages = with pkgs; [

    # ── Akondadi, korganiser && pkgs, what a mess  ─────────── 
    kdePackages.akonadi
    kdePackages.akonadi-calendar
    kdePackages.akonadi-calendar-tools
    kdePackages.akonadi-contacts
    kdePackages.akonadi-import-wizard
    kdePackages.akonadi-search
    kdePackages.calendarsupport
    kdePackages.kaccounts-integration
    kdePackages.kaccounts-providers
    kdePackages.kaddressbook
    kdePackages.kdepim-addons
    kdePackages.kdepim-runtime
    kdePackages.kmail
    kdePackages.kmail-account-wizard
    kdePackages.kontact
    kdePackages.korganizer
  ];
}
