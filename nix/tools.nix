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
  inherit actionlint alejandra cabal-fmt cargo clang-tools clippy hadolint hindent hlint hpack html-tidy nix-linter nixfmt nixpkgs-fmt ormolu rustfmt shellcheck shfmt statix stylish-haskell stylua;
  inherit (elmPackages) elm-format elm-review elm-test;
  inherit (haskellPackages) brittany fourmolu;
  inherit (luaPackages) luacheck;
  inherit (nodePackages) eslint markdownlint-cli prettier;
  inherit (python39Packages) ansible-lint yamllint;
  inherit (texlive) chktex latexindent;
  hpack-dir = callPackage ./hpack-dir { hpack = haskellPackages.hpack; };
  hunspell = callPackage ./hunspell { };
  purty = callPackage ./purty { purty = nodePackages.purty; };
  terraform-fmt = callPackage ./terraform-fmt { };
}
