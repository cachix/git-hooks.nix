{ ansible-lint
, haskell
, haskellPackages
, hlint
, shellcheck
, shfmt
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
, alejandra
, nixpkgs-fmt
, nixfmt
, nix-linter
, statix
, callPackage
, python39Packages
, rustfmt
, clippy
, cargo
, nodePackages
, hunspell
, html-tidy
, clang-tools
, hadolint
}:

{

  inherit hlint shellcheck shfmt hindent cabal-fmt alejandra nixpkgs-fmt nixfmt nix-linter statix rustfmt clippy cargo html-tidy clang-tools hadolint;
  inherit (elmPackages) elm-format elm-review elm-test;
  inherit (haskellPackages) stylish-haskell brittany hpack fourmolu;
  inherit (python39Packages) yamllint ansible-lint;
  inherit (nodePackages) eslint markdownlint-cli prettier;
  ormolu = haskell.packages.ghc921.ormolu;
  purty = callPackage ./purty { purty = nodePackages.purty; };
  terraform-fmt = callPackage ./terraform-fmt { };
  hpack-dir = callPackage ./hpack-dir { hpack = haskellPackages.hpack; };
  hunspell = callPackage ./hunspell { };
}
