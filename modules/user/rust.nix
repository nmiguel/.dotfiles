# Rust development toolchain.
#
# Home-manager module: declares `userSettings.rust.enable` and, when on,
# installs the compiler and cargo plus the tools the nvim config drives —
# rust-analyzer (LSP) and rustfmt (formatter), with clippy for linting.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.userSettings.rust;
in
{
  options.userSettings.rust.enable = lib.mkEnableOption "the Rust development toolchain";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      rustc # compiler
      cargo # build system / package manager
      rust-analyzer # LSP
      rustfmt # formatter
      clippy # linter
      gcc
    ];
  };
}
