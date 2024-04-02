{pkgs, ...}: {
  systemd.services = {
    "serial-getty@ttyS0".enable = false;
    "serial-getty@hvc0".enable = false;
    "getty@tty1".enable = false;
    "autovt@".enable = false;
    systemd-resolved.enable = false;
    systemd-udevd.enable = false;
    firewall.enable = false;
    nix-daemon.environment = {
      https_proxy = "socks5h://localhost:7890";
      http_proxy = "socks5h://localhost:7890";
    };
    network-mirrored = {
      description = "network-mirrored";
      enable = true;
      wants = ["network-pre.target"];
      wantedBy = ["multi-user.target"];
      before = ["network-pre.target" "shutdown.target"];
      serviceConfig = {
        User = "root";
        ExecStart = [
          ''
            /bin/sh -ec '\
            [ -x bin/wslinfo ] && [ "$(bin/wslinfo --networking-mode)" = "mirrored" ] || exit 0;\
            POSTROUTING=$(${pkgs.nftables}/bin/nft list chain ip nat WSLPOSTROUTING | sed -En "s/^.*(oif .* sport 1-65535 .* counter).*(masquerade to :[0-9-]+).*$/add rule ip6 nat WSLPOSTROUTING \\1 \\2 comment mirrored;/p");\
              echo "\
              add chain   ip nat WSLPREROUTING { type nat hook prerouting priority dstnat - 1; policy accept; };\
              insert rule ip nat WSLPREROUTING iif loopback0  ip daddr 127.0.0.1 counter dnat to 127.0.0.1 comment mirrored;\
              add table ip6 filter;\
              add chain ip6 filter WSLOUTPUT {type filter hook output priority filter; policy accept;};\
              add rule  ip6 filter WSLOUTPUT counter meta mark set 0x00000001 comment mirrored;\
              add table ip6 nat;\
              add chain ip6 nat WSLPOSTROUTING {type nat hook postrouting priority srcnat - 1; policy accept;};\
              $POSTROUTING"|${pkgs.nftables}/bin/nft -f -\
              '
          ''
        ];

        ExecStop = [
          ''
            /bin/sh -ec '\
            [ -x /usr/bin/wslinfo ] && [ "$(/usr/bin/wslinfo --networking-mode)" = "mirrored" ] || exit 0;\
            for chain in "ip nat WSLPREROUTING" "ip6 filter WSLOUTPUT" "ip6 nat WSLPOSTROUTING";\
              do\
                handle=$(${pkgs.nftables}/bin/nft -a list chain $chain | sed -En "s/^.*comment \\"mirrored\\" # handle ([0-9]+)$/\\1/p");\
                  for n in $handle; do echo "delete rule $chain handle $n"; done;\
                    done|${pkgs.nftables}/bin/nft -f -\
                      '
          ''
        ];
        RemainAfterExit = "yes";
      };
    };
  };
}