# modules/users.nix
{ pkgs, ... }:
{
  users.users.racc = {
    isNormalUser = true;

    extraGroups = [ "wheel" ];

    shell = pkgs.fish;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLqP4Sd3ZoiSO+hY+Ky/og/oJxSxbj9ZFG6c23qt6VR racc44@pm.me"
    ];
  };


  # Remove if you want passwordless sudo on the desktops.
  security.sudo.wheelNeedsPassword = true;
  programs.fish.enable = true;
}
