# home/racc/desktop.nix
# Layered on top of common.nix for NixOS desktops (thingamajig, lapbottom).
# Needs `inputs`, which reaches HM modules ONLY through
# home-manager.extraSpecialArgs (modules/home-manager-settings.nix).
# If that isn't imported on the host, the zen line below causes an
# infinite recursion, not a clean error.
{ inputs, pkgs, ... }:
{
  imports = [
    ./common.nix
    ./shell.nix
    ../../modules/home/vscode.nix
    inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
    # Policies, extensions, spaces, pinned tabs etc. can all be declared
    # here later. Examples:
    # https://github.com/0xc000022070/zen-browser-flake/tree/main/examples
  };

  home.packages = with pkgs; [
    # Editing / documents
    kdePackages.kate
    libreoffice-qt-stable

    # Media
    spotify

    # Chat
    discord

    distrobox

    vscode

    claude-code

    kontainer
  ];

  # Plasma settings stay imperative (System Settings) unless you add
  # plasma-manager as a flake input and import its HM module here.
}
