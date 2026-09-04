# hosts/lapbottom/default.nix
{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    # ../../modules/noctalia.nix

    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager

    ../../modules/nixos/common.nix
    ../../modules/nixos/desktops/plasma.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/home-manager-settings.nix

    # Keep commented for the initial install -- lanzaboote fails to build
    # until sbctl keys exist on the target. Uncomment at INSTALL.md step 7.
    # ../../modules/secure-boot.nix
  ];

  networking.hostName = "lapbottom";

  networking.networkmanager.enable = true;

  # ---- Boot ----------------------------------------------------------------

  # Plain systemd-boot for the initial install. secure-boot.nix mkForce's
  # this off and swaps in lanzaboote once it's imported.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # systemd stage-1: required for TPM2 unlock via systemd-cryptenroll, and
  # the better-supported initrd for LUKS + lanzaboote generally.
  boot.initrd.systemd.enable = true;

  # Newest kernel. The NPU flag from nixos-generate-config means recent
  # Intel silicon, which is exactly where LTS lags on drivers.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.plymouth.enable = true;
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "udev.log_level=3"
    "rd.systemd.show_status=false"
  ];
  boot.initrd.kernelModules = [ "xe" ];

  # ---- Laptop --------------------------------------------------------------

  services.thermald.enable = true;
  services.power-profiles-daemon.enable = true;
  services.fwupd.enable = true;
  hardware.bluetooth.enable = true;

  # tpm2-tss + udev rules; needed for systemd-cryptenroll to see the TPM.
  security.tpm2.enable = true;

  # ---- User ----------------------------------------------------------------

  # Merges with the [ "wheel" ] in modules/users.nix.
  users.users.racc.extraGroups = [
    "networkmanager"
    "video"
  ];

  home-manager.users.racc = import ../../home/racc/desktop.nix;

  system.stateVersion = "26.05";
}
