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
