{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.systemSettings.audio;

  percentageType = lib.types.ints.between 0 100;

  # PipeWire stores the volume shown by wpctl on a cubic scale.
  cubicVolume =
    percentage:
    let
      volume = percentage / 100.0;
    in
    volume * volume * volume;

  virtualSink = name: description: output: {
    name = "libpipewire-module-loopback";
    args = {
      "node.description" = description;

      "capture.props" = {
        "node.name" = name;
        "media.class" = "Audio/Sink";
        "audio.position" = [
          "FL"
          "FR"
        ];
        "adapter.auto-port-config" = {
          mode = "dsp";
          monitor = false;
          control = false;
          position = "preserve";
        };
        "node.param.Props" = {
          channelVolumes = [
            (cubicVolume output.volume)
            (cubicVolume output.volume)
          ];
        };
        "priority.session" = 1400;
        "state.restore-props" = false;
      };

      "playback.props" = {
        "node.name" = "playback.${name}";
        "target.object" = output.target;
        "audio.position" = [
          "FL"
          "FR"
        ];
        "node.dont-fallback" = true;
        "node.dont-move" = true;
        "node.passive" = true;
        "stream.dont-remix" = true;
      };
    };
  };

  setHeadphoneVolume = pkgs.writeShellScript "set-headphone-volume" ''
    target_name=${lib.escapeShellArg cfg.virtualOutputs.headphones.target}

    for _ in $(${pkgs.coreutils}/bin/seq 1 100); do
      target_id="$(${pkgs.wireplumber}/bin/wpctl status -n | ${pkgs.gawk}/bin/awk -v name="$target_name" '
        index($0, name) && match($0, /[0-9]+\./) {
          print substr($0, RSTART, RLENGTH - 1)
          exit
        }
      ')"

      if [[ -n "$target_id" ]]; then
        exec ${pkgs.wireplumber}/bin/wpctl set-volume "$target_id" ${toString cfg.virtualOutputs.headphones.targetVolume}%
      fi

      ${pkgs.coreutils}/bin/sleep 0.1
    done

    echo "Physical headphone sink '$target_name' did not appear" >&2
    exit 1
  '';
in
{
  options.systemSettings.audio = {
    enable = lib.mkEnableOption "the PipeWire audio stack and EasyEffects";

    virtualOutputs = {
      headphones = {
        target = lib.mkOption {
          type = lib.types.str;
          description = "PipeWire node.name of the physical headphone sink";
        };

        volume = lib.mkOption {
          type = percentageType;
          default = 50;
          description = "Initial volume percentage shown for Virtual Headphones";
        };

        targetVolume = lib.mkOption {
          type = percentageType;
          default = 6;
          description = "Physical headphone volume, scaled beneath the virtual sink";
        };
      };

      speakers = {
        target = lib.mkOption {
          type = lib.types.str;
          description = "PipeWire node.name of the physical speaker sink";
        };

        volume = lib.mkOption {
          type = percentageType;
          default = 50;
          description = "Initial volume percentage shown for Virtual Speakers";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      extraConfig.pipewire."10-virtual-outputs"."context.modules" = [
        (virtualSink "virtual_headphones_sink" "Virtual Headphones" cfg.virtualOutputs.headphones)
        (virtualSink "virtual_speakers_sink" "Virtual Speakers" cfg.virtualOutputs.speakers)
      ];

      wireplumber.extraConfig."10-disable-hardware-monitors"."monitor.alsa.rules" = [
        {
          matches = [
            { "node.name" = "~alsa_output.*"; }
          ];
          actions.update-props."adapter.auto-port-config" = {
            mode = "dsp";
            monitor = false;
            control = false;
            position = "preserve";
          };
        }
      ];
    };

    home-manager.users.nomig = {
      services.easyeffects = {
        enable = true;
        preset.output = "LoudnessEqualizer_Amplify";
        extraPresets.LoudnessEqualizer_Amplify = builtins.fromJSON (
          builtins.readFile ./audio-presets/LoudnessEqualizer_Amplify.json
        );

        settings = {
          StreamInputs = {
            inputDevice = null;
            listenToMic = false;
            useDefaultInputDevice = true;
          };
          StreamOutputs = {
            linkToVirtualSource = false;
            outputDevice = null;
            useDefaultOutputDevice = true;
          };
        };
      };

      systemd.user.services = {
        easyeffects.Unit.After = [
          "pipewire.service"
          "wireplumber.service"
        ];

        set-headphone-volume = {
          Unit = {
            Description = "Apply the physical headphone volume scale";
            After = [
              "pipewire.service"
              "wireplumber.service"
            ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = setHeadphoneVolume;
            RemainAfterExit = true;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
