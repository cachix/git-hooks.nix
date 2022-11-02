{ config, lib, pkgs, ... }:
let
  inherit (config) tools settings;
  inherit (lib) mkOption types;
in
{
  options.settings =
    {
      hpack =
        {
          silent =
            mkOption {
              type = types.bool;
              description = "Should generation should be silent";
              default = false;
            };
        };
      ormolu =
        {
          defaultExtensions =
            mkOption {
              type = types.listOf types.str;
              description = "Haskell language extensions to enable";
              default = [ ];
            };
          cabalDefaultExtensions =
            mkOption {
              type = types.bool;
              description = "Use default-extensions from .cabal files";
              default = false;
            };
        };
      alejandra =
        {
          exclude =
            mkOption {
              type = types.listOf types.str;
              description = "Files or directories to exclude from formatting";
              default = [ ];
              example = [ "flake.nix" "./templates" ];
            };
        };
      deadnix =
        {
          fix =
            mkOption {
              type = types.bool;
              description = "Remove unused code and write to source file";
              default = false;
            };

          noLambdaArg =
            mkOption {
              type = types.bool;
              description = "Don't check lambda parameter arguments";
              default = false;
            };

          noLambdaPatternNames =
            mkOption {
              type = types.bool;
              description = "Don't check lambda pattern names (don't break nixpkgs callPackage)";
              default = false;
            };

          noUnderscore =
            mkOption {
              type = types.bool;
              description = "Don't check any bindings that start with a _";
              default = false;
            };

          quiet =
            mkOption {
              type = types.bool;
              description = "Don't print dead code report";
              default = false;
            };
        };
      statix =
        {
          format =
            mkOption {
              type = types.enum [ "stderr" "errfmt" "json" ];
              description = "Error Output format";
              default = "errfmt";
            };

          ignore =
            mkOption {
              type = types.listOf types.str;
              description = "Globs of file patterns to skip";
              default = [ ];
              example = [ "flake.nix" "_*" ];
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
      eslint =
        {
          binPath =
            mkOption {
              type = types.path;
              description =
                "Eslint binary path. E.g. if you want to use the eslint in node_modules, use ./node_modules/.bin/eslint";
              default = "${tools.eslint}/bin/eslint";
            };

          extensions =
            mkOption {
              type = types.str;
              description =
                "The pattern of files to run on, see https://pre-commit.com/#hooks-files";
              default = "\\.js$";
            };
        };
    };

  config.hooks =
    {
      actionlint =
        {
          name = "actionlint";
          description = "Static checker for GitHub Actions workflow files";
          files = "^.github/workflows/";
          types = [ "yaml" ];
          entry = "${tools.actionlint}/bin/actionlint";
        };
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
      cabal2nix =
        {
          name = "cabal2nix";
          description = "Run cabal2nix on all *.cabal files to generate corresponding default.nix files.";
          files = "\\.cabal$";
          entry = "${tools.cabal2nix-dir}/bin/cabal2nix-dir";
        };
      clang-format =
        {
          name = "clang-format";
          description = "Format your code using clang-format";
          entry = "${tools.clang-tools}/bin/clang-format -style=file -i";
          types = [ "file" ];
        };
      brittany =
        {
          name = "brittany";
          description = "Haskell source code formatter.";
          entry = "${tools.brittany}/bin/brittany --write-mode=inplace";
          files = "\\.l?hs$";
        };
      dhall-format = {
        name = "dhall-format";
        description = "Dhall code formatter";
        entry = "${tools.dhall}/bin/dhall format";
        files = "\\.dhall$";
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
          entry = "${tools.hpack-dir}/bin/hpack-dir --${if settings.hpack.silent then "silent" else "verbose"}";
          files = "(\\.l?hs$)|(^[^/]+\\.cabal$)|(^package\\.yaml$)";
        };
      isort =
        {
          name = "isort";
          description = "A Python utility / library to sort imports.";
          entry = "${pkgs.python3Packages.isort}/bin/isort";
          types = [ "file" "python" ];
        };
      latexindent =
        {
          name = "latexindent";
          description = "Perl script to add indentation to LaTeX files";
          types = [ "file" "tex" ];
          entry = "${tools.latexindent}/bin/latexindent --local --silent --modifyIfDifferent";
        };
      luacheck =
        {
          name = "luacheck";
          description = "A tool for linting and static analysis of Lua code";
          types = [ "file" "lua" ];
          entry = "${tools.luacheck}/bin/luacheck";
        };
      ormolu =
        {
          name = "ormolu";
          description = "Haskell code prettifier.";
          entry =
            let
              extensions =
                lib.escapeShellArgs (lib.concatMap (ext: [ "--ghc-opt" "-X${ext}" ]) settings.ormolu.defaultExtensions);
              cabalExtensions =
                if settings.ormolu.cabalDefaultExtensions then "--cabal-default-extensions" else "";
            in
            "${tools.ormolu}/bin/ormolu --mode inplace ${extensions} ${cabalExtensions}";
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
      chktex =
        {
          name = "chktex";
          description = "LaTeX semantic checker";
          types = [ "file" "tex" ];
          entry = "${tools.chktex}/bin/chktex";
        };
      stylish-haskell =
        {
          name = "stylish-haskell";
          description = "A simple Haskell code prettifier";
          entry = "${tools.stylish-haskell}/bin/stylish-haskell --inplace";
          files = "\\.l?hs$";
        };
      alejandra =
        {
          name = "alejandra";
          description = "The Uncompromising Nix Code Formatter";
          entry = with settings.alejandra;
            "${tools.alejandra}/bin/alejandra ${if (exclude != [ ]) then "-e ${lib.escapeShellArgs (lib.unique exclude)}" else ""}";
          files = "\\.nix$";
        };

      deadnix =
        {
          name = "deadnix";
          description = "Scan Nix files for dead code (unused variable bindings).";
          entry =
            let
              toArg = string: "--" + (lib.concatMapStringsSep "-" lib.toLower (lib.filter (x: x != "") (lib.flatten (lib.split "([[:upper:]]+[[:lower:]]+)" string))));
              args = lib.concatMapStringsSep " " toArg (lib.filter (attr: settings.deadnix."${attr}") (lib.attrNames settings.deadnix));
            in
            "${tools.deadnix}/bin/deadnix ${args} --fail --";
          files = "\\.nix$";
        };
      mdsh =
        let
          script = pkgs.writeShellScript "precommit-mdsh" ''
            for file in $(echo "$@"); do
                ${tools.mdsh}/bin/mdsh -i $file"
            done
          '';
        in
        {
          name = "mdsh";
          description = "Markdown shell pre-processor.";
          entry = toString script;
          files = "\\.md$";
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
      statix =
        {
          name = "statix";
          description = "Lints and suggestions for the Nix programming language.";
          entry = with settings.statix;
            "${tools.statix}/bin/statix check -o ${format} ${if (ignore != [ ]) then "-i ${lib.escapeShellArgs (lib.unique ignore)}" else ""}";
          files = "\\.nix$";
          pass_filenames = false;
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
          name = "elm-test";
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
            ];
          entry = "${tools.shellcheck}/bin/shellcheck";
        };
      stylua =
        {
          name = "stylua";
          description = "An Opinionated Lua Code Formatter";
          types = [ "file" "lua" ];
          entry = "${tools.stylua}/bin/stylua";
        };
      shfmt =
        {
          name = "shfmt";
          description = "Format shell files";
          types = [ "shell" ];
          entry = "${tools.shfmt}/bin/shfmt -w -s -l";
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
        let
          wrapper = pkgs.symlinkJoin {
            name = "rustfmt-wrapped";
            paths = [ tools.rustfmt ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/cargo-fmt \
                --prefix PATH : ${lib.makeBinPath [ tools.cargo tools.rustfmt ]}
            '';
          };
        in
        {
          name = "rustfmt";
          description = "Format Rust code.";
          entry = "${wrapper}/bin/cargo-fmt fmt -- --check --color always";
          files = "\\.rs$";
          pass_filenames = false;
        };
      clippy =
        let
          wrapper = pkgs.symlinkJoin {
            name = "clippy-wrapped";
            paths = [ tools.clippy ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/cargo-clippy \
                --prefix PATH : ${lib.makeBinPath [ tools.cargo ]}
            '';
          };
        in
        {
          name = "clippy";
          description = "Lint Rust code.";
          entry = "${wrapper}/bin/cargo-clippy clippy";
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

      eslint =
        {
          name = "eslint";
          description = "Find and fix problems in your JavaScript code";
          entry = "${settings.eslint.binPath} --fix";
          files = "${settings.eslint.extensions}";
        };

      hadolint =
        {
          name = "hadolint";
          description = "Dockerfile linter, validate inline bash";
          entry = "${tools.hadolint}/bin/hadolint";
          files = "Dockerfile$";
        };

      markdownlint =
        {
          name = "markdownlint";
          description = "Style checker and linter for markdown files";
          entry = "${tools.markdownlint-cli}/bin/markdownlint";
          files = "\\.md$";
        };

      govet =
        let
          script = pkgs.writeShellScript "precommit-govet" ''
            for dir in $(echo "$@" | xargs -n1 dirname | sort -u); do
                ${tools.go}/bin/go vet ./"$dir"
            done
          '';
        in
        {
          name = "govet";
          description = "Checks correctness of Go programs";
          entry = builtins.toString script;
          raw = {
            # go vet requires package (directory) names as inputs. To avoid
            # calculating the same directory more than once, we want to have all
            # filenames in a single entry invocation.
            require_serial = true;
          };
          files = "\\.go$";
        };
    };
}
