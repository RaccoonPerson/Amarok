# modules/desktop/default.nix
# Base for every Wayland desktop. Shared by thingamajig and lapbottom, not
# imported on archongrid.
#
# The DE modules (plasma.nix, noctalia.nix) import this themselves, so a host
# only needs to import one DE module plus one login manager module
# (sddm.nix or noctalia-greeter.nix).
{ pkgs, lib, ... }:
{
  hardware.graphics = {
    enable = true;
    # enable32Bit = true; # 32-bit GL for Wine etc. (programs.steam turns this on by itself)
  };

  # PipeWire for audio; rtkit lets it run realtime threads.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Plumbing every compositor/DE expects to be there.
  security.polkit.enable = true; # privilege prompts; each DE brings its own agent
  programs.dconf.enable = true; # settings backend for GTK/GNOME apps
  services.udisks2.enable = true; # removable media
  services.gvfs.enable = true; # trash, MTP, smb:// etc. in file managers
  services.upower.enable = lib.mkDefault true;
  networking.networkmanager.enable = lib.mkDefault true;
  hardware.bluetooth = {
    enable = lib.mkDefault true;
    powerOnBoot = lib.mkDefault true;
  };

  # Electron/Chromium apps run natively on Wayland instead of through XWayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # xdg-desktop-portal is configured by the DE modules (plasma6 -> kde portal,
  # niri -> gnome + gtk portals), so nothing to do here.

  environment.systemPackages = with pkgs; [
    wl-clipboard # wl-copy / wl-paste

    distrobox

    hunspell
    hunspellDicts.en_US-large

    atool
    xarchiver
    unrar
    p7zip
    zip
    unzip
    pigz
    pixz
    plzip
    cpio
  ];

  fonts.packages = with pkgs; [
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # services.printing.enable = true;
  # services.fwupd.enable = true;
}
