# home/racc/standalone.nix
# Entrypoint for non-NixOS machines. Built via the (currently commented)
# homeConfigurations output in flake.nix.
{ ... }:
{
  imports = [ ./common.nix ];

  # Required off NixOS: fixes XDG_DATA_DIRS so .desktop files and icons
  # from HM packages show up, and points at the right locale archive.
  targets.genericLinux.enable = true;

  fonts.fontconfig.enable = true;
}
