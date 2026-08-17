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
    "uhci_hcd"
    "ehci_pci"
    "ata_piix"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # The OS disk is disposable. Replacements must recreate these labels.
  fileSystems."/" = {
    device = "/dev/disk/by-label/chariot-root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/chariot-boot";
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
      device = "/swapfile";
      size = 8192;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
