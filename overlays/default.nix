# Nixpkgs overlays - modifications to packages in nixpkgs
# Each overlay is a function: final: prev: { package = ...; }
# - prev: the previous package set
# - final: the final package set (after all overlays)

final: prev: {
  # Fix dfu-programmer C23 compatibility issue
  # Force compilation with C11 instead of C23 to avoid 'false' keyword conflict
  dfu-programmer = prev.dfu-programmer.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -std=gnu11";
  });
}
