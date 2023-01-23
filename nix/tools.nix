{ actionlint
, alejandra
, ansible-lint
, cabal-fmt
, cabal2nix
, callPackage
, cargo
, clang-tools
, clippy
, commitizen
, deadnix
, dhall
, editorconfig-checker
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
, mdsh
, nixfmt
, nixpkgs-fmt
, nodePackages
, ormolu
, python39Packages
, ruff ? null
, runCommand
, rustfmt
, shellcheck
, bats
, shfmt
, statix
, stylish-haskell
, stylua
, texlive
, typos
, yamllint
, writeScript
, writeText
, go
, go-tools
, revive ? null
}:


let
  tex = texlive.combine {
    inherit (texlive) latexindent chktex scheme-basic;
  };
in
{
  inherit actionlint ansible-lint alejandra cabal-fmt cabal2nix cargo clang-tools clippy deadnix dhall editorconfig-checker hadolint hindent hlint hpack html-tidy nixfmt nixpkgs-fmt ormolu rustfmt shellcheck shfmt statix stylish-haskell stylua typos go mdsh revive go-tools yamllint ruff;
  inherit (elmPackages) elm-format elm-review elm-test;
  # TODO: these two should be statically compiled
  inherit (haskellPackages) fourmolu;
  inherit (luaPackages) luacheck;
  inherit (nodePackages) eslint markdownlint-cli prettier;
  purs-tidy = nodePackages.purs-tidy or null;
  cabal2nix-dir = callPackage ./cabal2nix-dir { };
  hpack-dir = callPackage ./hpack-dir { };
  hunspell = callPackage ./hunspell { };
  purty = callPackage ./purty { purty = nodePackages.purty; };
  terraform-fmt = callPackage ./terraform-fmt { };
  latexindent = tex;
  chktex = tex;
  commitizen = commitizen.overrideAttrs (_: _: { doCheck = false; });
  bats = if bats ? withLibraries then (bats.withLibraries (p: [ p.bats-support p.bats-assert p.bats-file ])) else bats;
}
