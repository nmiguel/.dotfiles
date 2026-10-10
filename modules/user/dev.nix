# Development toolchains and editor tools for all languages.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.userSettings.dev;
in
{
  options.userSettings.dev.enabled = lib.mkEnableOption "the development toolchains for all languages";

  config = lib.mkIf cfg.enabled {
    home.packages = with pkgs; [
      # C/C++: also used by Rust builds and native Node.js addons.
      stdenv.cc

      # Go
      go # compiler / toolchain
      gopls # LSP
      gofumpt # formatter
      delve # debugger

      # JavaScript / TypeScript
      nodejs # runtime, npm and npx
      typescript # TypeScript compiler
      typescript-language-server # LSP
      prettier # formatter
      eslint # linter

      # Lua
      lua # interpreter
      lua-language-server # LSP
      stylua # formatter

      # Nix
      nixd # LSP
      nixfmt # formatter

      # Python
      python3 # interpreter
      uv # project / dependency / venv manager
      ruff # linter, formatter and LSP (`ruff server`)
      pyrefly # type-checker LSP (`pyrefly lsp`)

      # Rust
      rustc # compiler
      cargo # build system / package manager
      rust-analyzer # LSP
      rustfmt # formatter
      clippy # linter
    ];
  };
}
