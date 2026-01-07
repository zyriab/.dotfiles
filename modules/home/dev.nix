{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  isX86 = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
in
{
  programs.go.enable = true;

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
        tui = {
          compact_mode = true;
        };
        debug = false;
      };
    };
  };

  home.packages =
    with pkgs;
    [
      # CLI tools
      inputs.claude-code.packages.${stdenv.hostPlatform.system}.default
      cloc

      # Languages & runtimes
      nodejs
      lua
      luarocks
      cargo

      # Compilers & build tools
      gcc
      gnumake
      pkg-config
      glibc
      libconfig

      # Formatters & linters
      gofumpt
      golines
      golangci-lint
      stylua
      prettierd

      # Nix
      nixd
      nixfmt-rfc-style
      nixfmt-tree
      nix-search-cli

      # Networking/tunnels/VPS
      cloudflared
      hcloud

      # IDEs
      (jetbrains.datagrip.override {
        vmopts = ''
          -Dsun.java2d.uiScale=2.0
          -Dawt.toolkit.name=WLToolkit
        '';
      })

    ]
    # x86-only packages
    ++ lib.optionals isX86 [
      inputs.opencode.packages.${stdenv.hostPlatform.system}.default
      postman
      ngrok
    ];
}
