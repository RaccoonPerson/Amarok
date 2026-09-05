# modules/driftwm.nix
#
# driftwm (infinite-canvas Wayland compositor) with Noctalia as the shell.
#
# Needs `inputs` passed through specialArgs (specialArgs = { inherit inputs; })
# and Home Manager (used to place ~/.config/driftwm/config.toml).
# Import this from a host, e.g. hosts/lapbottom/default.nix:
#   imports = [ ../../modules/driftwm.nix ];

{ pkgs, inputs, ... }:

let
  tomlFormat = pkgs.formats.toml { };

  # Shorthand for Noctalia IPC calls. `spawn` = no loading cursor, doesn't exit fullscreen.
  noc = cmd: "spawn noctalia-shell ipc call ${cmd}";

  driftwmConfig = {
    mod_key = "super";
    focus_follows_mouse = false;
    window_placement = "auto"; # snap new windows next to whatever is in view
    focus_placement = "center";

    # Noctalia provides bar, launcher, notifications, control center, lock, OSD.
    autostart = [ "noctalia-shell" ];

    session = {
      suspend_on_close = false;
      restore_windows = true;
      restore_camera = true;
      restore_bookmarks = true;
    };

    input.keyboard = {
      layout = "us";
      repeat_rate = 30;
      repeat_delay = 250;
    };
    input.trackpad = {
      tap_to_click = true;
      natural_scroll = true;
      disable_while_typing = true;
      click_method = "clickfinger";
    };
    input.mouse.accel_profile = "flat";

    navigation.drift = 0.5;
    navigation.edge_pan.cursor_pan = false;
    zoom.reset_on_new_window = true;
    snap.gap = 12.0;

    decorations = {
      default_mode = "client";
      corner_radius = 10;
      shadow = true;
      border_width = 2;
      border_color = "#303030";
      border_color_focused = "#89b4fa";
    };

    # Built-in dot grid that pans/zooms with the canvas.
    # Set to "none" if you'd rather have Noctalia's wallpaper daemon draw the
    # background (it then stays fixed to the screen instead of scrolling).
    background.type = "default";

    keybindings = {
      # Apps
      "mod+return" = "exec-terminal"; # $TERMINAL, else foot/alacritty/kitty/...
      "mod+d" = noc "launcher toggle";
      "mod+space" = noc "launcher toggle";

      # Noctalia panels
      "mod+s" = noc "controlCenter toggle";
      "mod+n" = noc "notifications toggleHistory";
      "mod+comma" = noc "settings toggle";
      "mod+l" = noc "lockScreen toggle"; # replaces the swaylock default
      "mod+shift+e" = noc "sessionMenu toggle";

      # Windows
      "mod+q" = "close-window";
      "mod+shift+q" = "suspend-window"; # leaves a placeholder you can relaunch
      "mod+g" = "fill-window";
      "mod+shift+r" = "reload-config";

      # Keyboard resize (unbound upstream)
      "mod+ctrl+shift+right" = "grow-window right";
      "mod+ctrl+shift+left" = "shrink-window right";
      "mod+ctrl+shift+down" = "grow-window down";
      "mod+ctrl+shift+up" = "shrink-window down";

      # Media / brightness through Noctalia so its OSD shows
      "XF86AudioRaiseVolume" = noc "volume increase";
      "XF86AudioLowerVolume" = noc "volume decrease";
      "XF86AudioMute" = noc "volume muteOutput";
      "XF86AudioMicMute" = noc "volume muteInput";
      "XF86MonBrightnessUp" = noc "brightness increase";
      "XF86MonBrightnessDown" = noc "brightness decrease";
      "XF86AudioPlay" = "spawn playerctl play-pause";
      "XF86AudioNext" = "spawn playerctl next";
      "XF86AudioPrev" = "spawn playerctl previous";

      # Screenshots -> clipboard
      "Print" = "spawn grim - | wl-copy";
      "shift+Print" = "spawn grim -g \"$(slurp -d)\" - | wl-copy";
      "ctrl+Print" = "spawn driftwm msg screenshot window -o - | wl-copy";
    };

    # Defaults already cover pan/zoom/navigate gestures; the per-direction
    # 4-finger swipes below are a laptop nicety (comment out if you prefer
    # directional window jumps on 4 fingers).
    # gestures.anywhere = {
    #   "4-finger-swipe-right" = "cycle-windows forward";
    #   "4-finger-swipe-left" = "cycle-windows backward";
    # };

    outputs = [
      {
        name = "*";
        hot_corners = {
          top_left = "zoom-to-fit";
        };
      }
    ];

    window_rules = [
      {
        title = "Picture-in-Picture";
        pinned_to_screen = true;
        position = [ 0 (-300) ];
        focus_on_open = false;
      }
      {
        app_id = "steam_app_*";
        pass_keys = true;
      }
    ];
  };
in
{
  imports = [ inputs.driftwm.nixosModules.default ];

  programs.driftwm.enable = true;
  # XWayland via xwayland-satellite is on by default (programs.xwayland.enable).

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    grim
    slurp
    wl-clipboard
    playerctl
    brightnessctl
    wlr-randr
    # Uncomment if Noctalia isn't already installed by your niri module:
    # inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Screencasting / screenshots through the portal (OBS, Discord, Flameshot).
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr pkgs.xdg-desktop-portal-gtk ];
    config.driftwm.default = [ "wlr" "gtk" ];
  };

  # Drop the generated config into every Home Manager user's ~/.config/driftwm.
  # driftwm hot-reloads it when the symlink changes.
  home-manager.sharedModules = [
    {
      xdg.configFile."driftwm/config.toml".source =
        tomlFormat.generate "driftwm-config.toml" driftwmConfig;
    }
  ];
}
