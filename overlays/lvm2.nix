# LVM2 overlay - pins lvm2 to a working version
# Workaround for nixpkgs#475910: lvm/dmsetup became shell scripts, breaking initrd build
# This overlay requires `inputs` to be passed from the flake
#
# Usage in flake.nix:
#   overlays = [ (import ./overlays/lvm2.nix inputs) ];

inputs: final: prev: {
  lvm2 = inputs.nixpkgs-lvm2.legacyPackages.${prev.system}.lvm2;
}
