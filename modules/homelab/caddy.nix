{config, ...}: let
  certloc = "/var/lib/acme/dimoracosta.it";
in {
  networking.firewall.allowedTCPPorts = [80 443];

  sops = {
    # Cloudflare Token
    secrets."cloudflareToken" = {};

    templates.cloudflareEnv = {
      content = ''
        CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.cloudflareToken}
      '';
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "costa.jacopo@gmail.com";

    certs."dimoracosta.it" = {
      group = config.services.caddy.group;

      domain = "dimoracosta.it";
      extraDomainNames = ["*.dimoracosta.it"];
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      environmentFile = config.sops.templates.cloudflareEnv.path;
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts."vault.dimoracosta.it".extraConfig = ''
      reverse_proxy http://127.0.0.1:8222

      tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
      }
    '';
  };
}
