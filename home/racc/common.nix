# home/racc/common.nix
# Base home config. Must stay valid in BOTH contexts:
#   - home-manager.users.racc inside a NixOS system
#   - a standalone homeConfiguration on a non-NixOS box
# So: no `nixpkgs.config` here (rejected when useGlobalPkgs = true).
{ pkgs, ... }:
{
  # The NixOS module would default these, but standalone HM requires them.
  # Setting them explicitly is correct in both.
  home.username = "racc";
  home.homeDirectory = "/home/racc";

  home.stateVersion = "26.05";

  # Lets `home-manager` CLI manage itself in standalone mode; harmless on NixOS.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ripgrep
    fd
    jq

    nixd
    nixfmt
    statix
    deadnix
    nix-output-monitor
    nvd
    nix-tree
    manix
    nurl
  ];

  programs.git = {
    enable = true;
    settings.user.name = "racc";
    settings.user.email = "racc44@pm.me";
  };

  programs.bash.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
