# Chariot

`Chariot` is a headless NixOS homeserver configuration. Its network hostname
remains the conventional lowercase `chariot`. The root disk is disposable;
service data, service secrets, and local backups live under `/mnt/data` on the
existing 4 TB ext4 filesystem.

## Persistent contract

- `/mnt/data/services/gitea-native`: Gitea files and repositories
- `/mnt/data/services/gitea-postgresql-14`: Gitea PostgreSQL cluster
- `/mnt/data/services/seafile`: existing Seafile data and MariaDB directories
- `/mnt/data/services/caddy`: Caddy account and certificate state
- `/mnt/data/services/media`: Jellyfin, Seerr, Radarr, Prowlarr, Bazarr,
  Transmission, and Sonarr state
- `/mnt/data/Media`: movies and shows, copied from Tower without deleting the
  source library
- `/mnt/data/backups`: local service dumps; this is not an independent backup
- `/mnt/data/secrets/chariot`: runtime secrets that must never be added to Git
- `/mnt/data/secrets/chariot/openssh`: persistent host SSH keys

Stateful services use `RequiresMountsFor=/mnt/data`, and `/mnt/data` is needed
for boot. This prevents an absent data disk from silently redirecting writes to
the root filesystem.

## Required secrets

Create these as root-owned files with mode `0600` before activating this host:

- `ddclient-cloudflare-token`: only the Cloudflare API token
- `seafile-mysql.env`: only the MariaDB root password
- `seafile.env`: the Seafile application secrets below

```dotenv
# seafile-mysql.env
MYSQL_ROOT_PASSWORD=<MariaDB root password>

# seafile.env
DB_ROOT_PASSWD=<same MariaDB root password>
DB_PASSWORD=<Seafile database password>
JWT_PRIVATE_KEY=<Seafile JWT key>
```

The `INIT_SEAFILE_ADMIN_*` variables are needed only when initializing a new
instance. Do not retain an administrator password in the environment after the
administrator exists in the database.

The first local console automatically logs in as `nomig`; system services start
at boot independently of that session. The `nomig` Linux password remains
mutable and is not stored on the persistent disk. SSH public-key login and
console autologin do not depend on this password, but password-based `sudo`
does.

Gitea's generated `SECRET_KEY`, `INTERNAL_TOKEN`, OAuth2 JWT secret, and LFS JWT
secret live respectively in `secret_key`, `internal_token`,
`oauth2_jwt_secret`, and `lfs_jwt_secret` under
`/mnt/data/services/gitea-native/gitea/conf`. They remain outside the Nix store
and this repository. The Gitea tree is owned by numeric UID/GID `989:989`; the
explicit IDs keep ownership stable across future root-disk replacements.

Gitea remains stopped until `/mnt/data/services/gitea-native/.nixos-ready`
exists and all four application secrets are non-empty.
All three Seafile containers share one gate: both secret environment files,
both data directories, and `/mnt/data/services/seafile/.nixos-ready` must exist.
The media stack remains stopped until
`/mnt/data/services/media/.nixos-ready` exists. Keep this marker absent while an
initial or final media/configuration synchronization is in progress.
Create a marker only after the corresponding recovery checks have passed.

## Filesystems and boot

The installed machine boots in UEFI mode with systemd-boot. The current
filesystem identifiers, recorded in `hardware-configuration.nix`, are:

| Purpose | Hardware | Filesystem UUID |
| --- | --- | --- |
| EFI system partition | Samsung 80 GB, partition 1 | `4859-1C4D` |
| Disposable root | Samsung 80 GB, partition 2 | `c9600267-64af-4d65-b7dc-d275198f8f33` |
| Swap partition | Samsung 80 GB, partition 3 | `03ace1d9-fdd1-4c0c-bf97-c54ecb3aeec9` |
| Persistent data | Seagate 4 TB, partition 1 | `22c39105-5af0-4ffc-916a-40e3855a9214` |

The data-disk UUID must always be verified before disk maintenance. It must not
be formatted or relabeled. Its stable identifier is
`/dev/disk/by-id/ata-ST4000VN006-3CW104_WW690B4Y`; the disposable disk is
`/dev/disk/by-id/ata-SAMSUNG_HD080HJ_P_S0DEJ1IL567387`. A future root-disk
replacement will produce new root, EFI, and swap UUIDs, which must be updated
before building that install.

