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
- `/mnt/data/backups`: local service dumps; this is not an independent backup
- `/mnt/data/secrets/chariot`: runtime secrets that must never be added to Git
- `/mnt/data/secrets/chariot/openssh`: persistent host SSH keys

Stateful services use `RequiresMountsFor=/mnt/data`, and `/mnt/data` is needed
for boot. This prevents an absent data disk from silently redirecting writes to
the root filesystem.

## Required secrets

Create these as root-owned files with mode `0600` before activating this host:

- `ddclient-cloudflare-token`: only the Cloudflare API token
- `seafile-mysql.env`: only the existing MariaDB root password
- `seafile.env`: the Seafile application secrets below

```dotenv
# seafile-mysql.env
MYSQL_ROOT_PASSWORD=<existing MariaDB root password>

# seafile.env
DB_ROOT_PASSWD=<same existing MariaDB root password>
DB_PASSWORD=<existing Seafile database password>
JWT_PRIVATE_KEY=<existing Seafile JWT key>
INIT_SEAFILE_ADMIN_EMAIL=<existing administrator email>
INIT_SEAFILE_ADMIN_PASSWORD=<existing administrator password>
```

The `nomig` Linux password is intentionally mutable and is not stored on the
persistent disk. Set any desired password from the root installer environment
after each root filesystem replacement. SSH public-key login does not depend on
this password, but password-based `sudo` does.

Gitea's existing `SECRET_KEY`, `INTERNAL_TOKEN`, OAuth2 JWT secret, and LFS JWT
secret must be extracted respectively into `secret_key`, `internal_token`,
`oauth2_jwt_secret`, and `lfs_jwt_secret` under
`/mnt/data/services/gitea-native/gitea/conf` before its first start. This
preserves sessions, tokens, and LFS behavior without exposing their values to
the Nix store or this repository.

The migrated Gitea tree and SSH host keys must be recursively owned by numeric
UID/GID `989:989`. The explicit IDs keep ownership stable across future root
disk replacements and preserve the existing SSH host identity.

Gitea remains stopped until `/mnt/data/services/gitea-native/.nixos-ready`
exists. The Seafile containers remain stopped until their required environment
files and `/mnt/data/services/seafile/.nixos-ready` exist. Create these markers
only after the corresponding migration and verification gates have passed.

## Filesystems

The persistent disk is selected by its existing UUID. The disposable OS
filesystems must have the labels `chariot-root` and `chariot-boot`. The
persistent disk must not be formatted or relabeled.

## Migration status

Completed preparation:

- The `Chariot` configuration is wired into the flake and builds successfully.
- Hardware, BIOS boot, mounts, firewall, users, development tools, and services
  are declared.
- Host OpenSSH keys are copied to
  `/mnt/data/secrets/chariot/openssh` and referenced by NixOS.
- Seafile images are pinned to the exact digests currently running.
- Gitea and Seafile have readiness markers that prevent premature startup.
- No NixOS activation, service cutover, or disk replacement has been performed.

Outstanding blockers:

- There is no verified independent backup of Gitea or Seafile.
- Active Gitea files and PostgreSQL data still live on the root disk.
- Remaining runtime secrets have not been staged on the persistent disk.
- Gitea's upgrade from `1.25.4` to the nixpkgs version must be accepted and
  restore-tested.
- A rollback copy or retained replacement of the current root disk is required.

## Migration gates

Do not replace the root filesystem until every gate below is satisfied:

- An off-host backup contains Gitea, Seafile, database dumps, and server-side
  repository changes.
- Both database dumps have been restored successfully in an isolated test.
- File manifests and representative content hashes match their sources.
- Gitea's target tree contains the active data, not the stale
  `/mnt/data/services/gitea` copy.
- All required secrets exist with the expected ownership and permissions.
- The final maintenance-window data sync has completed with writes stopped.
- The current root disk is retained intact or has a verified restorable image.
- The 4 TB persistent disk is positively identified and excluded from every
  operating-system disk operation.

## Next steps

### 1. Preserve current server work

- Preserve the server-side `homeserver` checkout. It currently has modified
  firewall and Seafile files plus untracked CUPS configuration.
- Record current service versions, container image digests, database counts,
  repository counts, mount UUIDs, ownership, and public SSH fingerprints.
- Store that inventory with the migration backups.

### 2. Stage remaining secrets

Copy values without printing them to the terminal or placing them in Git:

| Target | Source |
| --- | --- |
| `ddclient-cloudflare-token` | Cloudflare password/token field in the active ddclient configuration |
| `seafile-mysql.env` | Existing Seafile MariaDB root password |
| `seafile.env` | Existing Seafile DB password, JWT key, and administrator values |
| Gitea `secret_key` | `SECRET_KEY` in the active Gitea `app.ini` |
| Gitea `internal_token` | `INTERNAL_TOKEN` in the active Gitea `app.ini` |
| Gitea `oauth2_jwt_secret` | OAuth2 `JWT_SECRET` in the active Gitea `app.ini` |
| Gitea `lfs_jwt_secret` | `LFS_JWT_SECRET` in the active Gitea `app.ini` |
| Gitea SSH host keys | `/data/ssh` in the active Gitea container |

