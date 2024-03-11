{ stdenv

, actionlint
, alejandra
, ansible-lint
, biome
, cabal-fmt
, cabal2nix
, callPackage
, cargo
, checkmake
, clang-tools
, clippy
, cljfmt
, cmake-format
, commitizen
, conform
, convco
, crystal
, deadnix
, deno
, dhall
, dune_3
, eclint
, editorconfig-checker
, elixir
, elmPackages
, fprettify
, git
, git-annex
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
, lua-language-server
, julia-bin
, mdl
, mdsh
, nil
, nixfmt
, nixpkgs-fmt
, nodePackages
, ocamlPackages
, opam
, ormolu
, pkgsBuildBuild
, pre-commit-hook-ensure-sops ? null
, python3Packages
, php82Packages
, ruff ? null
, runCommand
, rustfmt
, shellcheck
, bats
, shfmt
, beautysh
, statix
, stylish-haskell
, stylua
, tagref
, taplo
, texlive
, tflint
, topiary ? null ## Added in nixpkgs on Dec 2, 2022
, typos
, typstfmt
, zprint
, yamllint
, writeScript
, writeText
, go
, go-tools
, golangci-lint
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
    beautysh
    biome
    cabal2nix
    cabal-fmt
    cargo
    clang-tools
    clippy
    cljfmt
    cmake-format
    conform
    convco
    crystal
    deadnix
    deno
    dhall
    eclint
    editorconfig-checker
    elixir
    fprettify
    git-annex
    go
    go-tools
    golangci-lint
    gptcommit
    hadolint
    hindent
    hlint
    hpack
    html-tidy
    julia-bin
    mdl
    mdsh
    nil
    nixfmt
    nixpkgs-fmt
    opam
    ormolu
    pre-commit-hook-ensure-sops
    revive
    ruff
    rustfmt
    shellcheck
    shfmt
    statix
    stylish-haskell
    stylua
    tagref
    taplo
    topiary
    typos
    typstfmt
    yamllint
    zprint
    ;
  inherit (elmPackages) elm-format elm-review elm-test;
  # TODO: these two should be statically compiled
  inherit (haskellPackages) fourmolu;
  inherit (luaPackages) luacheck;
  inherit (nodePackages) eslint markdownlint-cli prettier pyright cspell;
  inherit (ocamlPackages) ocp-indent;
  inherit (python3Packages) autoflake black flake8 flynt isort mkdocs-linkcheck mypy pylint pyupgrade;
  inherit (php82Packages) php-cs-fixer phpcbf phpcs psalm;
  # FIXME: workaround build failure
  phpstan = php82Packages.phpstan.overrideAttrs (old: {
    composerStrictValidation = false;
  });
  lua-language-server = lua-language-server;
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
