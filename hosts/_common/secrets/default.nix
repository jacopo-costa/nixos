{
  # Sops secrets
  sops = {
    # Where the generated secrets with sops <filename> is
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    # Where the private key is
    age.keyFile = "/etc/sops/age/keys.txt";
    age.generateKey = false;
  };
}
