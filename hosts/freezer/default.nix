{
  config,
  pkgs,
  ...
}: let
  newt = pkgs.stdenv.mkDerivation {
    pname = "newt";
    version = "1.2.1";

    src = pkgs.fetchurl {
      url = "https://github.com/fosrl/newt/releases/download/1.2.1/newt_linux_amd64";
      sha256 = "sha256-d40Fi3IC1MkVKG1EmsBt55AklP8s5nm3aoroVk9zYi4=";
    };

    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/newt
      chmod +x $out/bin/newt
    '';
  };
in {
  imports = [
    ./hardware-configuration.nix

    ../../modules/homelab
    ../../modules/locale.nix

    # Users
    ../../users/ice
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/etc/sops/age/keys.txt"

    secrets."newtId" = {};
    secrets."newtSecret" = {};
  };

  # Networking
  networking = {
    useNetworkd = true;
    networkmanager.enable = false;

    firewall.enable = true;

    # Disable DHCP on individual interfaces
    interfaces.enp3s0.useDHCP = false;
    interfaces.enp4s0.useDHCP = false;

    bonds.bond0 = {
      interfaces = ["enp3s0" "enp4s0"];
      driverOptions = {
        miimon = "100";
        mode = "active-backup";
        primary = "enp3s0";
      };
    };

    # Use DHCP
    interfaces.bond0.useDHCP = true;

    hostName = "freezer";
  };

  systemd.services.newt-client = {
    description = "Newt client for Pangolin";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.runtimeShell} -c '${newt}/bin/newt \
          --id "$(cat /run/secrets/newtId)" \
          --secret "$(cat /run/secrets/newtSecret)" \
          --endpoint https://pangolin.dimoracosta.it"'
      '';
      Restart = "on-failure";
    };
  };
}