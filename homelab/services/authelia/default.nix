{
  config,
  lib,
  ...
}: let
  service = "authelia";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "Enable Authelia";
    instanceName = lib.mkOption {
      type = lib.types.str;
      default = "dimoracosta";
      description = "Name of this instance of Authelia";
    };
    storageEncryptionKeyPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the storage encryption key file";
    };
    jwtSecretPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the JWT secret file";
    };
    smtpPasswordPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the SMTP password file";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "auth.${homelab.baseDomain}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.authelia.instances.${cfg.instanceName} = {
      enable = true;
      secrets = {
        storageEncryptionKeyFile = cfg.storageEncryptionKeyPath;
        jwtSecretFile = cfg.jwtSecretPath;
      };
      environmentVariables = {
        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = cfg.smtpPasswordPath;
      };
      settings = {
        theme = "auto";

        authentication_backend.file.path = "/etc/authelia/users_database.yml";
        access_control = {
          default_policy = "deny";
          rules = [
            {
              domain = "*.${homelab.baseDomain}";
              policy = "one_factor";
            }
          ];
        };

        storage.postgres = {
          address = "unix:///run/postgresql";
          database = "authelia-${cfg.instanceName}";
          username = "authelia-${cfg.instanceName}";
        };

        session = {
          redis.host = "/var/run/redis-${cfg.instanceName}/redis.sock";
          cookies = [
            {
              domain = homelab.baseDomain;
              authelia_url = "https://${cfg.url}";
              # The period of time the user can be inactive for before the session is destroyed
              inactivity = "1M";
              # The period of time before the cookie expires and the session is destroyed
              expiration = "3M";
              # The period of time before the cookie expires and the session is destroyed
              # when the remember me box is checked
              remember_me = "1y";
            }
          ];
        };

        smtp = {
          address = "smtp://${config.email.smtpServer}:${toString config.email.smtpPort}";
          username = config.email.smtpUsername;
        };
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = ["authelia-${cfg.instanceName}"];
      ensureUsers = [
        {
          name = "authelia-${cfg.instanceName}";
          ensureDBOwnership = true;
        }
      ];
    };

    systemd.services."authelia-${cfg.instanceName}" = let
      dependencies = [
        "postgresql.service"
        "redis-${cfg.instanceName}.service"
      ];
    in {
      # Authelia requires PostgreSQL and Redis to be running
      after = dependencies;
      requires = dependencies;
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:9091
      '';
    };
    services.caddy.extraConfig = ''
      (auth) {
            forward_auth :9091 {
                uri /api/authz/forward-auth
                copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
            }
        }
    '';
  };
}
