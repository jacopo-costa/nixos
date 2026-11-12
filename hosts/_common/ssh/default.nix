# SSH on every host, hardened. Its host key (/etc/ssh/ssh_host_ed25519_key) is also the host's sops key.
#
# The port is closed by default. Reach a host only from the LAN or a VPN, never from the internet:
#   - server behind the router (port 22 not forwarded): services.openssh.openFirewall = true;
#   - laptop: keep it closed, or open it only on the VPN interface:
#       networking.firewall.interfaces.<vpn>.allowedTCPPorts = [22];
{lib, ...}: {
  services.openssh = {
    enable = true;
    ports = [22];
    openFirewall = lib.mkDefault false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = ["jacopo"];
      PermitRootLogin = "no";
    };
  };
}
