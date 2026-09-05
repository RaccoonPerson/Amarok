# modules/desktop/noctalia.nix
# niri (scrollable-tiling compositor) + Noctalia shell + KDE apps.
# Pair with noctalia-greeter.nix (or sddm.nix).
#
# niri, noctalia (v5), darkly and every KDE app here are in nixpkgs unstable;
# no extra flake inputs are required.
{ pkgs, lib, ... }:
{
  imports = [ ./default.nix ];

  # Besides installing niri this: registers the session with the login
  # manager, sets defaultSession = "niri", enables gnome-keyring and the
  # gnome + gtk xdg portals (screencast etc).
  programs.niri = {
    enable = true;
    useNautilus = false; # no Nautilus here; file chooser is handled below
  };

  programs.noctalia = {
    enable = true;

    # Enables NetworkManager, Bluetooth, UPower and power-profiles-daemon so
    # the wifi / bluetooth / battery / power-profile widgets all work.
    recommendedServices.enable = true;

    # Run the shell as a systemd user service instead of putting
    # `spawn-at-startup "noctalia"` in config.kdl. Bound to niri.service rather
    # than the default graphical-session.target so it won't also start if you
    # log into Plasma on the same machine.
    systemd = {
      enable = true;
      target = "niri.service";
    };
  };

  # Since Noctalia runs as a service, enable `launch_apps_as_systemd_services`
  # in its settings (Settings UI or ~/.config/noctalia/config.toml), otherwise
  # apps launched from the shell die when the service restarts.

  # ---------------------------------------------------------------------------
  # Qt / KDE theming, driven by Noctalia
  #
  # Noctalia's built-in "KColorScheme" template writes
  # ~/.local/share/color-schemes/noctalia.colors, merges it into
  # ~/.config/kdeglobals and pings running KDE apps over D-Bus every time the
  # palette or dark/light mode changes. kdeglobals is exactly what KDE's own
  # platform theme plugin (plasma-integration) reads, so pointing Qt at it
  # gives every Qt/KDE app Noctalia's colors live, with no qt6ct in between.
  # (nixpkgs only has vanilla qt6ct, not the qt6ct-kde build the Noctalia docs
  # walk through, and vanilla qt6ct can't apply KColorSchemes anyway.)
  #
  # "kde" is also what a Plasma session would pick on its own, so this is safe
  # on a host that has plasma.nix imported too.
  #
  # Turn the template on in Noctalia: Settings -> Templates -> KColorScheme,
  # or in ~/.config/noctalia/config.toml:
  #
  #   [theme.templates]
  #   enable_builtin_templates = true
  #   builtin_ids = ["kcolorscheme"]
  #
  # Don't manage ~/.config/kdeglobals from Home Manager as a store symlink —
  # Noctalia needs to write to it.
  qt = {
    enable = true;
    platformTheme = "kde"; # installs plasma-integration + kio, sets QT_QPA_PLATFORMTHEME=kde
  };

  # System-wide kdeglobals defaults. The user's ~/.config/kdeglobals (where
  # Noctalia puts the colors) layers on top and can override any of these.
  # widgetStyle picks Darkly (pkgs.darkly below); its plugin key is "Darkly".
  environment.etc."xdg/kdeglobals".text = ''
    [KDE]
    widgetStyle=Darkly

    [Icons]
    Theme=breeze
  '';

  # Use the KDE file chooser for portal-using apps (Zen, Flatpaks, ...).
  # KDE apps themselves get KIO's dialog directly from plasma-integration.
  xdg.portal = {
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.niri."org.freedesktop.impl.portal.FileChooser" = lib.mkForce "kde";
  };

  # Unlock the default KDE wallet with the login password (kdeconnect, krdc,
  # kget etc. store secrets there). kwallet-pam's autostart entry starts
  # kwalletd6 via niri's xdg-desktop-autostart.target.
  security.pam.services.login.kwallet = {
    enable = true;
    package = pkgs.kdePackages.kwallet-pam;
  };

  # Installs KDE Connect and opens the firewall ports it needs; kdeconnectd
  # autostarts through xdg-desktop-autostart, indicator lands in Noctalia's tray.
  programs.kdeconnect.enable = true;

  # Sets up the polkit helper KDE Partition Manager needs.
  programs.partition-manager.enable = true;

  environment.systemPackages =
    with pkgs;
    [
      xwayland-satellite # XWayland for niri; niri launches it on demand

      darkly # Qt6 widget style (nixpkgs builds the Qt6 half only)
      haruna # mpv-based video player
    ]
    ++ (with pkgs.kdePackages; [
      # Bits Plasma would normally provide for KDE apps
      breeze # fallback widget style, Breeze cursors
      breeze-icons # icon theme; recolors itself with the color scheme
      qqc2-desktop-style # QtQuick Controls style for Kirigami apps (kclock, kweather, ...)
      kio-extras # sftp:// smb:// mtp:// and thumbnails in Dolphin / file dialogs
      kdegraphics-thumbnailers
      ffmpegthumbs
      kwallet
      kwallet-pam
      kwalletmanager

      # Files & archives
      dolphin
      dolphin-plugins
      ark
      kfind
      filelight

      # Utilities
      konsole
      kate
      kcalc
      kcharselect
      kcolorchooser
      ksystemlog
      plasma-systemmonitor # needs ksystemstats, started on demand over D-Bus
      ksystemstats

      # Media / graphics
      gwenview
      okular
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
    ]);

  # Not carried over from plasma.nix: spectacle (needs KWin's screenshot
  # protocol) — use niri's Print binds or Noctalia's screenshot widget instead.
  #
  # Zen is GTK: if you want it themed too, add pkgs.adw-gtk3 and enable the
  # GTK 3 / GTK 4 templates in Noctalia (docs.noctalia.dev/noctalia/templates/official/gtk-qt/).
}
