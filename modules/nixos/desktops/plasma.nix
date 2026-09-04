# modules/desktop/plasma.nix
# KDE Plasma 6 on Wayland + KDE apps. Pair with sddm.nix (or noctalia-greeter.nix).
{ pkgs, ... }:
{
  imports = [ ./default.nix ];

  # No services.xserver.enable needed; XWayland is pulled in by Plasma for
  # legacy X11 apps.
  services.desktopManager.plasma6.enable = true;

  # Installs KDE Connect and opens the firewall ports it needs.
  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs; [
    haruna # mpv-based video player
  ] ++ (with pkgs.kdePackages; [
    (spectacle.override {
      tesseractLanguages = [ "eng" ];
    })

    # Utilities
    konsole
    kcalc
    kate
    kfind
    filelight
    kcharselect
    kcolorchooser
    ksystemlog

    # Camera / graphics
    kamoso
    kolourpaint
    skanpage

    # Everyday
    kclock
    kweather

    # Network
    kget
    krdc
    krfb

    partitionmanager
    dolphin-plugins
  ]);
}
