# modules/users.nix
{ pkgs, ... }:
{
  users.users.racc = {
    isNormalUser = true;
    description = "Racc";

    # wheel = sudo. Hosts add their own groups on top of this list.
    extraGroups = [ "wheel" ];

    shell = pkgs.fish;

    openssh.authorizedKeys.keys = [
      # "ssh-ed25519 AAAA...  racc@fedora"
    ];
  };


  # Remove if you want passwordless sudo on the desktops.
  security.sudo.wheelNeedsPassword = true;
  programs.fish.enable = true;
}
