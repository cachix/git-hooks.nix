{ sources ? import ./sources.nix }:

with {
    overlay =
      _: pkgs:
        let
          haskell = import sources."haskell.nix" { inherit pkgs; };
          pkgPlan =
            haskell.callCabalProjectToNix {
              index-state = "2019-08-18T00:00:00Z";
              src = sources.cabal-fmt;
            };
          # Instantiate a package set using the generated file.
          pkgSet =
            haskell.mkCabalProjectPkgSet {
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

import sources.nixpkgs { overlays = [ overlay ]; config = {}; }
