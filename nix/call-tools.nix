pkgs:
pkgs.lib.flip builtins.removeAttrs [ "override" "overrideDerivation" ]
  (pkgs.callPackage ./tools.nix {
    cabal-fmt = (pkgs.haskell.lib.enableSeparateBinOutput pkgs.haskellPackages.cabal-fmt).bin;
    cabal-gild = (pkgs.haskell.lib.enableSeparateBinOutput pkgs.haskellPackages.cabal-gild).bin;
    hindent = pkgs.haskell.lib.enableSeparateBinOutput pkgs.haskellPackages.hindent;
  })
