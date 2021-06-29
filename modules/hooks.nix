{ config, lib, pkgs, ... }:
let
  inherit (config) tools settings;
  inherit (lib) mkOption types;
in
{
  options.settings =
    {
      ormolu =
        {
          defaultExtensions =
            mkOption {
              type = types.listOf types.str;
              description = "Haskell language extensions to enable";
              default = [ ];
            };
        };
      nix-linter =
        {
          checks =
            mkOption {
              type = types.listOf types.str;
              description =
                "Available checks (See `nix-linter --help-for [CHECK]` for more details)";
              default = [ ];
            };
        };
      prettier =
        {
          binPath =
            mkOption {
              type = types.path;
              description =
                "Prettier binary path. E.g. if you want to use the prettier in node_modules, use ./node_modules/.bin/prettier";
              default = "${tools.prettier}/bin/prettier";
            };
        };
    };

  config.hooks =
    {
      ansible-lint =
        {
          name = "ansible-lint";
          description =
            "Ansible linter";
          entry = "${tools.ansible-lint}/bin/ansible-lint";
        };
      black =
        {
          name = "black";
          description = "The uncompromising Python code formatter";
          entry = "${pkgs.python3Packages.black}/bin/black";
          types = [ "file" "python" ];
        };
      brittany =
        {
          name = "brittany";
          description = "Haskell source code formatter.";
          entry = "${tools.brittany}/bin/brittany --write-mode=inplace";
          files = "\\.l?hs$";
        };
      hlint =
        {
          name = "hlint";
          description =
            "HLint gives suggestions on how to improve your source code.";
          entry = "${tools.hlint}/bin/hlint";
          files = "\\.l?hs$";
        };
      hpack =
        {
          name = "hpack";
          description =
            "hpack converts package definitions in the hpack format (package.yaml) to Cabal files.";
          entry = "${tools.hpack-dir}/bin/hpack-dir";
          files = "(\\.l?hs$)|(^[^/]+\\.cabal$)|(^package\\.yaml$)";
        };
      ormolu =
        {
          name = "ormolu";
          description = "Haskell code prettifier.";
          entry =
            "${tools.ormolu}/bin/ormolu --mode inplace ${
            lib.escapeShellArgs (lib.concatMap (ext: [ "--ghc-opt" "-X${ext}" ]) settings.ormolu.defaultExtensions)
            }";
          files = "\\.l?hs$";
        };
      fourmolu =
        {
          name = "fourmolu";
          description = "Haskell code prettifier.";
          entry =
            "${tools.fourmolu}/bin/fourmolu --mode inplace ${
            lib.escapeShellArgs (lib.concatMap (ext: [ "--ghc-opt" "-X${ext}" ]) settings.ormolu.defaultExtensions)
            }";
          files = "\\.l?hs$";
        };
      hindent =
        {
          name = "hindent";
          description = "Haskell code prettifier.";
          entry = "${tools.hindent}/bin/hindent";
          files = "\\.l?hs$";
        };
      cabal-fmt =
        {
          name = "cabal-fmt";
          description = "Format Cabal files";
          entry = "${tools.cabal-fmt}/bin/cabal-fmt --inplace";
          files = "\\.cabal$";
        };
      stylish-haskell =
        {
          name = "stylish-haskell";
          description = "A simple Haskell code prettifier";
          entry = "${tools.stylish-haskell}/bin/stylish-haskell --inplace";
          files = "\\.l?hs$";
        };
      nixfmt =
        {
          name = "nixfmt";
          description = "Nix code prettifier.";
          entry = "${tools.nixfmt}/bin/nixfmt";
          files = "\\.nix$";
        };
      nixpkgs-fmt =
        {
          name = "nixpkgs-fmt";
          description = "Nix code prettifier.";
          entry = "${tools.nixpkgs-fmt}/bin/nixpkgs-fmt";
          files = "\\.nix$";
        };
      nix-linter =
        {
          name = "nix-linter";
          description = "Linter for the Nix expression language.";
          entry =
            "${tools.nix-linter}/bin/nix-linter ${
            lib.escapeShellArgs (lib.concatMap (check: [ "-W" "${check}" ]) settings.nix-linter.checks)
            }";
          files = "\\.nix$";
        };
      elm-format =
        {
          name = "elm-format";
          description = "Format Elm files";
          entry =
            "${tools.elm-format}/bin/elm-format --yes --elm-version=0.19";
          files = "\\.elm$";
        };
      elm-review =
        {
          name = "elm-review";
          description = "Analyzes Elm projects, to help find mistakes before your users find them.";
          entry = "${tools.elm-review}/bin/elm-review";
          files = "\\.elm$";
          pass_filenames = false;
        };
      elm-test =
        {
          name = "elm-review";
          description = "Run unit and fuzz tests for Elm code.";
          entry = "${tools.elm-test}/bin/elm-test";
          files = "\\.elm$";
          pass_filenames = false;
        };
      shellcheck =
        {
          name = "shellcheck";
          description = "Format shell files";
          types = [ "shell" ];
          types_or =
            # based on `goodShells` in https://github.com/koalaman/shellcheck/blob/master/src/ShellCheck/Parser.hs
            [
              "sh"
              "ash"
              "bash"
              "bats"
              "dash"
              "ksh"
              "shell"
            ];
          entry = "${tools.shellcheck}/bin/shellcheck";
        };
      terraform-format =
        {
          name = "terraform-format";
          description = "Format terraform (.tf) files";
          entry = "${tools.terraform-fmt}/bin/terraform-fmt";
          files = "\\.tf$";
        };
      yamllint =
        {
          name = "yamllint";
          description = "Yaml linter";
          types = [ "file" "yaml" ];
          entry = "${tools.yamllint}/bin/yamllint";
        };
      rustfmt =
        {
          name = "rustfmt";
          description = "Format Rust code.";
          entry = "${tools.rustfmt}/bin/cargo-fmt fmt -- --check --color always";
          files = "\\.rs$";
          pass_filenames = false;
        };
      clippy =
        {
          name = "clippy";
          description = "Lint Rust code.";
          entry = "${tools.clippy}/bin/cargo-clippy clippy";
          files = "\\.rs$";
          pass_filenames = false;
        };
      cargo-check =
        {
          name = "cargo-check";
          description = "Check the cargo package for errors";
          entry = "${tools.cargo}/bin/cargo check";
          files = "\\.rs$";
          pass_filenames = false;
        };
      purty =
        {
          name = "purty";
          description = "Format purescript files";
          entry = "${tools.purty}/bin/purty";
          files = "\\.purs$";
        };
      prettier =
        {
          name = "prettier";
          description = "Opinionated multi-language code formatter";
          entry = "${settings.prettier.binPath} --write --list-different --ignore-unknown";
          types = [ "text" ];
        };
      hunspell =
        {
          name = "hunspell";
          description = "Spell checker and morphological analyzer";
          entry = "${tools.hunspell}/bin/hunspell -l";
          files = "\\.((txt)|(html)|(xml)|(md)|(rst)|(tex)|(odf)|\\d)$";
        };
      html-tidy =
        {
          name = "html-tidy";
          description = "HTML linter";
          entry = "${tools.html-tidy}/bin/tidy -quiet -errors";
          files = "\\.html$";
        };
    };
}
