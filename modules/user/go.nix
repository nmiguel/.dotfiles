# Go development toolchain.
#
# Home-manager module: declares `userSettings.go.enable` and, when on,
# installs the compiler plus the tools the nvim config drives — gopls (LSP)
# and gofumpt (formatter), with delve for debugging.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.userSettings.go;
in
{
  options.userSettings.go.enable =
    lib.mkEnableOption "the Go development toolchain";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      go # compiler / toolchain
      gopls # LSP
      gofumpt # formatter
      delve # debugger
    ];
  };
}