## Runtime model

Caddy, ddclient, Gitea, PostgreSQL, printing, SSH, monitoring, Jellyfin, Seerr,
Radarr, Prowlarr, Bazarr, Transmission, Sonarr, and FlareSolverr run as native
NixOS services. Seafile Server and Seahub were removed from nixpkgs as
unmaintained, so Seafile 12 remains the one OCI workload. NixOS still declares
its exact images, systemd units, dependencies, network, secrets, loopback-only
port, and persistent mounts. Replacing that image with a private native package
would add an unsupported application build and a database migration to this
recovery; test such a change separately against restored copies.

## Current recovery status

The pre-install plan was overtaken by the NixOS installation on 2026-09-12.
Observed after boot:

- UEFI/systemd-boot, root, EFI, swap, and `/mnt/data` are active on the UUIDs
  above; the persistent filesystem passed its boot-time check.
- Caddy, Docker, PostgreSQL, and SSH start successfully.
- Public DNS, router forwarding, the host firewall, TLS, and Caddy are working.
- Seafile, MariaDB, and memcached were authorized and started on 2026-09-12.
  MariaDB reported that no upgrade was required, all three containers remained
  active without restarts, and the database contained 11 repositories with 11
  owners after startup. The public login, API ping, and fileserver protocol
  endpoints returned successful responses.
- Before startup, `/mnt/data/services/seafile` was copied read-only to
  `tower:/home/nomig/chariot-recovery-2026-09-12/seafile-prestart.tar.zst`.
  The 70,419,283,599-byte archive passed zstd and tar validation; its SHA-256 is
  `6b46cda719a4147234d7a2f097cb898330bbc541afc119d71b02f9169a2e07c9`.
- The MariaDB root password, Seafile database password, and Seafile JWT key were
  rotated on 2026-09-13. Both old database credentials are rejected, the admin
  bootstrap variables are absent from the runtime environment, all three public
  endpoints return HTTP 200, and the database still contains 11 repositories.
  The pre-rotation logical dump was copied to
  `tower:/home/nomig/chariot-recovery-2026-09-12/seafile-credential-rotation-backup/pre-credential-rotation-2026-09-13.tar`.
  Its embedded SQL matches the server copy at SHA-256
  `33454f4cc409b6a6900abc6643826a7ab82dd7142b58b03b172481d982f5928d`;
  the archive SHA-256 is
  `2f9a0a6a2578fc3f84316d276a324a1a3ca9b553db4d65c64cdb38e80d870e8e`.
- The old Gitea tree and PostgreSQL database were lost when NixOS replaced the
  previous root filesystem. A fresh native Gitea `1.27.3` instance now serves
  HTTPS only. The `nmiguel` administrator and two private repositories were
  rebuilt from the surviving local clones. Fresh HTTPS clones passed `git fsck`
  and matched `homeserver/main` at `62a98b5` and `Bank-Parser/master` at
  `fdae9c8`; old issues, tokens, hooks, attachments, settings, and other database
  metadata could not be recovered.
- The native Gitea and PostgreSQL backup jobs completed successfully. Their
  outputs were copied to
  `tower:/home/nomig/chariot-recovery-2026-09-12/gitea-native-backups` and
  restore-tested: both archived repositories passed `git fsck`, while the SQL
  restored into isolated PostgreSQL 14 with two repository rows and one user.
  The Gitea archive SHA-256 is
  `db7730842cdf4df3f11e5fbe061ba3d572be18ac7c542b52a411ddc1d7482648`;
  the PostgreSQL archive SHA-256 is
  `ea22679a2cb219b5ccc1c0f6cb73e52fdbe0b35d3ee46563b8fc1f833a4fdb10`.
- The ddclient token and Seafile environment files are staged outside Git.
  ddclient updates the apex, wildcard, `www`, and `drive` records. `git` resolves
  through the Cloudflare-proxied wildcard because Gitea exposes HTTPS only.
- The active Cloudflare token also appears in Fish history and in an OpenCode
  session from 2026-08-04 that used the OpenAI provider. This is third-party
  disclosure even though the private Gitea repository is not anonymously
  accessible. Replace the token and revoke the current value.
