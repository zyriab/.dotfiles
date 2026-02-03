{ pkgs, ... }:
let
  # Wrapper script to proxy Linear MCP via stdio, reading API key from env
  linear-mcp = pkgs.writeShellScriptBin "linear-mcp" ''
    if [ -z "$LINEAR_API_KEY" ]; then
      echo "ERROR: LINEAR_API_KEY not set" >&2
      exit 1
    fi
    exec ${pkgs.mcp-proxy}/bin/mcp-proxy \
      --headers Authorization "Bearer $LINEAR_API_KEY" \
      https://mcp.linear.app/sse
  '';
in
{
  # Crush is already installed via NUR in flake.nix
  # environment.systemPackages = [ pkgs.nur.repos.charmbracelet.crush ];

  xdg.configFile."crush/crush.json".text = builtins.toJSON {
    "$schema" = "https://charm.land/crush.json";

    # LSP configuration for various languages
    lsp = {
      go = {
        command = "${pkgs.gopls}/bin/gopls";
        args = [ "serve" ];
        disabled = false;
      };
      typescript = {
        command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
        args = [ "--stdio" ];
        disabled = false;
      };
      javascript = {
        command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
        args = [ "--stdio" ];
        disabled = false;
      };
      nix = {
        command = "${pkgs.nixd}/bin/nixd";
        disabled = false;
      };
      lua = {
        command = "${pkgs.lua-language-server}/bin/lua-language-server";
        disabled = false;
      };
      rust = {
        command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
        disabled = false;
      };
      c = {
        command = "${pkgs.clang-tools}/bin/clangd";
        disabled = false;
      };
      templ = {
        command = "${pkgs.templ}/bin/templ";
        args = [ "lsp" ];
        disabled = false;
      };
      htmx = {
        command = "${pkgs.htmx-lsp}/bin/htmx-lsp";
        disabled = false;
      };
      bash = {
        command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
        args = [ "start" ];
        disabled = false;
      };
    };

    # MCP (Model Context Protocol) servers
    # Linear requires LINEAR_API_KEY env var - set per-project in flake.nix
    mcp = {
      linear = {
        type = "stdio";
        command = "${linear-mcp}/bin/linear-mcp";
      };
    };

    # Permissions
    permissions = {
      allowed_tools = [
        # File operations
        "view"
        "ls"
        "grep"
        "glob"
        "rg"
        "fzf"
        "find"

        # Git read-only operations
        "git_status"
        "git_diff"
        "git_log"

        # LSP operations
        "lsp"
      ];
    };

    # General options
    options = {
      context_paths = [
        "AGENTS.md"
        ".cursorrules"
      ];
      debug = false;
      debug_lsp = false;
      initialize_as = "AGENTS.md";
      auto_lsp = true;
    };
  };

  # Install LSP dependencies
  home.packages = with pkgs; [
    # Go
    gopls

    # TypeScript/JavaScript
    nodePackages.typescript-language-server
    nodePackages.typescript

    # Nix
    nixd

    # Lua
    lua-language-server

    # Rust
    rust-analyzer

    # C
    clang-tools

    # Templ
    templ

    # htmx
    htmx-lsp

    # MCP proxy (for Linear)
    mcp-proxy

    # Bash
    nodePackages.bash-language-server
  ];
}
