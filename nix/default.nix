{ sources ? import ./sources.nix
, system ? builtins.currentSystem
}:
let
  overlay =
    _: pkgs:
    {
      inherit (pkgs) nixfmt niv ormolu nixpkgs-fmt nix-linter;
      cabal-fmt = pkgs.haskellPackages.cabal-fmt;
      hindent = pkgs.haskellPackages.callCabal2nix "hindent" sources.hindent { };
      packages = pkgs.callPackages ./packages.nix { };
    };
in
import sources.nixpkgs {
  overlays = [ overlay ];
  config = { };
  inherit system;
}
