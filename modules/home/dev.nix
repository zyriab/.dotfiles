{ pkgs, lib, ... }:
let
  isX86 = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
in
{
  programs.go.enable = true;

  home.packages =
    with pkgs;
    [
      # CLI tools
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
      nixfmt
      nixfmt-tree
      nix-search-cli

      # Networking/tunnels/VPS
      cloudflared
      hcloud

      # IDEs
      (jetbrains.datagrip.override {
        vmopts = ''
          -Dsun.java2d.uiScale=1.8
          -Dawt.toolkit.name=WLToolkit
        '';
      })

    ]
    # x86-only packages
    ++ lib.optionals isX86 [
      postman
      ngrok
    ];
}
