# Nerd Font symbols come from the preset; only overrides are maintained here.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.userSettings.starship.enable = lib.mkEnableOption "the shared Starship prompt" // {
    default = config.userSettings.packages.cli.enable;
  };

  config = lib.mkIf config.userSettings.starship.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      extraPackages = [ pkgs.jj-starship ];
      presets = [ "nerd-font-symbols" ];
      settings = {
        palette = "custom";
        palettes.custom = {
          black = "#5C6773";
          red = "#FF3333";
          green = "#BAE67E";
          yellow = "#FFCC66";
          blue = "#5CCFE6";
          white = "#CBCCC6";
          purple = "#D4BFFF";
        };
        cmd_duration = {
          min_time = 500;
          show_milliseconds = true;
          format = "[ 󱎫 $duration ]($style)";
        };
        directory.style = "bold blue";
        custom.jj = {
          when = "${lib.getExe pkgs.jj-starship} detect";
          shell = [ (lib.getExe pkgs.jj-starship) ];
          format = "$output ";
        };
        # jj-starship renders repository information for both Git and JJ.
        git_branch.disabled = true;
        git_commit.disabled = true;
        git_state.disabled = true;
        git_metrics.disabled = true;
        git_status = {
          disabled = true;
        };
        hostname.format = "[$ssh_symbol]($style) ";
        package.disabled = true;
        python.style = "fg:#499de4";
        rust.symbol = "🦀 ";
        username.disabled = true;
      };
    };
  };
}
