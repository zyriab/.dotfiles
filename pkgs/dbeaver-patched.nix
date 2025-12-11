{ pkgs }:
with pkgs;
dbeaver-bin.overrideAttrs (oldAttrs: {
  buildInputs = (oldAttrs.buildInputs or [ ]);
  postInstall = (oldAttrs.postInstall or "") + ''
    wrapProgram $out/bin/dbeaver-bin --set GDK_BACKEND="x11";
  '';
})
