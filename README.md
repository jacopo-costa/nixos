# My Costa Flake - NixOS Configuration

This is a NixOS flake configuration designed for a Linux system with a focus on experimentation and flexibility. It utilizes a modular approach to configuration, promoting maintainability and easy customization.

## Overview

This flake leverages NixOS's powerful features to manage system configuration in a declarative way. It includes configurations for:

*   **Base System:** Includes a stable Nixpkgs release.
*   **Home Manager:**  Used for managing user environments and packages.
*   **Modular Configuration:** Configured using modules for clarity and organization.
*   **Cooler & Freezer:**  Distinct configurations for development and production environments.

## Key Features

*   **Modular Design:** Separated configurations into modules (e.g., `bluetooth`, `network`, `desktop`).
*   **Home Manager Integration:**  Provides a robust environment for user accounts, packages, and configuration.
*   **Distinct Environments:**  Configurations for "Cooler" (development) and "Freezer" (production).
*   **Declarative Configuration:**  Ensures consistent and reproducible system states.
*   **Automatic Updates:** Leveraging Nixpkgs for easy updates.

## Dependencies

*   **NixOS:**  Requires a working NixOS installation.
*   **Nixpkgs:**  The flake depends on a specific Nixpkgs release (nixos-25.05).
*   **Home Manager:**  Installed and configured to work with the flake.
*   **Alejandra:**  The flake uses Alejandra for system formatting.

## Configuration Structure

```
/nixos/
├── flake.nix          # Main flake configuration
├── hosts/
│   ├── cooler/         # Development configuration
│   │   ├── hardware-configuration.nix
│   │   ├── default.nix
│   │   └── ...
│   └── freezer/        # Production configuration
│       ├── default.nix
│       └── ...
├── modules/
│   ├── desktop/
│   │   ├── default.nix
│   │   └── ...
│   ├── bluetooth.nix
│   ├── boot.nix
│   ├── network.nix
│   ├── packages.nix
│   ├── programs.nix
│   ├── services.nix
│   └── sound.nix
└── users/
    ├── jacopo/
    │   └── home.nix
```

## Applying the Configuration

Here's how to apply this NixOS flake to your system:

1.  **Ensure NixOS is Installed:** Verify that you have a functioning NixOS installation.

2.  **Clone the Repository:** Clone the repository containing the `flake.nix` file to your system.
    ```bash
    git clone <repository_url> /nixos
    cd /nixos
    ```

3.  **Apply the Configuration:** Use `nixos-rebuild` to rebuild your system with the flake configuration:

    ```bash
    nixos-rebuild switch --flake "<flake_name>"
    ```
    Replace `<flake_name>` with the actual name of the flake.  This can be found in the `flake.nix` file (e.g., `https://nixos.nixos.org/channels/costa-flake/nixos-25.05`).  For example:
    ```bash
    nixos-rebuild switch --flake "https://nixos.nixos.org/channels/costa-flake/nixos-25.05"
    ```

4.  **Reboot (if necessary):**  After the rebuild completes, you might need to reboot your system for the changes to fully take effect.

5. **Verify:**  After rebooting, check that the new configuration is applied correctly. You can check the system's hostname, network settings, and installed packages.

## Customization

*   **User Accounts:**  The `jacopo` user is pre-configured. You can adapt the `users/jacopo/home.nix` file to manage additional users.
*   **Modules:**  Extend the existing modules or create new ones to tailor the configuration to your specific needs.
*   **Environment Variables:** Configure environment variables in the `modules/desktop/default.nix` file.

## Further Exploration

*   **NixOS Documentation:** [https://nixos.org/](https://nixos.org/) - The official NixOS documentation is an invaluable resource.
*   **Nixpkgs:** [https://github.com/NixOS/nixpkgs](https://github.com/NixOS/nixpkgs) - Explore the Nixpkgs repository to discover available packages and configurations.
*   **Home Manager Documentation:** [https://nix-community.github.io/home-manager/](https://nix-community.github.io/home-manager/) -  Learn about Home Manager's features and capabilities.
*   **Alejandra Documentation:** [https://alejandra.rs/docs/](https://alejandra.rs/docs/) - Learn how to use Alejandra for system formatting.

## Notes

*   This is a basic configuration, and you'll likely want to adapt it to your specific hardware and software requirements.
*   Always test changes in a non-production environment before deploying them to a critical system.
