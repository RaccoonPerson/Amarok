{ pkgs, ... }:
{
  gtk = {
    enable = true;

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus"; # or "Papirus" / "ePapirus-Dark"
    };

    font = {
      package = pkgs.inter;
      name = "Inter";
      size = 11;
    };

    # adw-gtk3 is what noctalia's GTK template themes on top of
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };

    gtk3.extraConfig = {
      gtk-decoration-layout = ":"; # no min/max/close on CSD apps
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-decoration-layout = ":";
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # libadwaita / portal-driven apps read these instead of settings.ini
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      icon-theme = "Papirus-Dark";
      gtk-theme = "adw-gtk3-dark";
      font-name = "Inter 11";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
      color-scheme = "prefer-dark";
    };
    "org/gnome/desktop/wm/preferences".button-layout = ":";
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