- The currently served SSH Ed25519 host key matches the key accepted before
  this recovery. Automatic replacement-key generation is disabled in NixOS.

## Unresolved gates

- Gitea and PostgreSQL need recurring off-host backups with restore tests. The
  surviving local clones and recovery archives preserve Git history but not the
  lost application metadata.
- Seafile still needs authenticated, application-level validation of library
  contents, representative hashes, upload, download, sharing, history, and
  client synchronization before the recovery is considered fully accepted.
- Confirm that the temporary Gitea bootstrap password was changed. Its local
  recovery copy is no longer present.
- The administrator value committed for Seafile no longer matches any current
  administrator hash; its current plaintext value is intentionally unavailable.
- Replace and revoke the active Cloudflare token because it was retained in
  shell and OpenCode history and sent through an OpenAI-backed session. The
  committed Seafile database credentials and JWT key are already rotated.

## Recovery order

### 1. Preserve data

- Take an off-host copy of `/mnt/data/services/seafile` before starting its
  MariaDB container. The container has automatic MariaDB upgrade enabled.
- Preserve the surviving Gitea clones and incomplete persistent tree; the old
  root filesystem and its PostgreSQL database are no longer recoverable.
- Record file manifests, representative content hashes, ownership, image
  digests, database counts, user counts, library counts, and repository counts.

Local dumps under `/mnt/data/backups` are useful for recovery history but are
not independent backups because they share the production disk.

### 2. Stage runtime secrets

Copy values from a secure source directly to their persistent targets without
printing them or placing an intermediate file in this checkout:

| Target | Required content |
| --- | --- |
| `ddclient-cloudflare-token` | Only a least-privilege Cloudflare API token |
| `seafile-mysql.env` | `MYSQL_ROOT_PASSWORD` |
| `seafile.env` | The three Seafile variables documented above |
| Gitea `gitea/conf/*_secret` files | The four persistent application secrets |

Secret directories must be root-owned mode `0700`; standalone secret files
must be root-owned mode `0600`. Gitea-owned files must remain readable by UID
and GID `989` without becoming public. NixOS checks that every required file is
non-empty but deliberately does not create any secret.

### 3. Recover Seafile

- Verify the MariaDB and Seafile directories against the preserved inventory.
- Verify both environment files are non-empty and contain only the expected
  assignments.
- Create `/mnt/data/services/seafile/.nixos-ready` only after accepting the
  first-start upgrade risk.
- Start `docker-seafile-mysql.service` and wait for Docker health to report
  `healthy` before starting the application. The NixOS application unit also
  enforces this wait with a five-minute timeout.
- Start `docker-seafile-memcached.service` and `docker-seafile.service`.
- Validate login, library listing, upload, download, sharing, history, client
  synchronization, and representative hashes before accepting new writes.

Creating a marker does not start a previously skipped unit. Removing a marker
does not stop a running unit; stop the units explicitly before removing it.

### 4. Recover Gitea

The old root filesystem was overwritten before its active Gitea state was
preserved. The accepted fallback was a fresh native instance populated from the
two surviving clones. Keep the incomplete `/mnt/data/services/gitea` tree only
as a recovery artifact; do not merge it into the active tree. Validate login,
HTTPS clone and push, repository visibility, hooks, and backups after future
changes. Gitea's built-in SSH server is intentionally disabled.

### 5. Enable dynamic DNS last

- Reconcile the configured apex, wildcard, `www`, and `drive` records with
  Cloudflare first. Gitea's `git` hostname uses the proxied wildcard.
- Stage the token, start ddclient, and confirm that it changes only the intended
  records. There is no IPv6 update configured.

## Long-term work

- Add recurring off-host backups for Gitea, PostgreSQL, Seafile MariaDB, and
  the Seafile object store, with retention and periodic restore tests.
- Keep credentials out of future commits and remove them from shell commands and
  AI tool arguments. Rotate the retained Cloudflare token.
- Treat Caddy journals and access logs as sensitive. NixOS redacts the custom
  `Seafile-Repo-Token` request header in both runtime errors and Drive access
  logs, but old journal entries can still contain it.
- Keep the exact Seafile image digests fixed until backup and restore tests pass.
- Prototype a native Seafile package only against isolated restored data; it is
  a maintained packaging project, not a safe in-place configuration switch.
