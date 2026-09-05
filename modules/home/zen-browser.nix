# home/zen-browser.nix
# Zen Browser via github:0xc000022070/zen-browser-flake.
#
# Needs `inputs` in Home Manager's extraSpecialArgs (the usual
# `extraSpecialArgs = { inherit inputs; }` in the flake).
{
  inputs,
  config,
  pkgs,
  ...
}:
let
  # AMO "latest" endpoint; the key is the extension ID, the value the AMO slug.
  mkExtensions = builtins.mapAttrs (_: slug: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
    installation_mode = "force_installed";
  });

  # ---------------------------------------------------------------------------
  # Noctalia theming. Noctalia's community "zen-browser" template is two CSS
  # files with palette tokens in them. Its own apply.sh wants to rewrite
  # userChrome.css / user.js inside the profile, which are Home Manager store
  # symlinks here, so instead the CSS is pinned from the community-templates
  # repo, registered as a Noctalia *user* template with no hook, and Zen's
  # userChrome/userContent just @import the rendered output.
  communityTemplatesRev = "83808b68b035146d974283042bca4774379bebcc";
  zenCss =
    name: hash:
    pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/noctalia-dev/community-templates/${communityTemplatesRev}/zen-browser/${name}";
      inherit hash;
    };
  zenUserChrome = zenCss "zen-userChrome.css" "sha256-boEvqfWwGkvHawczMtBhDsr2az+MOeKi9dHYZj1Nm14=";
  zenUserContent = zenCss "zen-userContent.css" "sha256-dMlYPj9WgFZw64Bh0r7sE3n/StfMy8FCNhyQmZSG9BI=";
  noctaliaZenDir = "${config.xdg.cacheHome}/noctalia/zen-browser";
in
{
  imports = [ inputs.zen-browser.homeModules.beta ]; # or .twilight

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    # policies.json — enforced, not changeable from the browser.
    policies = {
      DisableAppUpdate = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;

      # No built-in password manager or autofill of any kind.
      PasswordManagerEnabled = false; # also hides about:logins and password generation
      OfferToSaveLogins = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisableFormHistory = true; # no remembered form entries / search history in fields

      ExtensionSettings = mkExtensions {
        "uBlock0@raymondhill.net" = "ublock-origin";
        "sponsorBlocker@ajay.app" = "sponsorblock";
        "myallychou@gmail.com" = "youtube-recommended-videos"; # Unhook
        "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = "return-youtube-dislikes";
        "{ddc62400-f22d-4dd3-8b4a-05837de53c2e}" = "read-aloud"; # Read Aloud (LSD Software)
        "addon@darkreader.org" = "darkreader";
        "78272b6fa58f4a1abaac99321d503a20@proton.me" = "proton-pass";
      };
    };

    profiles.default = {
      # If you already have a Zen profile you want to keep, point at it:
      # path = "abcd1234.Default (release)";  # directory name under ~/.config/zen

      # Betterfox's Zen preset (BetterZen). Applied with mkDefault, so
      # anything in `settings` below wins over it.
      presets.betterfox.enable = true;

      settings = {
        # No container tabs at all (removes Personal/Work/Banking/Shopping
        # and the "open in container" UI).
        "privacy.userContext.enabled" = false;
        "privacy.userContext.ui.enabled" = false;

        # Belt and braces next to the policies above.
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "signon.generation.enabled" = false;
        "signon.firefoxRelay.feature" = "disabled";
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # Go through xdg-desktop-portal for the file picker (KDE dialog, per
        # noctalia.nix) and for the light/dark preference, which is what
        # makes `prefers-color-scheme` in the Noctalia CSS track its mode.
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.settings" = 1;

        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "zen.welcome-screen.seen" = true;
      };

      # https://zen-browser.app/mods/<uuid>
      mods = [
        "c6813222-6571-4ba6-8faf-58f3343324f6" # Disable Rounded Corners
        "b51ff956-6aea-47ab-80c7-d6c047c0d510" # Disable Status Bar
        "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
        "35f24f2c-b211-43e2-9fe4-2c3bc217d9f7" # Compact Tabs Titles
      ];

      search = {
        force = true; # search.json.mozlz4 is otherwise never touched again
        default = "brave";
        privateDefault = "brave";
        order = [ "brave" ];
        engines.brave = {
          name = "Brave Search";
          urls = [ { template = "https://search.brave.com/search?q={searchTerms}"; } ];
          definedAliases = [ "@brave" ];
        };
      };

      # Noctalia palette (see the note at the top). Firefox only reads these
      # at startup, so palette changes show up after a Zen restart.
      userChrome = ''
        @import "${noctaliaZenDir}/zen-userChrome.css";
      '';
      userContent = ''
        @import "${noctaliaZenDir}/zen-userContent.css";
      '';
    };
  };

  # Noctalia autoloads every *.toml in ~/.config/noctalia, so this fragment
  # registers the two templates without touching config.toml.
  xdg.configFile."noctalia/zen-browser.toml".text = ''
    # Managed by Home Manager (home/zen-browser.nix). Renders Noctalia's
    # community Zen Browser CSS with the current palette; no post_hook, the
    # outputs are @imported from Zen's userChrome.css / userContent.css.
    [theme.templates.user.zen_browser_chrome]
    input_path = "${zenUserChrome}"
    output_path = "${noctaliaZenDir}/zen-userChrome.css"

    [theme.templates.user.zen_browser_content]
    input_path = "${zenUserContent}"
    output_path = "${noctaliaZenDir}/zen-userContent.css"
  '';
}
