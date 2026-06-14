# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot = {
    plymouth = {
      enable = true;
      theme = "lone";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "lone" ];
        })
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];

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
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # i18n.extraLocaleSettings = {
  #     LC_IDENTIFICATION = "en_US.UTF-8";
  #     LC_MEASUREMENT = "en_US.UTF-8";
  #     LC_MONETARY = "en_US.UTF-8";
  #     LC_NAME = "en_US.UTF-8";
  #     LC_NUMERIC = "en_US.UTF-8";
  #     LC_PAPER = "en_US.UTF-8";
  #     LC_TELEPHONE = "en_US.UTF-8";
  #     LC_TIME = "en_US.UTF-8";
  # };

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  services.xserver.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      # xdg-desktop-portal-gnome
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

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

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;

    autoNumlock = true;

    extraPackages = with pkgs; [
      sddm-astronaut
    ];

    theme = "sddm-astronaut-theme";
    settings = {
      Theme = {
        Current = "sddm-astronaut-theme";
      };
    };
  };

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remoteplay
      dedicatedServer.openFirewall = true; # Open ports in the firewall for steam server
    };
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
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
    hyprland
    hyprland-qtutils
    (sddm-astronaut.override {
      embeddedTheme = "pixel_sakura";
    })
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
