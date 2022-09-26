{ ansible-lint
, haskell
, haskellPackages
, hlint
, shellcheck
, stylua
, luaPackages
, shfmt
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
, hpack
, ormolu
, stylish-haskell
}:

{
  inherit hlint shellcheck stylua shfmt hindent cabal-fmt alejandra nixpkgs-fmt nixfmt nix-linter statix rustfmt clippy cargo html-tidy clang-tools hadolint ormolu stylish-haskell hpack;
  inherit (elmPackages) elm-format elm-review elm-test;
  inherit (haskellPackages) brittany fourmolu;
  inherit (luaPackages) luacheck;
  inherit (python39Packages) yamllint ansible-lint;
  inherit (nodePackages) eslint markdownlint-cli prettier;
  purty = callPackage ./purty { purty = nodePackages.purty; };
  terraform-fmt = callPackage ./terraform-fmt { };
  hpack-dir = callPackage ./hpack-dir { hpack = haskellPackages.hpack; };
  hunspell = callPackage ./hunspell { };
}
