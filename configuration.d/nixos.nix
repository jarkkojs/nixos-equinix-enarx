{ lib, pkgs,... }:

{
  hardware = {
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = true;
    cpu.intel.updateMicrocode = true;
  };

  boot = {
    kernelParams = [
      "dynamic_debug.verbose=1"
      "dyndbg=\"file arch/x86/kvm/* +pflmt file drivers/crypto/* +pflmt\""
    ];
    kernelPackages = let
      linux_enarx_pkg = { fetchurl, buildLinux, ... } @ args:
      buildLinux (args // rec {
        version = "6.1.0-rc4";
        modDirVersion = version;
        extraMeta.branch = lib.versions.majorMinor version;
        src = fetchGit {
          url = "https://github.com/enarx/linux.git";
          ref = "refs/heads/enarx";
          shallow = true;
        };
        kernelPatches = [];
        ignoreConfigErrors = true;
        structuredExtraConfig = with lib.kernel; {
          "64BIT" = yes;
          AMD_MEM_ENCRYPT = yes;
          AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT = no;
          CRYPTO = yes;
          CRYPTO_DEV_CCP = yes;
          CRYPTO_DEV_CCP_DD = module;
          CRYPTO_DEV_SP_CCP = yes;
          CRYPTO_DEV_SP_PSP = yes;
          DMADEVICES = yes;
          HIGH_RES_TIMERS = yes;
          KVM = yes;
          KVM_AMD = module;
          KVM_AMD_SEV = yes;
          MEMORY_FAILURE = yes;
          PCI = yes;
          RETPOLINE = yes;
          VIRTUALIZATION = yes;
          X86_MCE = yes;
        };
      } // (args.argsOverride or {}));
      linux_enarx = pkgs.callPackage linux_enarx_pkg{};
    in
      pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_enarx);
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
    tmpOnTmpfs = true;
  };

  services = {
    udev.extraRules = ''
      KERNEL=="sev", OWNER="root", GROUP="kvm", MODE="0660"
    '';
  };

  security.pam.loginLimits = [
    { domain = "@kvm"; item = "memlock"; type = "-"; value = "unlimited"; }
  ];

  networking.firewall.logRefusedConnections = false;
}
