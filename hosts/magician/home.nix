# Standalone Home Manager configuration for nomig on the macOS host `magician`.
{ pkgs, ... }:
{
  imports = [ ../../modules/user ];

  userSettings = {
    dotfiles = {
      enable = true;
      repoRoot = "/Users/nomig/projects/personal/.dotfiles";
      entries = [
        "btop"
        "fastfetch"
        "fish"
        "ghostty"
        "lazygit"
        "nix"
        "nvim"
        "opencode"
        "rsync"
        "starship.toml"
        "television"
        "tmux"
      ];
    };

    packages.cli.enable = true;

    python.enable = true;
    rust.enable = true;
    lua.enable = true;
    go.enable = true;
    js.enable = true;
  };

  # Home Manager copies supported native app bundles into
  # ~/Applications/Home Manager Apps without managing macOS itself.
  targets.darwin.copyApps.enable = true;

  home.packages = with pkgs; [
    _1password-cli
    _1password-gui
    firefox
    google-chrome
    kitty
    localsend
    mpv
    pear-desktop # YouTube Music
    qalculate-gtk

    fira-sans
    inter
    noto-fonts
    source-sans
    source-serif
    nerd-fonts.caskaydia-mono
    nerd-fonts.commit-mono
    nerd-fonts.fira-mono
    nerd-fonts.jetbrains-mono
  ];

  home.username = "nomig";
  home.homeDirectory = "/Users/nomig";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
