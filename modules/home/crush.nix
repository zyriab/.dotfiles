{ ... }:
{
  programs.crush = {
    enable = true;
    settings = {
      lsp = {
        go = {
          enabled = true;
          command = "gopls";
          args = [ "--remote=auto" ];
        };
        nix = {
          enabled = true;
          command = "nixd";
        };
        typescript = {
          enabled = true;
          command = "typescript-language-server";
          args = [ "--stdio" ];
        };
      };
      options = {
        context_paths = [ "/etc/nixos/configuration.nix" ];
        tui.compact_mode = true;
        debug = false;
      };
    };
  };
}
