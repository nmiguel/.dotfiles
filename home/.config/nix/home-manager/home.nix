{ config, pkgs, ... }:

{
  home.username = "nomig";
  home.homeDirectory = "/home/nomig";
  home.stateVersion = "23.05";
  home.packages = with pkgs; [
    bat
    cargo
    cmake
    docker
    fd
    fish
    fzf
    gcc
    gh
    gnumake
    go
    jq
    lazydocker
    lazygit
    lua
    neofetch
    neovim
    nodejs
    python312Full
    ripgrep
    rustc
    sqlite
    starship
    stow
    television
    tmux
    tree
    uv
    xclip
    xsel
    zoxide
  ];
  programs.home-manager.enable = true;
}

