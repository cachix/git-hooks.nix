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
          inherit (import sources.niv { inherit pkgs; }) niv;
          inherit (import sources.ormolu { inherit pkgs; }) ormolu;
          # TODO: expose overlay to avoid evaluating nixpkgs twice
          inherit (import sources.canonix {}) canonix;
          nixfmt = import sources.nixfmt { inherit pkgs; };
          nixpkgs-fmt = import sources.nixpkgs-fmt { inherit pkgs; };
          cabal-fmt =
            pkgSet.config.hsPkgs.cabal-fmt.components.exes.cabal-fmt;
          packages = pkgs.callPackages ./packages.nix {};
        };
  };

import sources.nixpkgs { overlays = [ overlay ]; config = {}; }
