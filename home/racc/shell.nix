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
      nix_shell.format = "via [$symbol$state]($style) ";

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold yellow)";
      };

      directory = {
        style = "bold blue";
        truncation_length = 4;
      };

      git_branch.style = "bold magenta";
      git_status.style = "bold red";
      cmd_duration.style = "yellow";

      nix_shell = {
        symbol = " "; # Nerd Font nix glyph — works now that FiraCode NF is installed
        style = "bold cyan";
      };

      username = {
        style_user = "bold green";
        style_root = "bold red";
      };
    };
  };

  # Each has enableFishIntegration = true by default.
  # eza also defines ls / ll / la / lt aliases.
  programs.eza.enable = true;
  programs.bat.enable = true;
  # programs.fzf.enable = true;
  programs.zoxide.enable = true;

  home.packages = with pkgs; [
    fastfetch
    btop
  ];
}
