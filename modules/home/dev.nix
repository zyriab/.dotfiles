{ pkgs, inputs, ... }:
{
  programs.go.enable = true;

  home.packages = with pkgs; [
    # CLI tools
    inputs.claude-code.packages.${stdenv.hostPlatform.system}.default

    # Testing
    inputs.opencode.packages.${stdenv.hostPlatform.system}.default
    postman

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
    nix-search-cli

    # Networking/tunnels
    ngrok
    cloudflared
  ];
}
