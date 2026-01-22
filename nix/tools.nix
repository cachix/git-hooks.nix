{ stdenv
, lib
, placeholder
, actionlint
, action-validator
, alejandra
, ansible-lint
, biome
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
, flake-checker ? placeholder "flake-checker"
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
, nodePackages
, ocamlPackages
, opam
, opentofu
, ormolu
, pkgsBuildBuild
, poetry
, pre-commit-hook-ensure-sops ? placeholder "pre-commit-hook-ensure-sops"
, proselint
, python3Packages
, pyright ? nodePackages.pyright
, phpPackages
, ripsecrets ? placeholder "ripsecrets"
, reuse
, ruff ? placeholder "ruff"
, rumdl ? placeholder "rumdl"
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
    cue
    dart
    deadnix
    deno
    dhall
    eclint
    editorconfig-checker
    elixir
    flake-checker
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
    mdformat
    mdl
    mdsh
    nbstripout
    nil
    nixf-diagnose
    nixpkgs-fmt
    opam
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
    rumdl
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
  inherit (nodePackages)
    eslint
    markdownlint-cli
    prettier
    cspell
    ;
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
  purs-tidy = nodePackages.purs-tidy or (placeholder "purs-tidy");
  cabal2nix-dir = callPackage ./cabal2nix-dir { };
  hpack-dir = callPackage ./hpack-dir { };
  hunspell = callPackage ./hunspell { };
  tflint = callPackage ./tflint { };
  dune-build-opam-files = callPackage ./dune-build-opam-files {
    dune = dune_3;
    inherit (pkgsBuildBuild) ocaml;
  };
  dune-fmt = callPackage ./dune-fmt {
    dune = dune_3;
    inherit (pkgsBuildBuild) ocaml;
  };
  latexindent = tex;
  lacheck = texlive.combine {
    inherit (texlive) lacheck scheme-basic;
  };
  chktex = tex;
  commitizen = commitizen.overrideAttrs (_: _: { doCheck = false; });
  bats =
    if bats ? withLibraries then
      (bats.withLibraries (p: [
        p.bats-support
        p.bats-assert
        p.bats-file
      ]))
    else
      bats;

  headache = callPackage ./headache { };

  # Disable tests as these take way to long on our infra.
  julia-bin = julia-bin.overrideAttrs (_: _: { doInstallCheck = false; });

  cabal-fmt = (haskell.lib.enableSeparateBinOutput haskellPackages.cabal-fmt).bin;
  cabal-gild = (haskell.lib.enableSeparateBinOutput haskellPackages.cabal-gild).bin;
  hindent = haskell.lib.enableSeparateBinOutput haskellPackages.hindent;

  # nixfmt 1.0 is now the official Nix formatter as of 25.11.
  #
  # In 24.05, the `nixfmt` package was deprecated and replaced with two separate packages:
  #   - nixfmt-classic
  #   - nixfmt-rfc-style
  #
  # Remove this block in 26.05
  nixfmt =
    if lib.versionOlder nixfmt.version "1.0" && (nixfmt-classic.meta.isPlaceholder or false) then
      nixfmt-classic
    else
      nixfmt;
  inherit nixfmt-classic nixfmt-rfc-style;
}
