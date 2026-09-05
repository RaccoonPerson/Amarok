# home/kitty.nix — kitty + starship prompt, colors driven by Noctalia
#
# No colors are declared in this file on purpose: Noctalia renders its kitty
# template to ~/.config/kitty/themes/noctalia.conf at runtime (enable the
# "Kitty" template in Noctalia's settings → color scheme → templates). The
# include at the bottom pulls it in, and Noctalia hot-reloads every running
# kitty (SIGUSR1) whenever the scheme changes.

{ pkgs, ... }:

{
  #### Kitty ###################################################################

  programs.kitty = {
    enable = true;

    # font.package installs the font via home.packages automatically.
    # If Nerd Font glyphs ever render two cells wide, switch the name to
    # "FiraCode Nerd Font Mono".
    font = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font";
      size = 12;
    };

    # Shell integration without the forced beam cursor, so the block cursor
    # below actually sticks.
    shellIntegration.mode = "no-cursor";

    settings = {
      ### Look — sharp and square
      window_padding_width = 8;
      hide_window_decorations = "yes"; # suits niri; delete if you miss the titlebar in Plasma
      disable_ligatures = "cursor"; # FiraCode ligatures everywhere except under the cursor

      ### Tabs — rectangular color blocks, no powerline slants or rounds
      tab_bar_edge = "top";
      tab_bar_style = "separator";
      tab_separator = "\" \""; # plain gap between square tabs
      tab_title_template = "\" {index} {title} \""; # padding inside each block
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";
      # Active/inactive tab colors come from Noctalia's template
      # (primary / surface_variant) — don't set them here.

      ### Cursor — solid block with an animated trail
      cursor_shape = "block";
      cursor_blink_interval = "-1 ease-in-out"; # eased, animated blink
      cursor_trail = 1; # smear animation when the cursor jumps (kitty >= 0.37)
      cursor_trail_decay = "0.1 0.4";
      cursor_trail_start_threshold = 2; # only animate jumps larger than 2 cells
      # cursor_trail_color is also set by the Noctalia template.

      ### QoL
      scrollback_lines = 10000;
      enable_audio_bell = false;
    };

    keybindings = {
      "ctrl+shift+t" = "new_tab_with_cwd"; # new tab keeps the current directory
      # defaults still apply: ctrl+shift+left/right = prev/next tab,
      # ctrl+shift+q = close tab
    };

    # Noctalia's kitty apply hook looks for EXACTLY this line. If it's
    # missing, the hook tries to append it to kitty.conf itself, which fails
    # against Home Manager's read-only store symlink — so don't reword,
    # reformat, or remove it.
    extraConfig = ''
      include themes/noctalia.conf
    '';
  };

  # Make user-installed fonts visible to fontconfig.
  fonts.fontconfig.enable = true;

  #### Starship ################################################################
  # Noctalia's starship template rewrites ~/.config/starship.toml in place,
  # which can't work against a Home Manager store symlink. Instead, every
  # style below uses ANSI palette *names* — the 16-color palette is exactly
  # what Noctalia themes in kitty, so the prompt re-colors live on every
  # scheme change while staying fully declarative.
  #
  # Rule for future edits: never use hex colors in this block, or that part
  # of the prompt stops following Noctalia.

  programs.starship.settings = {
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

    username.style = "bold green";
    hostname.style = "bold green";
  };
}
