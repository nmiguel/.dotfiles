{
  inputs,
  config,
  pkgs,
  ...
}:

{
  systemSettings = {
    noctalia.enable = true;
    steam.enable = true;
    hyprland.enable = true;
    hyprland.monitorsFile = ./monitors.lua;
    sddm.enable = true;
    # plymouth.enable = true;
    audio.enable = true;
    fish.enable = true;
    logitech.enable = true;
  };

  # Bootloader.
  boot = {
    loader = {
      timeout = 3;
      efi.efiSysMountPoint = "/boot";
      efi.canTouchEfiVariables = true;

      limine = {
        enable = true;

        maxGenerations = 5;

        panicOnChecksumMismatch = false; # your hash_mismatch_panic: no

        style = {
          backdrop = "1a1b26";
          wallpapers = [ ];

          interface = {
            branding = "Tower";
            # brandingColor = "2"; # your interface_branding_color: 2
          };

          graphicalTerminal = {
            background = "1a1b26";
            brightBackground = "24283b";
            foreground = "c0caf5";
            brightForeground = "c0caf5";

            # Palette is semicolon-separated, same format as your existing config
            palette = "15161e;f7768e;9ece6a;e0af68;7aa2f7;bb9af7;7dcfff;a9b1d6";
            brightPalette = "414868;f7768e;9ece6a;e0af68;7aa2f7;bb9af7;7dcfff;c0caf5";
          };
        };

        # Extra static entries — Arch and Windows
        # NixOS generations are added automatically by the module
        extraEntries = ''
          /+Arch
            comment: Arch
            comment: order-priority=20
            protocol: linux
            path: boot():/vmlinuz-linux
            module_path: boot():/initramfs-linux.img
            cmdline: root=UUID=9bf0c545-31a4-4d51-a50d-8541d8dbbf66 rw quiet loglevel=3

          /Windows
            comment: Windows Boot Manager
            comment: order-priority=20
            protocol: efi_chainload
            image_path: guid(03a6aa5d-56b4-4a71-b96d-4a09175ca1ac):/EFI/Microsoft/Boot/bootmgfw.efi

          /EFI fallback
            comment: Default EFI loader
            comment: order-priority=10
            protocol: efi_chainload
            image_path: boot():/EFI/BOOT/BOOTX64.EFI
        '';
      };
    };
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "tower"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."nomig" = {
    isNormalUser = true;
    description = "Nuno Ramos";
    extraGroups = [
      "networkmanager"
      "wheel"
      "greeter"
    ];
    uid = 1000;
    packages = with pkgs; [
    ];
  };

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.systemPackages = with pkgs; [
    vim
    kitty
    wget
    neovim
    git
  ];

  system.stateVersion = "25.11"; # Did you read the comment?

}
