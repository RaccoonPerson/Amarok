# modules/common.nix
# Imported by every host. Nothing desktop- or server-specific here.
{ pkgs, ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    # Lets racc push closures / use --target-host without sudo prompts
    # for the nix daemon.
    trusted-users = [ "root" "@wheel" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # useGlobalPkgs = true means Home Manager inherits this too.
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
  ];

  # Needed for `nixos-rebuild --target-host` from the Fedora box.
  # Key-only: add your pubkey to modules/users.nix before relying on it.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
