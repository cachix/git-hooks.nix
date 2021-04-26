{ ansible-lint
, haskellPackages
, hlint
, shellcheck
, ormolu
, hindent
, cabal-fmt
, elmPackages
, niv
, gitAndTools
, runCommand
, writeText
, writeScript
, git
, nixpkgs-fmt
, nixfmt
, nix-linter
, callPackage
, python3Packages
, rustfmt
, clippy
, cargo
}:

{
  inherit ansible-lint hlint shellcheck ormolu hindent cabal-fmt nixpkgs-fmt nixfmt nix-linter rustfmt clippy cargo;
  inherit (elmPackages) elm-format;
  inherit (haskellPackages) brittany hpack;
  inherit (python3Packages) yamllint;
  terraform-fmt = callPackage ./terraform-fmt { };
}
