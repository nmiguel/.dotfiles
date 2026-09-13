# Hardware configuration for `chariot`.
{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Disposable OS disk: ata-SAMSUNG_HD080HJ_P_S0DEJ1IL567387.
  # UUIDs match the existing NixOS installation; do not format the 4 TB disk.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c9600267-64af-4d65-b7dc-d275198f8f33";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4859-1C4D";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # This is the persistent 4 TB disk. A missing disk must stop boot rather than
  # let stateful services write into an unmounted directory on the root disk.
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/22c39105-5af0-4ffc-916a-40e3855a9214";
    fsType = "ext4";
    neededForBoot = true;
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/03ace1d9-fdd1-4c0c-bf97-c54ecb3aeec9";
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
