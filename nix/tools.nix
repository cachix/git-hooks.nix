{ actionlint
, alejandra
, ansible-lint
, cabal-fmt
, callPackage
, cargo
, clang-tools
, clippy
, elmPackages
, git
, gitAndTools
, hadolint
, haskell
, haskellPackages
, hindent
, hlint
, hpack
, html-tidy
, hunspell
, luaPackages
, niv
, nix-linter
, nixfmt
, nixpkgs-fmt
, nodePackages
, ormolu
, python39Packages
, runCommand
, rustfmt
, shellcheck
, shfmt
, statix
, stylish-haskell
, stylua
, texlive
, writeScript
, writeText
}:

{
  inherit actionlint hlint shellcheck stylua shfmt hindent cabal-fmt alejandra nixpkgs-fmt nixfmt nix-linter statix rustfmt clippy cargo html-tidy clang-tools hadolint ormolu stylish-haskell hpack;
  inherit (elmPackages) elm-format elm-review elm-test;
  inherit (haskellPackages) brittany fourmolu;
  inherit (luaPackages) luacheck;
  inherit (python39Packages) yamllint ansible-lint;
  inherit (nodePackages) eslint markdownlint-cli prettier;
  inherit (texlive) chktex;
  purty = callPackage ./purty { purty = nodePackages.purty; };
  terraform-fmt = callPackage ./terraform-fmt { };
  hpack-dir = callPackage ./hpack-dir { hpack = haskellPackages.hpack; };
  hunspell = callPackage ./hunspell { };
}
