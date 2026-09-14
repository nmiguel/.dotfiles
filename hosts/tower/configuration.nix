{
  inputs,
  config,
  pkgs,
  ...
}:
let
  graphicalRuntimeLibraries = with pkgs; [
    libX11
    libXcursor
    libXi
    libXrandr
    libxkbcommon
    vulkan-loader
  ];

  backupArchiveName = "tower-{now:%Y-%m-%dT%H:%M:%S.%f}";
  backupPassphrase = "{credential systemd borgmatic.pw}";
  backupSources = [
    "/home"
  ];
  backupExcludes = [
    "/mnt/data/tower_backup"
    "/mnt/data/$RECYCLE.BIN"
    "/mnt/data/System Volume Information"
    "/mnt/win/$RECYCLE.BIN"
    "/mnt/win/System Volume Information"
    "/mnt/win/hiberfil.sys"
    "/mnt/win/pagefile.sys"
    "/mnt/win/swapfile.sys"
    "/var/cache/pacman/pkg"
    "/var/log/*.log"
    "/var/log/journal/*"
    "/home/*/.cache"
    "/home/*/.local/share/Trash"
    "/home/*/.mozilla/firefox/*/cache2"
    "/home/*/.config/google-chrome/Default/Cache"
    "/home/*/node_modules"
    "/home/*/.npm"
    "/home/*/.cargo/registry"
    "/home/*/.cargo/git"
    "/home/*/target"
    "/home/*/build"
    "/home/*/.gradle"
    "/home/*/.venv"
    "/home/*/venv"
    "/home/*/__pycache__"
    "*.pyc"
    "/home/*/.local/share/Steam/steamapps/common"
    "/home/*/.steam/steam/steamapps/common"
    "/home/*/.local/share/Steam/steamapps/downloading"
    "/home/*/.local/share/Steam/steamapps/temp"
  ];
  backupSettings = {
    source_directories = backupSources;
    source_directories_must_exist = true;
    exclude_patterns = backupExcludes;
    exclude_caches = true;
    exclude_nodump = true;
    one_file_system = true;
    numeric_ids = true;
    atime = false;

    archive_name_format = backupArchiveName;
    match_archives = "sh:tower-*";
    encryption_passphrase = backupPassphrase;
    compression = "lz4";
    checkpoint_interval = 900;
    lock_wait = 300;
    retries = 3;
    retry_wait = 60;
    upload_rate_limit = 51200;
    statistics = true;

    keep_within = "14d";
    keep_weekly = 8;
    keep_monthly = 12;
    keep_yearly = 3;

    checks = [
      {
        name = "repository";
        frequency = "1 month";
        max_duration = 3600;
      }
      {
        name = "archives";
        frequency = "1 month";
      }
      {
        name = "extract";
        frequency = "3 months";
      }
    ];
    check_last = 3;

    borg_base_directory = "/var/lib/borgmatic";
    user_state_directory = "/var/lib/borgmatic";
    bootstrap.store_config_files = true;
  };
in
{
  modules.games.enable = true;

  systemSettings = {
    dms.enable = true;
    fonts.enable = true;
    hyprland.enable = true;
    hyprland.monitorsFile = ./monitors.lua;
    sddm.enable = true;
    boot_options.enable = true;
    audio = {
      enable = true;
      virtualOutputs = {
        headphones = {
          target = "alsa_output.usb-1532_Razer_BlackShark_V2_Pro_2.4_O001000007-00.analog-stereo";
          volume = 30;
          targetVolume = 6;
        };
        speakers = {
          target = "alsa_output.usb-Yamaha_Corporation_Digital_Keyboard-00.analog-stereo";
          volume = 25;
        };
      };
      virtualInputs.microphone = {
        target = "alsa_input.usb-1532_Razer_BlackShark_V2_Pro_2.4_O001000007-00.mono-fallback";
        boost = 1.35;
      };
    };
    fish.enable = true;
    logitech.enable = true;
    onepassword = {
      enable = true;
      polkitPolicyOwners = [ "nomig" ];
      browserExtensions.enable = true;
    };
    openrgb = {
      enable = true;
    };
    jellyfin.enable = false;
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
  networking.hosts."192.168.1.50" = [ "chariot" ];

  # Enable networking
  networking.networkmanager.enable = true;

  programs.ssh.knownHosts.chariot = {
    hostNames = [
      "chariot"
      "192.168.1.50"
    ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAgeYs/SikYgp4lxg08D+ZOmY8+/lmMKw149/T3eQ1xE";
  };

  services.borgmatic = {
    enable = true;
    configurations = {
      local = backupSettings // {
        repositories = [
          {
            path = "/mnt/data/tower_backup";
            label = "local_hdd";
          }
        ];
      };

      chariot = backupSettings // {
        repositories = [
          {
            path = "borg@chariot:.";
            label = "chariot";
          }
        ];
        ssh_command = "${pkgs.openssh}/bin/ssh -i /run/credentials/borgmatic.service/borgmatic.ssh-key -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=/etc/ssh/ssh_known_hosts -o ConnectTimeout=30 -o ServerAliveInterval=60 -o ServerAliveCountMax=3";

        # Remote retention and checks run locally on chariot. The Borg endpoint
        # itself is append-only, so this job cannot prune remote archives.
        skip_actions = [
          "prune"
          "compact"
          "check"
        ];
      };
    };
  };

  systemd.services.borgmatic = {
    unitConfig.RequiresMountsFor = backupSources;
    serviceConfig = {
      LoadCredential = [ "borgmatic.ssh-key:/home/nomig/.ssh/box" ];
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = [ "/mnt/data/tower_backup" ];
      UMask = "0077";

      Nice = 19;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      CPUWeight = 10;
      IOWeight = 10;
    };
  };

  systemd.timers.borgmatic.timerConfig = {
    # Clear borgmatic's packaged daily schedule before adding the weekly one.
    OnCalendar = [
      ""
      "Sun *-*-* 04:00:00"
    ];
    Persistent = true;
    RandomizedDelaySec = "2h";
    AccuracySec = "30m";
  };

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  services.gvfs.enable = true;
  services.tumbler.enable = true;

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

  programs.nix-ld = {
    enable = true;
    libraries = graphicalRuntimeLibraries;
  };

  # Nix-linked development binaries bypass nix-ld, so expose only the
  # graphical additions to their native loader.
  programs.fish.shellInit = ''
    set -gx NIX_LD /run/current-system/sw/share/nix-ld/lib/ld.so
    set -gx NIX_LD_LIBRARY_PATH /run/current-system/sw/share/nix-ld/lib
    set -gx LD_LIBRARY_PATH ${pkgs.lib.makeLibraryPath graphicalRuntimeLibraries}
  '';

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
