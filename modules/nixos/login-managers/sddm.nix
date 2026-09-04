# modules/desktop/sddm.nix
# SDDM login manager on Wayland. It lists everything in
# services.displayManager.sessionPackages, so it can launch niri as well as
# Plasma. Mutually exclusive with noctalia-greeter.nix.
{ ... }:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    # plasma6 already swaps in kdePackages.sddm, the breeze theme and the
    # kwin compositor for the greeter; nothing else needed for Plasma.
    # autoNumlock = true;
  };

  # programs.niri sets defaultSession = "niri" (mkDefault). If a host has
  # both DEs installed and you want SDDM to preselect Plasma, uncomment:
  # services.displayManager.defaultSession = "plasma";
}
