# Lua development toolchain.
#
# Home-manager module: declares `userSettings.lua.enable` and, when on,
# installs the interpreter plus the tools the nvim config drives —
# lua-language-server (LSP) and stylua (formatter).
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.userSettings.lua;
in
{
  options.userSettings.lua.enable =
    lib.mkEnableOption "the Lua development toolchain";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      lua # interpreter
      lua-language-server # LSP
      stylua # formatter
    ];
  };
}
