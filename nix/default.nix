{ nixpkgs
, hindent-src
, cabal-fmt-src
, pre-commit-hooks-module
, system ? builtins.currentSystem
}:

let
  overlay =
    _: pkgs:
      let
        cabal-fmt =
          pkgs.haskellPackages.callCabal2nix "cabal-fmt" cabal-fmt-src {};
      in
        {
          hindent =
            pkgs.haskellPackages.callCabal2nix "hindent" hindent-src {};
          cabal-fmt =
            cabal-fmt.overrideScope (
              self: super:
                {
                  Cabal = self.Cabal_3_0_0_0;
                }
            );
          packages = pkgs.callPackages ./packages.nix { inherit pre-commit-hooks-module; };
        };
in
import nixpkgs {
  overlays = [
    overlay
  ];
  config = {};
  inherit system;
}
