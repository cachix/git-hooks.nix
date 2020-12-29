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
, pythonPackages
, rustfmt
, clippy
, cargo
, nodePackages
, hunspell
}:

{
  inherit ansible-lint hlint shellcheck ormolu hindent cabal-fmt nixpkgs-fmt nixfmt nix-linter rustfmt clippy cargo;
  inherit (elmPackages) elm-format;
  inherit (haskellPackages) stylish-haskell brittany hpack fourmolu;
  inherit (pythonPackages) yamllint;
  inherit (nodePackages) prettier;
  purty = callPackage ./purty { purty = nodePackages.purty; };
  terraform-fmt = callPackage ./terraform-fmt { };
  hunspell = callPackage ./hunspell { };
}
