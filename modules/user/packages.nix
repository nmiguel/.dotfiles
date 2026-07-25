# User package sets.
#
# Home-manager module: declares `userSettings.packages.{cli,gui}.enable`.
#   - `cli` is the portable terminal toolchain that makes sense on any Linux
#     box (NixOS or not).
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
in
{
  options.userSettings.packages = {
    cli.enable = lib.mkEnableOption "the portable command-line package set";
    gui.enable = lib.mkEnableOption "the graphical desktop package set";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.cli.enable {
      home.packages = with pkgs; [
        opencode

        bat
        ncdu
        borgmatic
        btop
        curl
        dnsutils # `dig` + `nslookup`
        ethtool
        eza
        fastfetch
        fd
        file
        fish
        fzf # A command-line fuzzy finder
        gcc
        git
        gnutar
        iftop # network monitoring
        jq
        lazydocker
        lazygit
        lsof
        neovim
        pciutils
        ripgrep
        nixd
        starship
        television
        tmux
        tokei
        tree
        tree-sitter
        unzip
        usbutils # lsusb
        wget
        which
        xz
        zip
        zoxide
        zstd
        yazi
      ];
    })

    (lib.mkIf cfg.gui.enable {
      home.packages = with pkgs; [
        blueman
        bluetui
        libreoffice
        chromium
        firefox
        ghostty
        gimp
        gnome-calendar
        gnome-disk-utility
        gnome-keyring
        gnome-system-monitor
        gnome-themes-extra
        google-chrome
        grim
        localsend
        logiops
        nwg-displays
        nwg-look
        obs-studio
        openrgb
        papirus-icon-theme
        qalculate-gtk
        satty
        slurp
        wev
        wl-clipboard
        thunar
        mpv
        pear-desktop # youtube-music
      ];
    })
  ];
}
