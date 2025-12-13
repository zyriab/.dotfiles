{ pkgs, lib, ... }:

pkgs.spotify.overrideAttrs (oldAttrs: {
  postInstall = (oldAttrs.postInstall or "") + ''
    # Add libayatana-appindicator to the library path
    wrapProgram $out/share/spotify/.spotify-wrapped \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ pkgs.libayatana-appindicator ]}"
  '';

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
})
