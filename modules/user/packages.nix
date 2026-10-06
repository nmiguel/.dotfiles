# User package sets.
#
# Home-manager module: declares `userSettings.packages.{cli,gui}.enable`.
#   - `cli` is the portable terminal toolchain shared by Linux and macOS.
#   - `gui` layers on the graphical desktop apps — browsers, editors, Wayland
#     utilities, and hardware tools.
# Splitting them lets a headless or foreign-distro host take just the CLI set
# while a full desktop (tower) enables both.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.userSettings.packages;
  # The pinned OpenCode 1 release needs Quota 4; Quota 5 requires OpenCode 2.
  quotaPlugin = "@slkiser/opencode-quota@4.10.7";
  jsonFormat = pkgs.formats.json { };
in
{
  options.userSettings.packages = {
    cli.enable = lib.mkEnableOption "the portable command-line package set";
    gui.enable = lib.mkEnableOption "the graphical desktop package set";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.cli.enable {
      assertions = [
        {
          assertion =
            !(lib.any (
              file:
              file.target == lib.removePrefix "${config.home.homeDirectory}/" "${config.xdg.configHome}/opencode"
            ) (lib.attrValues config.home.file));
          message = "OpenCode needs a writable config directory. Manage its individual config files with programs.opencode; do not symlink .config/opencode as a whole directory.";
        }
      ];

      # Only these config files belong to Home Manager. OpenCode owns the
      # writable parent directory, node_modules, package.json, and lockfiles.
      programs.opencode = {
        enable = true;
        settings.plugin = [ quotaPlugin ];
        tui.plugin = [ quotaPlugin ];
      };

      xdg.configFile."opencode/opencode-quota/quota-toast.json".source =
        jsonFormat.generate "quota-toast.json"
          {
            enabledProviders = "auto";
            formatStyle = "allWindows";
            tuiSidebarPanel.enabled = true;
            enableToast = false;
            tuiCompactStatus.enabled = false;
          };

      home.packages =
        with pkgs;
        [
          bat
          ncdu
          borgmatic
          btop
          curl
          dnsutils # `dig` + `nslookup`
          eza
          fastfetch
          fd
          file
          fzf # A command-line fuzzy finder
          stdenv.cc
          gh
          gnutar
          iftop # network monitoring
          jq
          lazydocker
          lazygit
          lsof
          neovim
          nix-index
          nix-search-cli
          ripgrep
          nixd
          tokei
          tree
          silicon
          tree-sitter
          unzip
          wget
          which
          xz
          zip
          zstd
          yazi
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          ethtool
          pciutils
          usbutils # lsusb
        ];
    })

    (lib.mkIf cfg.gui.enable {
      home.packages = with pkgs; [
        blueman
        bluetui
        brightnessctl
        cliphist
        libreoffice
        chromium
        evince
        firefox
        file-roller
        gimp
        gnome-calendar
        gnome-disk-utility
        gnome-keyring
        gnome-system-monitor
        gnome-themes-extra
        google-chrome
        grim
        imv
        localsend
        logiops
        mousepad
        mpv
        nwg-displays
        nwg-look
        obs-studio
        openrgb
        papirus-icon-theme
        playerctl
        qalculate-gtk
        satty
        slurp
        wev
        wl-clipboard
        wtype
        pear-desktop # youtube-music
      ];
    })
  ];
}
