{ pkgs, ... }:
let
  anthropic-api-key = pkgs.callPackage ../../pkgs/anthropic-api-key.nix { };
in
{
  home.packages = [ anthropic-api-key ];

  programs.crush = {
    enable = true;
    settings = {
      providers = {
        anthropic = {
          type = "anthropic";
          api_key = "Bearer $(anthropic-api-key)";
          extra_headers = {
            "anthropic-version" = "2023-06-01";
            "anthropic-beta" = "oauth-2025-04-20";
          };
          system_prompt_prefix = "You are Claude Code, Anthropic's official CLI for Claude.";
        };
      };
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
