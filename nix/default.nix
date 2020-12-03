{ sources ? import ./sources.nix
, system ? builtins.currentSystem
, nixpkgs ? sources.nixpkgs
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
import nixpkgs {
  overlays = [ overlay ];
  config = { };
  inherit system;
}
