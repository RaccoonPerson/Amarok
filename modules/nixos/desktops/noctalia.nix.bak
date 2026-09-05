# modules/desktop/noctalia.nix
# niri (scrollable-tiling compositor) + Noctalia shell + GNOME apps.
# Pair with noctalia-greeter.nix (or sddm.nix).
#
# niri, noctalia (v5) and all the GNOME apps are in nixpkgs unstable, so no
# extra flake inputs are required.
{ pkgs, ... }:
{
  imports = [ ./default.nix ];

  # Besides installing niri this: registers the session with the login
  # manager, sets defaultSession = "niri", enables gnome-keyring and the
  # gnome + gtk xdg portals (screencast, Nautilus file picker).
  programs.niri.enable = true;

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
  #
  # Bits you still want in ~/.config/niri/config.kdl
  # (https://docs.noctalia.dev/noctalia/compositor-settings/niri/):
  #
  #   binds {
  #     Mod+Space { spawn-sh "noctalia msg panel-toggle launcher"; }
  #     Mod+S     { spawn-sh "noctalia msg panel-toggle control-center"; }
  #     Mod+Comma { spawn-sh "noctalia msg settings-toggle"; }
  #     XF86AudioRaiseVolume { spawn-sh "noctalia msg volume-up"; }
  #     XF86AudioLowerVolume { spawn-sh "noctalia msg volume-down"; }
  #     XF86AudioMute        { spawn-sh "noctalia msg volume-mute"; }
  #   }
  #   debug { honor-xdg-activation-with-invalid-serial }
  #   layer-rule { match namespace="^noctalia-backdrop"; place-within-backdrop true; }

  # Space-bar previews in Nautilus.
  services.gnome.sushi.enable = true;

  environment.systemPackages = with pkgs; [
    xwayland-satellite # XWayland for niri; niri launches it on demand

    # GNOME apps
    nautilus # files
    file-roller # archives
    showtime # video player (GStreamer); celluloid if you'd rather have mpv
    decibels # audio player
    loupe # image viewer
    papers # PDF / document viewer
    snapshot # camera
    ptyxis # terminal, container-aware so it pairs nicely with distrobox
    gnome-text-editor
    gnome-calculator
    gnome-clocks
    gnome-weather
    gnome-characters
    gnome-font-viewer
    gnome-disk-utility
    gnome-system-monitor
    baobab # disk usage
    gnome-logs # journal viewer
    simple-scan # scanner
    gnome-connections # RDP / VNC client
    drawing # simple paint app

  ];
}
