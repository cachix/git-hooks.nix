{ sources ? import ./sources.nix }:
with {
    overlay =
      _: pkgs:
        {
          inherit (import sources.niv {}) niv;
          inherit (import sources.ormolu { }) ormolu;
          inherit (import sources.canonix {}) canonix;
          cabal-fmt = null;
          packages = pkgs.callPackages ./packages.nix {};
        };
  };

import sources.nixpkgs { overlays = [ overlay ]; config = {}; }
