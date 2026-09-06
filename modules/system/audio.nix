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

  virtualOutput =
    name: description: output:
    let
      volume = toString (cubicVolume output.volume);
      captureProps = ''
        {
          node.name = "${name}"
          node.description = "${description}"
          media.class = "Audio/Sink"
          audio.position = [ FL FR ]
          node.param.Props = { channelVolumes = [ ${volume} ${volume} ] }
          priority.session = 1400
          state.restore-props = false
        }
      '';
      playbackProps = ''
        {
          node.name = "playback.${name}"
          audio.position = [ FL FR ]
          node.autoconnect = false
          node.dont-move = true
          node.passive = true
          stream.dont-remix = true
        }
      '';
    in
    pkgs.writeShellScript "${name}-loopback" ''
      exec ${pkgs.pipewire}/bin/pw-loopback \
        --name ${lib.escapeShellArg "${name}_loopback"} \
        --capture-props ${lib.escapeShellArg captureProps} \
        --playback-props ${lib.escapeShellArg playbackProps}
    '';

  virtualHeadphones =
    virtualOutput "virtual_headphones_sink" "Virtual Headphones"
      cfg.virtualOutputs.headphones;
  virtualSpeakers =
    virtualOutput "virtual_speakers_sink" "Virtual Speakers"
      cfg.virtualOutputs.speakers;

  virtualMicrophone =
    let
      boost = toString cfg.virtualInputs.microphone.boost;
      captureProps = ''
        {
          node.name = "capture.virtual_microphone_source"
          node.description = "Virtual Microphone Capture"
          audio.position = [ MONO ]
          node.autoconnect = false
          node.dont-move = true
          node.param.Props = { channelVolumes = [ ${boost} ] }
          node.passive = true
          state.restore-props = false
          stream.dont-remix = true
        }
      '';
      playbackProps = ''
        {
          node.name = "virtual_microphone_source"
          node.description = "Virtual Microphone"
          media.class = "Audio/Source"
          audio.position = [ MONO ]
          priority.session = 2400
          state.restore-props = false
        }
      '';
    in
    pkgs.writeShellScript "virtual_microphone_source-loopback" ''
      exec ${pkgs.pipewire}/bin/pw-loopback \
        --name virtual_microphone_source_loopback \
        --channels 1 \
        --channel-map '[ MONO ]' \
        --capture-props ${lib.escapeShellArg captureProps} \
        --playback-props ${lib.escapeShellArg playbackProps}
    '';

  virtualOutputService = description: command: {
    Unit = {
      Description = description;
      After = [ "pipewire.service" ];
      BindsTo = [ "pipewire.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = command;
      Restart = "always";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  routeVirtualOutputs = pkgs.writeShellScript "route-virtual-outputs" ''
    find_node_id() {
      ${pkgs.wireplumber}/bin/wpctl status -n | ${pkgs.gawk}/bin/awk -v name="$1" '
        {
          for (field = 1; field <= NF; field++) {
            if ($field != name) continue

            for (id = field - 1; id >= 1; id--) {
              if ($id ~ /^[0-9]+\.$/) {
                sub(/\.$/, "", $id)
                print $id
                exit
              }
            }
          }
        }
      '
    }

    link_output() {
      playback=$1
      target=$2

      for channel in FL FR; do
        output_port="$playback:output_$channel"
        input_port="$target:playback_$channel"

        if ! ${pkgs.pipewire}/bin/pw-link -l "$output_port" "$input_port" \
          | ${pkgs.gnugrep}/bin/grep -qF -- '|->'; then
          ${pkgs.pipewire}/bin/pw-link -P "$output_port" "$input_port" \
            >/dev/null 2>&1 || true
        fi
      done
    }

    link_input() {
      capture=$1
      target=$2
      input_port="$capture:input_MONO"
      output_port=$(
        ${pkgs.pipewire}/bin/pw-link -o | ${pkgs.gawk}/bin/awk -v prefix="$target:" '
          {
            sub(/^[[:space:]]+/, "")
            if (index($0, prefix) == 1) {
              print
              exit
            }
          }
        '
      )

      if [[ -n "$output_port" ]] \
        && ! ${pkgs.pipewire}/bin/pw-link -l "$output_port" "$input_port" \
          | ${pkgs.gnugrep}/bin/grep -qF -- '|->'; then
        ${pkgs.pipewire}/bin/pw-link -P "$output_port" "$input_port" \
          >/dev/null 2>&1 || true
      fi
    }

    reconcile() {
      link_output \
        playback.virtual_headphones_sink \
        ${lib.escapeShellArg cfg.virtualOutputs.headphones.target}
      link_output \
        playback.virtual_speakers_sink \
        ${lib.escapeShellArg cfg.virtualOutputs.speakers.target}
      link_input \
        capture.virtual_microphone_source \
        ${lib.escapeShellArg cfg.virtualInputs.microphone.target}

      headphones_id=$(find_node_id ${lib.escapeShellArg cfg.virtualOutputs.headphones.target})
      if [[ -n "$headphones_id" ]]; then
        ${pkgs.wireplumber}/bin/wpctl set-volume \
          "$headphones_id" \
          ${toString cfg.virtualOutputs.headphones.targetVolume}%
      fi

      current_sink=$(
        ${pkgs.wireplumber}/bin/wpctl inspect @DEFAULT_AUDIO_SINK@ \
          | ${pkgs.gawk}/bin/awk -F'"' '/node.name =/ { print $2; exit }'
      )
      case "$current_sink" in
        virtual_headphones_sink | virtual_speakers_sink) ;;
        *)
          virtual_id=$(find_node_id virtual_headphones_sink)
          if [[ -n "$virtual_id" ]]; then
            ${pkgs.wireplumber}/bin/wpctl set-default "$virtual_id"
          fi
          ;;
      esac

      current_source=$(
        ${pkgs.wireplumber}/bin/wpctl inspect @DEFAULT_AUDIO_SOURCE@ \
          | ${pkgs.gawk}/bin/awk -F'"' '/node.name =/ { print $2; exit }'
      )
      if [[ "$current_source" != virtual_microphone_source ]]; then
        virtual_id=$(find_node_id virtual_microphone_source)
        if [[ -n "$virtual_id" ]]; then
          ${pkgs.wireplumber}/bin/wpctl set-default "$virtual_id"
        fi
      fi
    }

    reconcile
    while IFS= read -r _; do
      while IFS= read -r -t 0.1 _; do :; done
      reconcile
    done < <(${pkgs.pipewire}/bin/pw-link -mil)
  '';

  routeExistingOutputs = pkgs.writeShellScript "route-existing-outputs" ''
    default_output=$(
      ${pkgs.wireplumber}/bin/wpctl inspect @DEFAULT_AUDIO_SINK@ \
        | ${pkgs.gawk}/bin/awk -F'"' '/node.name =/ { print $2; exit }'
    )
    case "$default_output" in
      virtual_headphones_sink | virtual_speakers_sink) ;;
      *) exit 0 ;;
    esac

    for _ in $(${pkgs.coreutils}/bin/seq 1 50); do
      read -r sink_id sink_serial < <(
        ${pkgs.pipewire}/bin/pw-dump | ${pkgs.jq}/bin/jq -r '
          .[]
          | select(.type == "PipeWire:Interface:Node")
          | select(.info.props["node.name"] == "easyeffects_sink")
          | [.id, .info.props["object.serial"]]
          | @tsv
        '
      )

      if [[ -n "''${sink_id:-}" && -n "''${sink_serial:-}" ]]; then
        break
      fi
      ${pkgs.coreutils}/bin/sleep 0.1
    done

    if [[ -z "''${sink_id:-}" || -z "''${sink_serial:-}" ]]; then
      exit 0
    fi

    while IFS= read -r stream_id; do
      ${pkgs.pipewire}/bin/pw-metadata -n default \
        "$stream_id" target.node "$sink_id" Spa:Id >/dev/null
      ${pkgs.pipewire}/bin/pw-metadata -n default \
        "$stream_id" target.object "$sink_serial" Spa:Id >/dev/null
    done < <(
      ${pkgs.pipewire}/bin/pw-dump | ${pkgs.jq}/bin/jq -r --arg target "$default_output" '
        .[]
        | select(.type == "PipeWire:Interface:Node")
        | select(.info.props["media.class"] == "Stream/Output/Audio")
        | select(.info.props["target.object"] == $target)
        | .id
      '
    )
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
          default = 30;
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
          default = 30;
          description = "Initial volume percentage shown for Virtual Speakers";
        };
      };
    };

    virtualInputs.microphone = {
      target = lib.mkOption {
        type = lib.types.str;
        description = "PipeWire node.name of the physical microphone source";
      };

      boost = lib.mkOption {
        type = lib.types.float;
        default = 1.35;
        description = "Linear gain applied before audio reaches Virtual Microphone";
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

    };

    home-manager.users.nomig = {
      services.easyeffects = {
        enable = true;
        preset.output = "LoudnessEqualizer_Amplify";
        extraPresets.LoudnessEqualizer_Amplify = builtins.fromJSON (
          builtins.readFile ./audio-presets/LoudnessEqualizer_Amplify.json
        );

        settings = {
          EffectsPipelines.processAllInputs = false;
          EffectsPipelines.processAllOutputs = true;
          StreamInputs = {
            inputDevice = "virtual_microphone_source";
            listenToMic = false;
            useDefaultInputDevice = true;
          };
          StreamOutputs = {
            linkToVirtualSource = false;
            outputDevice = "virtual_headphones_sink";
            useDefaultOutputDevice = true;
          };
        };
      };

      systemd.user.services = {
        virtual-headphones = virtualOutputService "Provide the Virtual Headphones sink" virtualHeadphones;
        virtual-microphone = virtualOutputService "Provide the Virtual Microphone source" virtualMicrophone;
        virtual-speakers = virtualOutputService "Provide the Virtual Speakers sink" virtualSpeakers;

        easyeffects.Unit.After = [
          "audio-routing.service"
          "pipewire.service"
          "wireplumber.service"
        ];

        audio-routing = {
          Unit = {
            Description = "Route stable virtual outputs to physical devices";
            After = [
              "pipewire.service"
              "virtual-headphones.service"
              "virtual-microphone.service"
              "virtual-speakers.service"
              "wireplumber.service"
            ];
            BindsTo = [ "pipewire.service" ];
            PartOf = [ "graphical-session.target" ];
            Requires = [
              "virtual-headphones.service"
              "virtual-microphone.service"
              "virtual-speakers.service"
            ];
          };
          Service = {
            ExecStart = routeVirtualOutputs;
            Restart = "always";
            RestartSec = 1;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };

      xdg.configFile."systemd/user/easyeffects.service.d/route-existing.conf".text = ''
        [Service]
        ExecStartPost=${routeExistingOutputs}
      '';
    };
  };
}
