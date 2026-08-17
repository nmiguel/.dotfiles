{
  lib,
  pkgs,
  ...
}:
let
  dataRoot = "/mnt/data";
  secretRoot = "${dataRoot}/secrets/chariot";
  giteaStateDir = "${dataRoot}/services/gitea-native";
  giteaReady = "${giteaStateDir}/.nixos-ready";
  seafileRoot = "${dataRoot}/services/seafile";
  seafileSecretEnv = "${secretRoot}/seafile.env";
  seafileMysqlSecretEnv = "${secretRoot}/seafile-mysql.env";
  seafileReady = "${seafileRoot}/.nixos-ready";
in
{
  systemSettings.fish.enable = true;

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking = {
    hostName = "chariot";
    networkmanager.enable = true;
    nftables.enable = true;

    firewall = {
      enable = true;
      backend = "nftables";
      allowedTCPPorts = [
        80
        443
        222
      ];

      # Keep host SSH and CUPS private without publishing the actual LAN range.
      extraInputRules = ''
        ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } tcp dport { 22, 631 } accept
      '';
    };
  };

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.nomig = {
    isNormalUser = true;
    description = "Nuno Ramos";
    uid = 1000;
    extraGroups = [
      "docker"
      "lpadmin"
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfSc6o1n3wa2I1lmEuEleV+jfZBJU2uuFXTLes/PFXP home-server"
    ];
  };
  # Keep persistent Gitea ownership stable across root-disk reinstalls.
  users.users.gitea.uid = 989;
  users.groups.gitea.gid = 989;

  services.openssh = {
    enable = true;
    openFirewall = false;
    hostKeys = [
      {
        path = "${secretRoot}/openssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "${secretRoot}/openssh/ssh_host_ecdsa_key";
        type = "ecdsa";
      }
      {
        path = "${secretRoot}/openssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 3072;
      }
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.caddy = {
    enable = true;
    dataDir = "${dataRoot}/services/caddy";
    openFirewall = false;

    virtualHosts = {
      "git.getthybearings.xyz".extraConfig = ''
        reverse_proxy 127.0.0.1:3000
      '';

      "drive.getthybearings.xyz".extraConfig = ''
        reverse_proxy 127.0.0.1:3100 {
          header_up Host {host}
          header_up X-Real-IP {remote_host}
          header_up X-Forwarded-For {remote_host}
          flush_interval -1
        }
      '';
    };
  };

  services.ddclient = {
    enable = true;
    interval = "5min";
    protocol = "cloudflare";
    username = "token";
    passwordFile = "${secretRoot}/ddclient-cloudflare-token";
    zone = "getthybearings.xyz";
    domains = [
      "getthybearings.xyz"
      "*.getthybearings.xyz"
      "www.getthybearings.xyz"
      "drive.getthybearings.xyz"
    ];
    usev4 = "webv4, webv4=ifconfig.me/ip";
    usev6 = "";
    extraConfig = "ttl=1";
  };

  services.gitea = {
    enable = true;
    package = pkgs.gitea;
    appName = "Gitea";
    stateDir = giteaStateDir;
    customDir = "${giteaStateDir}/gitea";
    repositoryRoot = "${giteaStateDir}/git/repositories";

    database = {
      type = "postgres";
      createDatabase = true;
    };

    lfs = {
      enable = true;
      contentDir = "${giteaStateDir}/git/lfs";
    };

    dump = {
      enable = true;
      interval = "daily";
      backupDir = "${dataRoot}/backups/gitea";
      type = "tar.zst";
    };

    settings = {
      server = {
        APP_DATA_PATH = "${giteaStateDir}/gitea";
        DOMAIN = "git.getthybearings.xyz";
        SSH_DOMAIN = "git.getthybearings.xyz";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3000;
        ROOT_URL = "https://git.getthybearings.xyz/";
        DISABLE_SSH = false;
        START_SSH_SERVER = true;
        SSH_LISTEN_PORT = 222;
        SSH_PORT = 22;
        SSH_SERVER_HOST_KEYS = builtins.concatStringsSep "," [
          "${giteaStateDir}/ssh/ssh_host_rsa_key"
          "${giteaStateDir}/ssh/ssh_host_ecdsa_key"
          "${giteaStateDir}/ssh/ssh_host_ed25519_key"
        ];
        OFFLINE_MODE = true;
      };

      "repository.local".LOCAL_COPY_PATH = "${giteaStateDir}/gitea/tmp/local-repo";
      "repository.upload".TEMP_PATH = "${giteaStateDir}/gitea/uploads";
      indexer.ISSUE_INDEXER_PATH = "${giteaStateDir}/gitea/indexers/issues.bleve";
      session = {
        COOKIE_SECURE = true;
        PROVIDER = "file";
        PROVIDER_CONFIG = "${giteaStateDir}/gitea/sessions";
      };
      picture = {
        AVATAR_UPLOAD_PATH = "${giteaStateDir}/gitea/avatars";
        REPOSITORY_AVATAR_UPLOAD_PATH = "${giteaStateDir}/gitea/repo-avatars";
      };
      attachment.PATH = "${giteaStateDir}/gitea/attachments";
      log = {
        MODE = "console";
        LEVEL = "Info";
        ROOT_PATH = "${giteaStateDir}/gitea/log";
      };
      security = {
        REVERSE_PROXY_LIMIT = 1;
        REVERSE_PROXY_TRUSTED_PROXIES = "*";
        PASSWORD_HASH_ALGO = "pbkdf2";
      };
      service = {
        DISABLE_REGISTRATION = true;
        REQUIRE_SIGNIN_VIEW = false;
        REGISTER_EMAIL_CONFIRM = false;
        ENABLE_NOTIFY_MAIL = false;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = false;
        ENABLE_CAPTCHA = false;
        DEFAULT_KEEP_EMAIL_PRIVATE = false;
        DEFAULT_ALLOW_CREATE_ORGANIZATION = true;
        DEFAULT_ENABLE_TIMETRACKING = true;
        NO_REPLY_ADDRESS = "noreply.localhost";
      };
      openid = {
        ENABLE_OPENID_SIGNIN = true;
        ENABLE_OPENID_SIGNUP = true;
      };
      "repository.pull-request".DEFAULT_MERGE_STYLE = "merge";
      "repository.signing".DEFAULT_TRUST_MODEL = "committer";
    };
  };

  services.postgresql = {
    package = pkgs.postgresql_14;
    dataDir = "${dataRoot}/services/gitea-postgresql-14";
  };

  services.postgresqlBackup = {
    enable = true;
    backupAll = false;
    databases = [ "gitea" ];
    location = "${dataRoot}/backups/postgresql";
    compression = "zstd";
  };

  # Seafile was removed from nixpkgs as unmaintained. Keep the upstream stack
  # declarative and pin every image to the digest currently running on chariot.
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      seafile-mysql = {
        image = "docker.io/library/mariadb@sha256:4045aba619003d93b5dc834e89e6815ba078d2cb3ff0a26f316ab5d7eab35093";
        environmentFiles = [ seafileMysqlSecretEnv ];
        environment = {
          MYSQL_LOG_CONSOLE = "true";
          MARIADB_AUTO_UPGRADE = "1";
        };
        volumes = [ "${seafileRoot}/seafile-mysql/db:/var/lib/mysql" ];
        networks = [ "seafile-net" ];
        extraOptions = [
          "--network-alias=seafile-db"
          "--health-cmd=/usr/local/bin/healthcheck.sh --connect --mariadbupgrade --innodb_initialized"
          "--health-interval=20s"
          "--health-start-period=30s"
          "--health-timeout=5s"
          "--health-retries=10"
        ];
      };

      seafile-memcached = {
        image = "docker.io/library/memcached@sha256:56a39bd5c2d5c0a656d0aca25ad5b0d8cd40b7050d2805b58a04194a16d3953b";
        entrypoint = "memcached";
        cmd = [
          "-m"
          "256"
        ];
        networks = [ "seafile-net" ];
        extraOptions = [ "--network-alias=memcached" ];
      };

      seafile = {
        image = "docker.io/seafileltd/seafile-mc@sha256:8d0dd6b682c12cb0e1d4f1f73ba223b0176e9e3d43805408a2f631706e9c10e8";
        dependsOn = [
          "seafile-mysql"
          "seafile-memcached"
        ];
        environmentFiles = [ seafileSecretEnv ];
        environment = {
          DB_HOST = "seafile-db";
          DB_PORT = "3306";
          DB_USER = "seafile";
          SEAFILE_MYSQL_DB_CCNET_DB_NAME = "ccnet_db";
          SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile_db";
          SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seahub_db";
          TIME_ZONE = "Etc/UTC";
          SEAFILE_SERVER_HOSTNAME = "drive.getthybearings.xyz";
          SEAFILE_SERVER_PROTOCOL = "https";
          SITE_ROOT = "/";
          NON_ROOT = "false";
          SEAFILE_LOG_TO_STDOUT = "false";
          ENABLE_SEADOC = "false";
          SEADOC_SERVER_URL = "https://drive.getthybearings.xyz/sdoc-server";
        };
        ports = [ "127.0.0.1:3100:80" ];
        volumes = [ "${seafileRoot}/seafile-data:/shared" ];
        networks = [ "seafile-net" ];
      };
    };
  };

  systemd.services.seafile-network = {
    description = "Create the Seafile container network";
    wantedBy = [ "multi-user.target" ];
    before = [
      "docker-seafile-mysql.service"
      "docker-seafile-memcached.service"
      "docker-seafile.service"
    ];
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    script = ''
      if ! ${pkgs.docker}/bin/docker network inspect seafile-net >/dev/null 2>&1; then
        ${pkgs.docker}/bin/docker network create seafile-net
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  systemd.services = {
    caddy.unitConfig.RequiresMountsFor = dataRoot;
    ddclient.unitConfig.RequiresMountsFor = dataRoot;
    gitea.unitConfig = {
      RequiresMountsFor = dataRoot;
      ConditionPathExists = giteaReady;
    };
    gitea-dump.unitConfig.ConditionPathExists = giteaReady;
    postgresqlBackup-gitea.unitConfig = {
      RequiresMountsFor = dataRoot;
      ConditionPathExists = giteaReady;
    };

    docker-seafile-mysql = {
      after = [ "seafile-network.service" ];
      requires = [ "seafile-network.service" ];
      unitConfig = {
        RequiresMountsFor = dataRoot;
        ConditionPathExists = [
          seafileReady
          seafileMysqlSecretEnv
        ];
      };
      serviceConfig.Restart = lib.mkForce "always";
    };
    docker-seafile-memcached = {
      after = [ "seafile-network.service" ];
      requires = [ "seafile-network.service" ];
      unitConfig = {
        RequiresMountsFor = dataRoot;
        ConditionPathExists = seafileReady;
      };
      serviceConfig.Restart = lib.mkForce "always";
    };
    docker-seafile = {
      after = [ "seafile-network.service" ];
      requires = [ "seafile-network.service" ];
      unitConfig = {
        RequiresMountsFor = dataRoot;
        ConditionPathExists = [
          seafileReady
          seafileSecretEnv
        ];
      };
      serviceConfig.Restart = lib.mkForce "always";
    };
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
    listenAddresses = [ "*:631" ];
    allowFrom = [ "all" ];
    browsing = true;
    defaultShared = true;
    openFirewall = false;
  };

  hardware.printers.ensurePrinters = [
    {
      name = "HP_LaserJet_MFP_M28-M31";
      description = "HP LaserJet MFP M28-M31";
      deviceUri = "usb://HP/LaserJet%20MFP%20M28-M31?serial=VNC6305593";
      model = "drv:///hp/hpcups.drv/hp-laserjet_mfp_m28-m31.ppd";
    }
  ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  services.fstrim.enable = true;
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  systemd.tmpfiles.rules = [
    "d '${dataRoot}/services/caddy' 0750 caddy caddy - -"
    "d '${secretRoot}' 0700 root root - -"
    "d '${dataRoot}/backups' 0750 root root - -"
  ];

  environment.systemPackages = with pkgs; [
    borgbackup
    dmidecode
    git
    smartmontools
    vim
    wget
  ];

  system.stateVersion = "26.05";
}
