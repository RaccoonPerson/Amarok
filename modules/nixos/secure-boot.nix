# modules/secure-boot.nix
# Import only after `sbctl create-keys` has populated /var/lib/sbctl on
# the target. Until then the build fails at bootloader installation.
{ pkgs, lib, inputs, ... }:
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  environment.systemPackages = [ pkgs.sbctl ];

  # Lanzaboote replaces systemd-boot's installer; both enabled = conflict.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
}
