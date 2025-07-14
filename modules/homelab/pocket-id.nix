{config, ...}:
{

  sops = {
    # Pocket-ID encryption key
    secrets."pocketIdEnc" = {};
  };

  services.pocket-id = {
    enable = true;
    settings = {
        APP_URL = "https://pocketid.dimoracosta.it";
        TRUST_PROXY = true;
        ENCRYPTION_KEY_FILE = "${config.sops.secrets."pocketIdEnc".path}";
    };
  };
}