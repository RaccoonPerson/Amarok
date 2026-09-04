# modules/home/vscode.nix

{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        leonardssh.vscord
      ];

      userSettings = {
        "chat.disableAIFeatures" = true;
        "window.autoDetectColorScheme" = true;
        "terminal.external.linuxExec" = "konsole";
        "workbench.browser.showInTitleBar" = false;
        "editor.formatOnSave" = true;

        # nix-ide
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.formatterPath" = "nixfmt";
        "nix.serverSettings".nixd.formatting.command = [ "nixfmt" ];
      };
    };
  };
}
