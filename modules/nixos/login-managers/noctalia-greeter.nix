# modules/desktop/noctalia-greeter.nix
# greetd + Noctalia Greeter. Shows every session in
# services.displayManager.sessionPackages (niri, Plasma, ...), so it works with
# either DE module. Mutually exclusive with sddm.nix.
#
# noctalia-greeter and its module are in nixpkgs unstable; no flake input needed.
{ pkgs, ... }:
{
  # Enables greetd, polkit and accounts-daemon (user avatars in the picker), and
  # points greetd's default_session.command at noctalia-greeter-session.
  services.displayManager.noctalia-greeter = {
    enable = true;

    # Optional: use the same cursor as in-session.
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };

    # Written to /var/lib/noctalia-greeter/greeter.toml on every activation.
    # Full key list: https://docs.noctalia.dev/greeter/configuration/
    settings = {
      # Preselected session. Must be the desktop entry's Name= (what
      # `noctalia-greeter sessions` prints), e.g. "niri" or "Plasma (Wayland)".
      # Unknown names are ignored, so this is safe on a Plasma-only host too.
      session.default = "niri";
      keyboard.layout = "us";
      # user.default = "racc"; # skip the user list, go straight to the password step
      # idle.timeout = 300;    # blank the screen after N seconds on the greeter
    };

    # Extra flags for noctalia-greeter-session, e.g. [ "--user" "racc" ].
    # extraArgs = [ ];
  };

  # greetd's PAM stack includes `login`; this unlocks gnome-keyring with the
  # login password so niri/GNOME apps don't prompt for it again.
  security.pam.services.login.enableGnomeKeyring = true;

  # Wallpaper/palette sync from Noctalia (Settings -> Security -> Sync Now) goes
  # through polkit; enable Noctalia's built-in polkit agent in the same menu.
}
