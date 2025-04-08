{ config, pkgs, ... }:

{
  home.username = "nomig";
  home.homeDirectory = "/home/nomig";
  home.stateVersion = "23.05";
  home.packages = with pkgs; [
    fish
    tmux
    starship

    uv
    cargo
    rustc
    go
    python312Full
    nodejs
    lua

    fd
    lazygit
    lazydocker
    fzf
    television
    neovim
    neofetch
    bat
    docker
    jq
    ripgrep
    sqlite
    tree
    stow
    xclip
    xsel
  ];
  programs.home-manager.enable = true;
}

