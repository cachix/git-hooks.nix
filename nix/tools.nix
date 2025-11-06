{ stdenv
, lib

, actionlint
, action-validator
, alejandra
, ansible-lint
, biome
, cabal-fmt
, cabal-gild
, cabal2nix
, callPackage
, cargo
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
, dart
, deadnix
, deno
, dhall
, dune_3
, eclint
, editorconfig-checker
, elixir
, elmPackages
, flake-checker ? null
, fprettify
, git-annex
, gitlint
, gptcommit ? null
, hadolint
, haskellPackages
, hindent
, hledger-fmt ? null
, hlint
, hpack
, html-tidy
, keep-sorted
, luaPackages
, lua-language-server
, lychee
, julia-bin
, mdformat
, mdl
, mdsh
, nbstripout
, nil
, nixfmt
, nixfmt-classic ? null
, nixfmt-rfc-style ? null
, nixpkgs-fmt
, nodePackages
, ocamlPackages
, opam
, opentofu
, ormolu
, pkgsBuildBuild
, poetry
, pre-commit-hook-ensure-sops ? null
, proselint
, python3Packages
, pyright ? nodePackages.pyright
, phpPackages
, ripsecrets ? null
, reuse
, ruff ? null
, rustfmt
, selene
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
, topiary ? null ## Added in nixpkgs on Dec 2, 2022
, treefmt
, trufflehog
, typos
, typstfmt
, typstyle ? null ## Add in nixpkgs added on commit 800ca60
, woodpecker-cli
, zprint
, yamlfmt
, yamllint
, go
, go-tools
, golangci-lint
, golines
, revive ? null
, uv
, vale
, zizmor
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
    cabal-fmt
    cabal-gild
    cargo
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
    dart
    deadnix
    deno
    dhall
    eclint
    editorconfig-checker
    elixir
    flake-checker
    fprettify
    gitlint
    go
    go-tools
    golangci-lint
    golines
    gptcommit
    hadolint
    hindent
    hledger-fmt
    hlint
    hpack
    html-tidy
    keep-sorted
    lychee
    mdformat
    mdl
    mdsh
    nbstripout
    nil
    nixpkgs-fmt
    opentofu
    ormolu
    pre-commit-hook-ensure-sops
    poetry
    proselint
    pyright
    reuse
    revive
    ripsecrets
    ruff
    rustfmt
    selene
    shellcheck
    shfmt
    statix
    stylish-haskell
    stylua
    tagref
    taplo
    topiary
    treefmt
    trufflehog
    typos
    typstfmt
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
  inherit (nodePackages) eslint markdownlint-cli prettier cspell;
  inherit (ocamlPackages) ocp-indent;
  inherit (python3Packages) autoflake black flake8 flynt isort mkdocs-linkcheck mypy openapi-spec-validator pre-commit-hooks pylint pyupgrade;
  inherit (phpPackages) php-cs-fixer psalm;
  # FIXME: workaround build failure
  phpstan = phpPackages.phpstan.overrideAttrs (old: {
    composerStrictValidation = false;
  });
  # these two are for backwards compatibility
  phpcbf = phpPackages.php-codesniffer or phpPackages.phpcbf;
  phpcs = phpPackages.php-codesniffer or phpPackages.phpcs;
  lua-language-server = lua-language-server;
  purs-tidy = nodePackages.purs-tidy or null;
  cabal2nix-dir = callPackage ./cabal2nix-dir { };
  hpack-dir = callPackage ./hpack-dir { };
  hunspell = callPackage ./hunspell { };
  purty = callPackage ./purty { purty = nodePackages.purty; };
  terraform-validate = callPackage ./terraform-validate { };
  tflint = callPackage ./tflint { };
  dune-build-opam-files = callPackage ./dune-build-opam-files { dune = dune_3; inherit (pkgsBuildBuild) ocaml; };
  dune-fmt = callPackage ./dune-fmt { dune = dune_3; inherit (pkgsBuildBuild) ocaml; };
  latexindent = tex;
  lacheck = texlive.combine {
    inherit (texlive) lacheck scheme-basic;
  };
  chktex = tex;
  commitizen = commitizen.overrideAttrs (_: _: { doCheck = false; });
  bats = if bats ? withLibraries then (bats.withLibraries (p: [ p.bats-support p.bats-assert p.bats-file ])) else bats;
  git-annex = if stdenv.isDarwin then null else git-annex;
  # Note: Only broken in stable nixpkgs, works fine on latest master.
  opam = if stdenv.isDarwin then null else opam;

  headache = callPackage ./headache { };

  # Disable tests as these take way to long on our infra.
  julia-bin = julia-bin.overrideAttrs (_: _: { doInstallCheck = false; });

  # nixfmt 1.0 is now the official Nix formatter as of 25.11.
  #
  # In 24.05, the `nixfmt` package was deprecated and replaced with two separate packages:
  #   - nixfmt-classic
  #   - nixfmt-rfc-style
  #
  # Remove this block in 26.05
  nixfmt =
    if lib.versionOlder nixfmt.version "1.0" && nixfmt-classic != null
    then nixfmt-classic
    else nixfmt;
  inherit nixfmt-classic nixfmt-rfc-style;
}
