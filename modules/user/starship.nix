# Nerd Font symbols come from the preset; only overrides are maintained here.
{ config, lib, ... }:
{
  options.userSettings.starship.enable = lib.mkEnableOption "the shared Starship prompt" // {
    default = config.userSettings.packages.cli.enable;
  };

  config = lib.mkIf config.userSettings.starship.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
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
        aws.disabled = true;
        conda.symbol = " ";
        dart.symbol = " ";
        directory.style = "bold blue";
        git_status = {
          windows_starship = "/mnt/c/Program Files/starship/bin/starship";
          style = "purple";
        };
        hostname.format = "[$ssh_symbol]($style) ";
        java.symbol = " ";
        nim.symbol = "󰆥 ";
        os.symbols = {
          Emscripten = " ";
          EndeavourOS = " ";
          Garuda = "󰛓 ";
          Illumos = "󰈸 ";
          OpenBSD = "󰈺 ";
          OracleLinux = "󰌷 ";
          Redhat = " ";
          RedHatEnterprise = " ";
          Solus = "󰠳 ";
        };
        package.disabled = true;
        python.style = "fg:#499de4";
        rust.symbol = " ";
        username.disabled = true;
      };
    };
  };
}
