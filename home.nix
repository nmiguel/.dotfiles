{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

let
  repoRoot = "/home/nomig/projects/personal/.dotfiles";
  configDir = ./stow/config;

  configEntries = builtins.listToAttrs (
    map (name: {
      name = ".config/${name}";
      value.source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/stow/config/${name}";
    }) (builtins.attrNames (builtins.readDir configDir))
  );
in
{
  home.username = "nomig";
  home.homeDirectory = "/home/nomig";
  home.stateVersion = "25.11";

  # home.file.".config/alacritty".source =
  #   config.lib.file.mkOutOfStoreSymlink "/home/nomig/projects/personal/.dotfiles/stow/config/alacritty";

  home.file =
    configEntries
    // {
      # TODO: handle this better, it's not detected by readDir as it's a submodule
      ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/stow/config/nvim";
    }
    # Install icons
    // builtins.listToAttrs (
      map (name: {
        name = ".local/share/icons/hicolor/128x128/apps/${name}";
        value = {
          source = ./icons + "/${name}";
        };
      }) (builtins.attrNames (builtins.readDir ./icons))
    );

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;
    configType = "lua";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk4.theme = config.gtk.theme;
    gtk4.iconTheme = config.gtk.iconTheme;
    gtk3.theme = config.gtk.theme;
    gtk3.iconTheme = config.gtk.iconTheme;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "papirus-dark";
  };

  programs.noctalia.enable = true;

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Packages that should be installed to the user profile.
  home.packages = (
    with pkgs;
    [
      bat
      blueman
      bluetui
      ncdu
      borgmatic
      btop
      libreoffice
      chromium
      dnsutils # `dig` + `nslookup`
      easyeffects
      ethtool
      eza
      fastfetch
      fd
      file
      firefox
      fish
      fzf # A command-line fuzzy finder
      ghostty
      gimp
      gnome-calendar
      gnome-disk-utility
      gnome-keyring
      gnome-system-monitor
      gnome-themes-extra
      gnutar
      google-chrome
      grim
      iftop # network monitoring
      jq
      lazydocker
      lazygit
      localsend
      logiops
      lsof
      lutris
      nwg-displays
      nwg-look
      obs-studio
      openrgb
      papirus-icon-theme
      pciutils
      qalculate-gtk
      ripgrep
      nixd
      satty
      slurp
      starship
      television
      tmux
      tokei
      tree
      unzip
      usbutils # lsusb
      wev
      wget
      which
      xz
      zip
      zoxide
      zstd
      wl-clipboard
      thunar
      yazi
      uv
      mpv
      pear-desktop # youtube-music
    ]
  );
  xdg.desktopEntries.claude = {
    name = "Claude";
    genericName = "AI Assistant";
    exec = "chromium --app=https://claude.ai --class=claude";
    icon = "claude";
    comment = "Claude AI";
  };
  services.easyeffects.enable = true;

}
