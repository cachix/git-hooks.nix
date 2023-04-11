{ stdenv

, actionlint
, alejandra
, ansible-lint
, cabal-fmt
, cabal2nix
, callPackage
, cargo
, checkmake
, clang-tools
, clippy
, commitizen
, deadnix
, dhall
, dune_3
, editorconfig-checker
, elmPackages
, git
, gitAndTools
, gptcommit ? null
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
, nil
, nixfmt
, nixpkgs-fmt
, nodePackages
, ocamlPackages
, opam
, ormolu
, pkgsBuildBuild
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
, tagref
, texlive
, topiary ? null ## Added in nixpkgs on Dec 2, 2022
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
  inherit actionlint ansible-lint alejandra cabal-fmt cabal2nix cargo clang-tools gptcommit clippy deadnix dhall editorconfig-checker hadolint hindent hlint hpack html-tidy nil nixfmt nixpkgs-fmt opam ormolu rustfmt shellcheck shfmt statix stylish-haskell stylua tagref typos go mdsh revive go-tools yamllint ruff topiary;
  inherit (elmPackages) elm-format elm-review elm-test;
  # TODO: these two should be statically compiled
  inherit (haskellPackages) fourmolu;
  inherit (luaPackages) luacheck;
  inherit (nodePackages) eslint markdownlint-cli prettier;
  inherit (ocamlPackages) ocp-indent;
  purs-tidy = nodePackages.purs-tidy or null;
  cabal2nix-dir = callPackage ./cabal2nix-dir { };
  hpack-dir = callPackage ./hpack-dir { };
  hunspell = callPackage ./hunspell { };
  purty = callPackage ./purty { purty = nodePackages.purty; };
  terraform-fmt = callPackage ./terraform-fmt { };
  dune-build-opam-files = callPackage ./dune-build-opam-files { dune = dune_3; inherit (pkgsBuildBuild) ocaml; };
  latexindent = tex;
  chktex = tex;
  commitizen = commitizen.overrideAttrs (_: _: { doCheck = false; });
  bats = if bats ? withLibraries then (bats.withLibraries (p: [ p.bats-support p.bats-assert p.bats-file ])) else bats;

  ## NOTE: `checkmake` 0.2.2 landed in nixpkgs on 12 April 2023. Once this gets
  ## into a NixOS release, the following code will be useless.
  checkmake = if stdenv.isLinux || checkmake.version >= "0.2.2" then checkmake else null;
}
