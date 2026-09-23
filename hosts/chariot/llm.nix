{
  config,
  lib,
  pkgs,
  ...
}:
let
  dataRoot = "/mnt/data";
  llmHost = "llm.getthybearings.xyz";
  ollamaStateDir = "${dataRoot}/services/ollama";
  ollamaLibDir = "${pkgs.ollama-cuda}/lib/ollama";
  persistentDirectoriesService = "chariot-persistent-directories.service";
  waitForCuda = pkgs.writeShellScript "wait-for-ollama-cuda" ''
    export GGML_BACKEND_PATH=${ollamaLibDir}/cuda_v12/libggml-cuda.so
    export LD_LIBRARY_PATH=${ollamaLibDir}:${ollamaLibDir}/cuda_v12

    for attempt in $(${pkgs.coreutils}/bin/seq 1 6); do
      if output="$(${pkgs.coreutils}/bin/timeout --kill-after=5s 20s \
        ${ollamaLibDir}/llama-server --list-devices 2>&1)" \
        && ${pkgs.gnugrep}/bin/grep --quiet 'CUDA[0-9]:' <<< "$output"; then
        printf '%s\n' "$output"
        exit 0
      fi

      printf 'CUDA probe %s/6 failed: %s\n' "$attempt" "$output" >&2
      ${pkgs.coreutils}/bin/sleep 5
    done

    exit 1
  '';
in
{
  boot.kernelModules = [ "nvidia_uvm" ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaPersistenced = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    user = "ollama";
    group = "ollama";
    home = ollamaStateDir;
    host = "127.0.0.1";
    port = 11434;
    openFirewall = false;
    loadModels = [
            "qwen3:14b"
            "qwen3-vl:8b"
    ];
    syncModels = true;
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "-1";
      OLLAMA_LLM_LIBRARY = "cuda_v12";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_ORIGINS = "https://${llmHost}";
    };
  };

  services.tailscale.serve.services.llm = {
    advertised = true;
    endpoints."tcp:443" = "tcp://127.0.0.1:443";
  };

  security.acme.certs.${llmHost} = {
    dnsProvider = "cloudflare";
    credentialFiles.CF_DNS_API_TOKEN_FILE = "${dataRoot}/secrets/chariot/ddclient-cloudflare-token";
  };

  services.caddy.virtualHosts.${llmHost} = {
    listenAddresses = [ "127.0.0.1" ];
    useACMEHost = llmHost;
    extraConfig = ''
      reverse_proxy 127.0.0.1:11434 {
        header_up Host 127.0.0.1:11434
        flush_interval -1
      }
    '';
  };

  systemd.services = {
    chariot-persistent-directories = {
      before = [
        "ollama.service"
        "ollama-model-loader.service"
      ];
      script = lib.mkAfter ''
        ${pkgs.coreutils}/bin/install -d -m 0750 -o ollama -g ollama ${ollamaStateDir}
      '';
    };

    ollama = {
      after = [
        persistentDirectoriesService
        "nvidia-persistenced.service"
      ];
      requires = [ persistentDirectoriesService ];
      wants = [ "nvidia-persistenced.service" ];
      unitConfig.RequiresMountsFor = dataRoot;
      serviceConfig = {
        ExecStartPre = [ waitForCuda ];
        Restart = "on-failure";
        RestartSec = "5s";
        TimeoutStartSec = "3min";
      };
    };

    ollama-model-loader = {
      after = [ persistentDirectoriesService ];
      requires = [ persistentDirectoriesService ];
      unitConfig.RequiresMountsFor = dataRoot;
    };
  };
}
