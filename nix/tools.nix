{ stdenv
, lib
, pkgs
, placeholder
, actionlint
, action-validator
, alejandra
, ansible-lint
, biome
, cabal2nix
, callPackage
, cargo
, cargo-sort
, chart-testing
, checkmake
, circleci-cli
, llvmPackages_latest
, clippy
, cljfmt
, cmake-format
, commitizen
, comrak
, conform
, convco
, crystal
, cspell
, cue
, dart
, deadnix
, deno
, dhall
, dune_3
, eclint
, editorconfig-checker
, elixir
, elmPackages
, eslint
, flake-checker ? placeholder "flake-checker"
, flake-edit ? placeholder "flake-edit"
, fprettify
, git-annex
, gitlint
, gptcommit ? placeholder "gptcommit"
, hadolint
, haskell
, haskellPackages
, hledger-fmt ? placeholder "hledger-fmt"
, hlint
, hpack
, html-tidy
, keep-sorted
, luaPackages
, lua-language-server
, lychee
, julia-bin
, markdownlint-cli
, mdformat
, mdl
, mdsh
, nbstripout
, nil
, nixf-diagnose
, nixfmt
, nixfmt-classic ? placeholder "nixfmt-classic"
, nixfmt-rfc-style ? placeholder "nixfmt-rfc-style"
, nixpkgs-fmt
, nufmt ? placeholder "nufmt"
, nodePackages
, ocamlPackages
, opam
, opentofu
, ormolu
, oxfmt ? placeholder "oxfmt"
, oxlint
, panache ? placeholder "panache"
, pkgsBuildBuild
, poetry
, pre-commit-hook-ensure-sops ? placeholder "pre-commit-hook-ensure-sops"
, prettier
, prometheus
, proselint
, python3Packages
, pyright ? nodePackages.pyright
, phpPackages
, ripsecrets ? placeholder "ripsecrets"
, regal
, reuse
, ruff ? placeholder "ruff"
, rumdl ? placeholder "rumdl"
, rustfmt
, selene
, shellcheck
, bats
, shfmt
, beautysh
, sqlfluff
, statix
, stylish-haskell
, stylua
, tagref
, taplo
, texlive
, # Added in nixpkgs on Dec 2, 2022
  topiary ? placeholder "topiary"
, treefmt
, trufflehog
, typos
, # Added in nixpkgs in commit 800ca60
  typstyle ? placeholder "typstyle"
, woodpecker-cli
, zprint
, yamlfmt
, yamllint
, go
, go-tools
, golangci-lint
, golines
, revive ? placeholder "revive"
, uv
, vale
, zizmor
,
}:

let
  tex = texlive.combine {
    inherit (texlive) latexindent chktex scheme-basic;
  };
in
{
  clang-tools = llvmPackages_latest.clang-tools;
  inherit
    actionlint
    action-validator
    alejandra
    ansible-lint
    beautysh
    biome
    cabal2nix
    cargo
    cargo-sort
    chart-testing
    checkmake
    circleci-cli
    clippy
    cljfmt
    cmake-format
    comrak
    conform
    convco
    crystal
    cspell
    cue
    dart
    deadnix
    deno
    dhall
    eclint
    editorconfig-checker
    elixir
    eslint
    flake-checker
    flake-edit
    fprettify
    git-annex
    gitlint
    go
    go-tools
    golangci-lint
    golines
    gptcommit
    hadolint
    hledger-fmt
    hlint
    hpack
    html-tidy
    keep-sorted
    lychee
    markdownlint-cli
    mdformat
    mdl
    mdsh
    nbstripout
    nil
    nixf-diagnose
    nixpkgs-fmt
    nufmt
    opam
    opentofu
    ormolu
    oxfmt
    oxlint
    panache
    pre-commit-hook-ensure-sops
    prettier
    poetry
    proselint
    pyright
    regal
    reuse
    revive
    ripsecrets
    ruff
    rumdl
    rustfmt
    selene
    shellcheck
    shfmt
    sqlfluff
    statix
    stylish-haskell
    stylua
    tagref
    taplo
    topiary
    treefmt
    trufflehog
    typos
    typstyle
    uv
    vale
    woodpecker-cli
    yamlfmt
    yamllint
    zizmor
    zprint
    ;
  inherit (elmPackages) elm-format elm-review elm-test;
  # TODO: these two should be statically compiled
  inherit (haskellPackages) fourmolu;
  inherit (luaPackages) luacheck;
  inherit (ocamlPackages) ocp-indent;
  inherit (python3Packages)
    autoflake
    black
    flake8
    flynt
    isort
    mkdocs-linkcheck
    mypy
    openapi-spec-validator
    pre-commit-hooks
    pylint
    pyupgrade
    ;
  inherit (phpPackages) php-cs-fixer psalm;
  # FIXME: workaround build failure
  phpstan = phpPackages.phpstan.overrideAttrs (old: {
    composerStrictValidation = false;
  });
  # these two are for backwards compatibility
  phpcbf = phpPackages.php-codesniffer or phpPackages.phpcbf;
  phpcs = phpPackages.php-codesniffer or phpPackages.phpcs;
  lua-language-server = lua-language-server;
  purs-tidy =
    if pkgs ? nodePackages && pkgs.nodePackages ? purs-tidy then
      pkgs.nodePackages.purs-tidy
    else
      placeholder "purs-tidy";
  cabal2nix-dir = callPackage ./cabal2nix-dir { };
  hpack-dir = callPackage ./hpack-dir { };
  hunspell = callPackage ./hunspell { };
}
