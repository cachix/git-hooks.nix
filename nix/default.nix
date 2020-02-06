{ sources ? import ./sources.nix
, system ? builtins.currentSystem
}:

let
  haskellnix = import sources."haskell.nix";
  overlay =
    _: pkgs:
      let
        cabal-fmt =
          pkgs.haskellPackages.callCabal2nix "cabal-fmt" sources.cabal-fmt {};
      in
        {
          inherit (pkgs) nixfmt niv ormolu nixpkgs-fmt;
          hindent =
            pkgs.haskellPackages.callCabal2nix "hindent" sources.hindent {};
          cabal-fmt =
            cabal-fmt.overrideScope (
              self: super:
                {
                  Cabal = self.Cabal_3_0_0_0;
                }
            );
          packages = pkgs.callPackages ./packages.nix {};
        };
in
import sources.nixpkgs {
  overlays = haskellnix.overlays ++ [ overlay ];
  config = haskellnix.config // {};
  inherit system;
}
