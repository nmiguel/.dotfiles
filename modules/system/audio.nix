# Audio stack: PipeWire and EasyEffects.
#
# Two-layer module: declares `systemSettings.audio.enable` and configures both
# the system side (PipeWire) and the per-user EasyEffects, so audio toggles as
# a unit.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.systemSettings.audio;
in
{
  options.systemSettings.audio.enable =
    lib.mkEnableOption "the PipeWire audio stack and EasyEffects";

  config = lib.mkIf cfg.enable {
    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Per-user EasyEffects, driven from here so the audio stack toggles as a unit.
    home-manager.users.nomig = {
      services.easyeffects.enable = true;
      home.packages = [ pkgs.easyeffects ];
    };
  };
}
