# JavaScript and TypeScript development toolchain.
#
# Home-manager module: declares `userSettings.js.enable` and, when on,
# installs Node.js and npm plus the tools the nvim config drives —
# typescript-language-server (LSP), Prettier (formatter), and ESLint (linter).
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.userSettings.js;
in
{
  options.userSettings.js.enable =
    lib.mkEnableOption "the JavaScript and TypeScript development toolchain";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs # runtime, npm and npx
      typescript # TypeScript compiler
      typescript-language-server # JavaScript / TypeScript LSP
      prettier # formatter
      eslint # linter
      gcc # native Node.js addon compilation
    ];
  };
}
