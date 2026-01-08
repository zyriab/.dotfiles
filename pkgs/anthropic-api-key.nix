{
  lib,
  stdenv,
  fetchurl,
  nodejs,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "anthropic-api-key";
  version = "0.2.3";

  src = fetchurl {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-IfoC3IJOD+NqDbDsfu4YeicgJUdi6bkYffY59uavpaQ=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ nodejs ];

  unpackPhase = ''
    tar xzf $src
    mv package $pname
  '';

  installPhase = ''
    mkdir -p $out/lib/node_modules/${pname}
    cp -r $pname/* $out/lib/node_modules/${pname}/

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/anthropic-api-key \
      --add-flags "$out/lib/node_modules/${pname}/dist/index.js"
  '';

  meta = {
    description = "CLI to fetch Anthropic API access tokens via OAuth with PKCE";
    homepage = "https://github.com/taciturnaxolotl/anthropic-api-key";
    license = lib.licenses.mit;
    mainProgram = "anthropic-api-key";
  };
}
