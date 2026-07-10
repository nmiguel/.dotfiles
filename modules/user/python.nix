# Python development toolchain.
#
# Home-manager module: declares `userSettings.python.enable` and, when on,
# installs the interpreter plus the tools the nvim config drives — pyrefly and
# ruff (LSPs), ruff (formatter), and uv (project/venv manager).
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.userSettings.python;
in
{
  options.userSettings.python.enable =
    lib.mkEnableOption "the Python development toolchain";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      python3 # interpreter
      uv # project / dependency / venv manager
      ruff # linter, formatter and LSP (`ruff server`)
      pyrefly # type-checker LSP (`pyrefly lsp`)
    ];
  };
}
