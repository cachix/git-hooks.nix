{ sources ? import ./sources.nix 
, system ? builtins.currentSystem
}:

with {
    haskellnix = import sources."haskell.nix";
    overlay =
      _: pkgs:
        let
          pkgPlan =
            pkgs.haskell-nix.callCabalProjectToNix {
              #index-state = "2020-02-18T00:00:00Z";
              src = sources.cabal-fmt;
            };
          # Instantiate a package set using the generated file.
          pkgSet =
            pkgs.haskell-nix.mkCabalProjectPkgSet {
              plan-pkgs = import pkgPlan;
              pkg-def-extras = [];
              modules = [];
            };
        in {
          inherit (pkgs) nixfmt niv ormolu nixpkgs-fmt;
          hindent =
            pkgs.haskellPackages.callCabal2nix "hindent" sources.hindent {};
          # TODO: expose overlay to avoid evaluating nixpkgs twice
          inherit (import sources.canonix {}) canonix;
          # Requires Cabal 3, wait for LTS 15
          cabal-fmt =
            pkgSet.config.hsPkgs.cabal-fmt.components.exes.cabal-fmt;
          packages = pkgs.callPackages ./packages.nix {};
        };
  };
import sources.nixpkgs {
  overlays = haskellnix.overlays ++ [ overlay ];
  config = haskellnix.config // {};
  inherit system;
}
