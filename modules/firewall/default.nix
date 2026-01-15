# networking/default.nix
# tolga erok
# 13 jan 26
# network and firewall config

{ config, options, lib, pkgs, ... }: {

  networking = {
    enableIPv6 = true;
    networkmanager.enable = true;
    
    firewall = {
      enable = true;  # enabled with custom rules
      allowPing = true;
      
      # tcp ports
      allowedTCPPorts = [
        # web services
        80      # http
        443     # https
        8010    # gnomecast
        8888    # gnomecast alt
        
        # docker services
        8443    # vscode
        9000    # portainer
        3000    # grafana
        9090    # prometheus
        
        # file sharing
        21      # ftp
        22      # ssh
        139     # samba netbios
        445     # samba smb
        2049    # nfs
        111     # nfs rpcbind
        5357    # wsdd samba discovery
        
        # databases
        3306    # mysql
        3307    # mariadb
        5432    # postgresql
        
        # services
        25      # smtp
        53      # dns
        143     # imap
        389     # ldap
        2375    # docker api
        9091    # transmission web
        60450   # transmission peer
        22000   # syncthing
        
        # remote access
        8200    # teamviewer
        59010   # teamviewer
        59011   # teamviewer
      ];
      
      # tcp port ranges
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }   # kde connect
        { from = 32765; to = 32769; } # nfs high ports
      ];
      
      # udp ports
      allowedUDPPorts = [
        53      # dns
        137     # netbios name
        138     # netbios datagram
        111     # nfs rpcbind
        2049    # nfs
        3702    # wsdd discovery
        5353    # mdns/avahi
        21027   # syncthing discovery
        22000   # syncthing
        8200    # teamviewer
        59010   # teamviewer
        59011   # teamviewer
      ];
      
      # udp port ranges
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; }   # kde connect
        { from = 32765; to = 32769; } # nfs high ports
      ];
      
      # netbios name resolution helper
      extraCommands = ''
        iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns
      '';
    };
  };
}