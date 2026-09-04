# home/racc/shell.nix
# Fish + Starship + CLI quality-of-life. Context-neutral, so common.nix
# can import it later if you want the same shell on the server / Fedora.
#
# This configures fish; it does NOT make it the login shell. That's
# system-side: programs.fish.enable = true; users.users.racc.shell = pkgs.fish;
{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -g fish_greeting
    '';

#     shellAbbrs = {
#       g = "git";
#       gs = "git status";
#       ga = "git add";
#       gc = "git commit";
#       gp = "git push";
#       cat = "bat";
#       rebuild = "sudo nixos-rebuild switch --flake ~/Desktop/Amarok";
#     };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
      directory.truncation_length = 3;
      nix_shell.format = "via [$symbol$state]($style) ";
    };
  };

  # Each has enableFishIntegration = true by default.
  # eza also defines ls / ll / la / lt aliases.
  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.zoxide.enable = true;

  home.packages = with pkgs; [
    fastfetch
    btop
  ];
}
