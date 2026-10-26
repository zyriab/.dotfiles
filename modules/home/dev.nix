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

      # Go tooling
      templ

      # Nix
      nixd
      nixfmt
      nixfmt-tree
      nix-search-cli

      # Networking/tunnels/VPS
      cloudflared
      hcloud

      # CAD + 3D printing
      openscad-unstable
      cura-appimage

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

  # Force Cura to use the GTK3 platform theme so open a file doesn't crash the app.
  # Overrides the .desktop shipped with cura-appimage.
  xdg.desktopEntries.cura = {
    name = "UltiMaker Cura";
    genericName = "3D Printing Software";
    comment = "Cura converts 3D models into paths for a 3D printer.";
    icon = "cura-icon";
    exec = "cura -platformtheme gtk3";
    terminal = false;
    type = "Application";
    categories = [ "Graphics" ];
    mimeType = [
      "model/stl"
      "application/vnd.ms-3mfdocument"
      "application/prs.wavefront-obj"
      "image/bmp"
      "image/gif"
      "image/jpeg"
      "image/png"
      "text/x-gcode"
      "application/x-amf"
      "application/x-ply"
      "application/x-ctm"
      "model/vnd.collada+xml"
      "model/gltf-binary"
      "model/gltf+json"
      "model/vnd.collada+xml+zip"
    ];
    settings = {
      Keywords = "3D;Printing;";
    };
  };
}