- Keep files under `/mnt/data/secrets/chariot` root-owned with mode `0600`
  unless Gitea must read them directly.
- Keep secret directories mode `0700` unless an explicitly configured service
  group requires traversal.
- Treat credentials already committed to the homeserver Git history as exposed
  and rotate them after the restored services are verified.

### 3. Create independent backups

- Choose storage that is not the server's 4 TB disk.
- Produce a logical PostgreSQL dump of the active Gitea database.
- Copy active Gitea repositories, LFS objects, attachments, application data,
  application secrets, and Gitea SSH host keys.
- Produce a transactionally consistent MariaDB dump containing all three
  Seafile databases.
- Copy the complete `/mnt/data/services/seafile` tree, including the 68 GB
  Seafile object store and MariaDB directory.
- Copy the dirty server-side repository and any other wanted files from the
  current root filesystem.
- Generate manifests and hashes for the backups without modifying the sources.

### 4. Prove the backups

- Restore the Gitea PostgreSQL dump into an isolated PostgreSQL 14 instance.
- Start an isolated Gitea test against copied files and the restored database.
- Confirm the observed baseline of one user and two repositories, then test an
  HTTP clone, SSH clone, LFS object, login, and repository browsing.
- Restore the Seafile MariaDB dump and copied object store into an isolated
  Seafile stack.
- Confirm the observed baseline of 11 library records and test login, listing,
  upload, download, and representative file hashes.
- Record the restore procedure and results. A backup is not accepted until this
  gate passes.

### 5. Stage the persistent Gitea target

- Use `/mnt/data/services/gitea-native`; do not reuse or overwrite the stale
  `/mnt/data/services/gitea` tree.
- Copy the active `/home/nomig/data/gitea` content into the new target while the
  current service remains available, then plan a final cold delta sync.
- Preserve Gitea's four application secrets and three SSH host keypairs.
- Set the migrated Gitea tree to numeric ownership `989:989`.
- Prepare the PostgreSQL logical dump for restoration into
  `/mnt/data/services/gitea-postgresql-14` after NixOS initializes PostgreSQL.
- Leave `/mnt/data/services/gitea-native/.nixos-ready` absent.

### 6. Complete pre-install checks

- Rebuild and evaluate `nixosConfigurations.Chariot` from the exact revision
  selected for installation.
- Confirm the machine is still using legacy BIOS and that GRUB targets only the
  disposable operating-system disk.
- Confirm the persistent disk UUID matches `hardware-configuration.nix`.
- Confirm the future root and boot filesystems will use the labels expected by
  the configuration.
- Confirm the copied OpenSSH fingerprints match the current host.
- Confirm console or installer-root access is available to set any desired
  `nomig` Linux password.

### 7. Perform the maintenance cutover

- Announce a maintenance window and prevent new writes to Gitea and Seafile.
- Take final logical database dumps after writes have stopped.
- Perform the final Gitea filesystem delta sync and final Seafile backup sync.
- Recheck database counts, manifests, hashes, and backup readability.
- Keep both readiness markers absent.
- Proceed to operating-system replacement only after the migration gates pass
  and a separate destructive runbook has been explicitly reviewed and approved.

### 8. Complete first-boot restoration

- Verify `/mnt/data` is mounted from the expected persistent disk before
  inspecting or starting stateful services.
- Set the chosen `nomig` Linux password from the root installer environment.
- Verify the copied host OpenSSH keys are active before relying on remote access.
- Let NixOS initialize the empty PostgreSQL 14 target, then restore the verified
  Gitea logical dump.
- Verify Gitea files, secrets, SSH keys, paths, and ownership before creating
  the Gitea readiness marker.
- Verify Seafile environment files, database directory, object store, and image
  digests before creating the Seafile readiness marker.
- Start each application separately and stop the cutover if its validation
  checks fail.

### 9. Validate the migrated host

- Confirm Gitea users, repositories, HTTPS clone, SSH clone, LFS, hooks, login,
  tokens, and attachments.
- Confirm Seafile users, libraries, uploads, downloads, shares, history, and
  representative file hashes.
- Confirm Caddy certificates and both reverse proxies.
- Confirm ddclient updates only the intended DNS records.
- Confirm host SSH fingerprints, firewall policy, CUPS printing, SMART status,
  filesystem mounts, swap, timers, and local dumps.
- Monitor logs and disk growth through an agreed observation period.

### 10. Establish rollback and long-term backups

- Retain the old root disk or its verified image until the observation period
  completes.
- Keep pre-migration dumps and file backups immutable during that period.
- Configure recurring off-host backups for Gitea, PostgreSQL, Seafile MariaDB,
  and the Seafile object store.
- Define retention, restore testing, monitoring, and alerting.
- Remove stale data and old rollback material only in a later, separately
  approved cleanup step.

## Destructive phase

This document intentionally contains no formatting, installation, NixOS
activation, service-stop, or deletion commands. Those commands should be added
only to a separate cutover runbook after the migration gates and outstanding
decisions have been resolved.
