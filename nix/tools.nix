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
, convco
, crystal
, deadnix
, dhall
, dune_3
, editorconfig-checker
, elmPackages
, fprettify
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
, sumneko-lua-language-server
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
, tflint
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
  inherit
    actionlint
    alejandra
    ansible-lint
    cabal2nix
    cabal-fmt
    cargo
    clang-tools
    clippy
    convco
    crystal
    deadnix
    dhall
    editorconfig-checker
    fprettify
    go
    go-tools
    gptcommit
    hadolint
    hindent
    hlint
    hpack
    html-tidy
    mdsh
    nil
    nixfmt
    nixpkgs-fmt
    opam
    ormolu
    revive
    ruff
    rustfmt
    shellcheck
    shfmt
    statix
    stylish-haskell
    stylua
    tagref
    topiary
    typos
    yamllint
    ;
  inherit (elmPackages) elm-format elm-review elm-test;
  # TODO: these two should be statically compiled
  inherit (haskellPackages) fourmolu;
  inherit (luaPackages) luacheck;
  inherit (nodePackages) eslint markdownlint-cli prettier cspell;
  inherit (ocamlPackages) ocp-indent;
  lua-language-server = sumneko-lua-language-server;
  purs-tidy = nodePackages.purs-tidy or null;
  cabal2nix-dir = callPackage ./cabal2nix-dir { };
  hpack-dir = callPackage ./hpack-dir { };
  hunspell = callPackage ./hunspell { };
  purty = callPackage ./purty { purty = nodePackages.purty; };
  terraform-fmt = callPackage ./terraform-fmt { };
  tflint = callPackage ./tflint { };
  dune-build-opam-files = callPackage ./dune-build-opam-files { dune = dune_3; inherit (pkgsBuildBuild) ocaml; };
  dune-fmt = callPackage ./dune-fmt { dune = dune_3; inherit (pkgsBuildBuild) ocaml; };
  latexindent = tex;
  chktex = tex;
  commitizen = commitizen.overrideAttrs (_: _: { doCheck = false; });
  bats = if bats ? withLibraries then (bats.withLibraries (p: [ p.bats-support p.bats-assert p.bats-file ])) else bats;

  ## NOTE: `checkmake` 0.2.2 landed in nixpkgs on 12 April 2023. Once this gets
  ## into a NixOS release, the following code will be useless.
  checkmake = if stdenv.isLinux || checkmake.version >= "0.2.2" then checkmake else null;

  headache = callPackage ./headache { };
}
