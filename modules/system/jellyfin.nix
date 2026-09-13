# Jellyfin media server + the "*arr" automation stack.
#
# Two-layer module: declares `systemSettings.jellyfin.enable` and stays inert
# until a host flips it on. Every service auto-starts on boot (systemd) and its
# firewall port is opened so clients on the LAN can reach the web UIs.
#
# The request/download pipeline:
#
#   Jellyseerr  -> Radarr / Sonarr -> Prowlarr (trackers)
#   (requests)     (the "brains")  |
#                                  v
#                            Transmission (downloads)
#                                  |
#                                  v
#                       /var/lib/media  ->  Jellyfin (library)
#
# Jellyseerr takes requests and hands them to Radarr (movies) / Sonarr (TV).
# Those search the trackers synced from Prowlarr, send the pick to Transmission,
# then move the finished file into /var/lib/media where Jellyfin serves it.
{
  config,
  lib,
  ...
}:
let
  cfg = config.systemSettings.jellyfin;
  persistentState = cfg.stateRoot != null;
  serviceState = name: "${cfg.stateRoot}/${name}";
in
{
  options.systemSettings.jellyfin = {
    enable = lib.mkEnableOption "the Jellyfin media server and *arr request/download stack";

    stateRoot = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/mnt/data/services/media";
      description = "Persistent root for media-service state; null uses each service's default location.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Shared group so Transmission's completed downloads are readable by
    # Radarr/Sonarr, and the finished library is readable by Jellyfin. Without
    # this, each service can only see its own files and imports silently fail.
    users.groups.media = { };
    users.users = {
      jellyfin.extraGroups = [ "media" ];
      radarr.extraGroups = [ "media" ];
      sonarr.extraGroups = [ "media" ];
      bazarr.extraGroups = [ "media" ];
      transmission.extraGroups = [ "media" ];
    }
    // lib.optionalAttrs persistentState {
      seerr = {
        isSystemUser = true;
        group = "seerr";
        home = serviceState "seerr";
      };
    };
    users.groups.seerr = lib.mkIf persistentState { };

    # Library layout. The setgid bit (leading 2) makes new files inherit the
    # `media` group so Jellyfin can always read what Radarr/Sonarr drop in.
    systemd.tmpfiles.rules =
      if persistentState then
        [
          "d ${cfg.stateRoot} 0755 root root - -"
          "d ${serviceState "seerr"} 0700 seerr seerr - -"
          "d ${serviceState "sonarr"} 0700 sonarr sonarr - -"
          "d ${serviceState "transmission"} 0750 transmission media - -"
        ]
      else
        [
          "d /var/lib/media 0775 root media - -"
          "d /var/lib/media/movies 2775 radarr media - -"
          "d /var/lib/media/tv 2775 sonarr media - -"
        ];

    # Jellyfin media server. Runs under its own `jellyfin` user, auto-starts on
    # boot, and opens the firewall for LAN clients (HTTP 8096 / HTTPS 8920 plus
    # the DLNA/discovery UDP ports).
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    }
    // lib.optionalAttrs persistentState {
      dataDir = serviceState "jellyfin";
      cacheDir = serviceState "jellyfin-cache";
    };

    # Jellyseerr — request/discovery front-end that talks to Jellyfin.
    # Listens on port 5055. (nixpkgs renamed the old `services.jellyseerr`
    # option to `services.seerr`.)
    services.seerr = {
      enable = true;
      openFirewall = true;
    }
    // lib.optionalAttrs persistentState {
      configDir = serviceState "seerr";
    };

    # Radarr (movies, web UI :7878) and Sonarr (TV, :8989). These fulfil the
    # requests: search trackers, grab via Transmission, then rename/move the
    # finished file into /var/lib/media.
    services.radarr = {
      enable = true;
      openFirewall = true;
    }
    // lib.optionalAttrs persistentState {
      dataDir = serviceState "radarr";
    };
    services.sonarr = {
      enable = true;
      openFirewall = true;
    }
    // lib.optionalAttrs persistentState {
      dataDir = serviceState "sonarr";
    };

    # Bazarr (web UI :6767) — subtitle companion. Watches Radarr's and Sonarr's
    # libraries and downloads matching subtitles alongside each video file.
    services.bazarr = {
      enable = true;
      openFirewall = true;
    }
    // lib.optionalAttrs persistentState {
      dataDir = serviceState "bazarr";
    };

    # Prowlarr (web UI :9696) — central tracker/indexer manager. Add each
    # tracker once here and it syncs them into Radarr and Sonarr.
    services.prowlarr = {
      enable = true;
      openFirewall = true;
    }
    // lib.optionalAttrs persistentState {
      dataDir = serviceState "prowlarr";
    };

    # FlareSolverr (:8191) — headless-browser proxy that solves the Cloudflare
    # challenges guarding some public trackers. Only Prowlarr talks to it over
    # localhost, so its port stays closed to the LAN.
    services.flaresolverr = {
      enable = true;
      openFirewall = false;
    };

    # Transmission — the torrent client that does the actual downloading.
    # `openFirewall` opens the peer port; `openRPCPort` opens the :9091 web UI.
    # umask 002 makes downloads group-writable so Radarr/Sonarr can move them.
    services.transmission = {
      enable = true;
      openFirewall = true;
      openRPCPort = true;
      group = "media";
      home = if persistentState then serviceState "transmission" else "/var/lib/transmission";
      settings = {
        download-dir =
          if persistentState then
            "${serviceState "transmission"}/Downloads"
          else
            "/var/lib/transmission/Downloads";
        incomplete-dir =
          if persistentState then
            "${serviceState "transmission"}/.incomplete"
          else
            "/var/lib/transmission/.incomplete";
        incomplete-dir-enabled = true;
        umask = 2;
        # Stop seeding once a torrent hits ratio 2.0 OR sits idle (no peers)
        # for 60 min, whichever comes first — otherwise Transmission seeds
        # forever. This only *pauses* the torrent; Radarr/Sonarr's "Remove
        # Completed" option then deletes the finished torrent + its download
        # copy. (Raise these on private trackers, which require seed time.)
        ratio-limit-enabled = true;
        ratio-limit = 2.0;
        idle-seeding-limit-enabled = true;
        idle-seeding-limit = 60;
        # Expose the web UI to the LAN. Fine on a trusted home network; tighten
        # rpc-whitelist if this host is reachable from elsewhere.
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist-enabled = false;
        rpc-host-whitelist-enabled = false;
      };
    };

    systemd.services.seerr = lib.mkIf persistentState {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        StateDirectory = lib.mkForce [ ];
        User = "seerr";
        Group = "seerr";
        ReadWritePaths = [ (serviceState "seerr") ];
      };
    };
  };
}
