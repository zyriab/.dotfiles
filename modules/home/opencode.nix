{ pkgs, inputs, ... }:
let
  opencodePkg =
    inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
      (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace packages/opencode/src/session/prompt.ts \
            --replace "tools[item.id]" "tools[\`oc_\$\{item.id}\`]" \
            --replace "id: item.id" "id: \`oc_\$\{item.id}\`"
          # Strip prefix from incoming tool names
          substituteInPlace packages/opencode/src/session/processor.ts \
            --replace "value.toolName" 'value.toolName.replace(/^oc_/, "")'
        '';
      });
in
{
  home.packages = [ opencodePkg ];
}
