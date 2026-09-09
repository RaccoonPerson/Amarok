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
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/swtpm-localca 0750 tss tss - -"
  ];

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
