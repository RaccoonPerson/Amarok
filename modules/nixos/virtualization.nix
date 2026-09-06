{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.kernelModules = [ "kvm-intel" ]; # "kvm-amd" on AMD hosts
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore"; # don't resume guests that were running at shutdown
    onShutdown = "shutdown"; # shut guests down cleanly rather than saving state

    qemu = {
      package = pkgs.qemu_kvm; # host arch only; pkgs.qemu if you want cross-arch emulation
      runAsRoot = false;
      swtpm.enable = true; # emulated TPM 2.0, needed for Win11 guests
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ]; # UEFI firmware incl. secure-boot variants
      };
      vhostUserPackages = [ pkgs.virtiofsd ]; # host<->guest shared folders
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  programs.virt-manager.enable = true;
  programs.dconf.enable = true; # virt-manager stores its settings in dconf

  users.users.racc.extraGroups = [
    "libvirtd"
    "kvm"
  ];

  environment.systemPackages = with pkgs; [
    virt-viewer # lightweight SPICE/VNC client, handy without the full GUI
    spice-gtk
    spice-protocol
    swtpm
    libguestfs # virt-cat, virt-df, guestmount
    dnsmasq # libvirt's default NAT network needs this
    bridge-utils
    adwaita-icon-theme # virt-manager renders with broken icons without it
  ];
}
