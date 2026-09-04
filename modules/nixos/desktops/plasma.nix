# modules/desktop.nix
# Shared by thingamajig and lapbottom. Not imported on archongrid.
{ pkgs, ... }:
{

  # Plasma 6 on Wayland. No services.xserver.enable needed; XWayland is
  # pulled in by Plasma for legacy X11 apps.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  hardware.graphics.enable = true;

  # PipeWire for audio; rtkit lets it run realtime threads.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    distrobox

    haruna

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

    kdeconnect-kde
    dolphin-plugins
  ]);

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
}
