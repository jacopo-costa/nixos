{ pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ice = {
    isNormalUser = true;
    description = "ice";
    extraGroups = [
      "wheel"
    ];
  };
}
