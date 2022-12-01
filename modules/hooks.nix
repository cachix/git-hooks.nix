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
              description = lib.mdDoc "Whether generation should be silent.";
              default = false;
            };
        };
      ormolu =
        {
          defaultExtensions =
            mkOption {
              type = types.listOf types.str;
              description = lib.mdDoc "Haskell language extensions to enable.";
              default = [ ];
            };
          cabalDefaultExtensions =
            mkOption {
              type = types.bool;
              description = lib.mdDoc "Use `default-extensions` from `.cabal` files.";
              default = false;
            };
        };
      alejandra =
        {
          exclude =
            mkOption {
              type = types.listOf types.str;
              description = lib.mdDoc "Files or directories to exclude from formatting.";
              default = [ ];
              example = [ "flake.nix" "./templates" ];
            };
        };
      deadnix =
        {
          edit =
            mkOption {
              type = types.bool;
              description = lib.mdDoc "Remove unused code and write to source file.";
              default = false;
            };

          noLambdaArg =
            mkOption {
              type = types.bool;
              description = lib.mdDoc "Don't check lambda parameter arguments.";
              default = false;
            };

          noLambdaPatternNames =
            mkOption {
              type = types.bool;
              description = lib.mdDoc "Don't check lambda pattern names (don't break nixpkgs `callPackage`).";
              default = false;
            };

          noUnderscore =
            mkOption {
              type = types.bool;
              description = lib.mdDoc "Don't check any bindings that start with a `_`.";
              default = false;
            };

          quiet =
            mkOption {
              type = types.bool;
              description = lib.mdDoc "Don't print a dead code report.";
              default = false;
            };
        };
      statix =
        {
          format =
            mkOption {
              type = types.enum [ "stderr" "errfmt" "json" ];
              description = lib.mdDoc "Error Output format.";
              default = "errfmt";
            };

          ignore =
            mkOption {
              type = types.listOf types.str;
              description = lib.mdDoc "Globs of file patterns to skip.";
              default = [ ];
              example = [ "flake.nix" "_*" ];
            };
        };
      markdownlint = {
        config =
          mkOption {
            type = types.attrs;
            description = lib.mdDoc
              "See https://github.com/DavidAnson/markdownlint/blob/main/schema/.markdownlint.jsonc";
            default = { };
          };
      };
      nix-linter =
        {
          checks =
            mkOption {
              type = types.listOf types.str;
              description = lib.mdDoc
                "Available checks. See `nix-linter --help-for [CHECK]` for more details.";
              default = [ ];
            };
        };
      nixfmt =
        {
          width =
            mkOption {
              type = types.nullOr types.int;
              description = lib.mdDoc "Line width.";
              default = null;
            };
        };
      prettier =
        {
          binPath =
            mkOption {
              type = types.path;
              description = lib.mdDoc
                "`prettier` binary path. E.g. if you want to use the `prettier` in `node_modules`, use `./node_modules/.bin/prettier`.";
              default = "${tools.prettier}/bin/prettier";
              defaultText = lib.literalExpression ''
                "''${tools.prettier}/bin/prettier"
              '';
            };

          write =
            mkOption {
              type = types.bool;
              description = lib.mdDoc "Whether to edit files inplace.";
              default = true;
            };

          output =
            mkOption {
              description = lib.mdDoc "Output format.";
              type = types.nullOr types.enum [ "check" "list-diffrent" ];
              default = "list-different";
            };
        };
      eslint =
        {
          binPath =
            mkOption {
              type = types.path;
              description = lib.mdDoc
                "`eslint` binary path. E.g. if you want to use the `eslint` in `node_modules`, use `./node_modules/.bin/eslint`.";
              default = "${tools.eslint}/bin/eslint";
              defaultText = lib.literalExpression "\${tools.eslint}/bin/eslint";
            };

          extensions =
            mkOption {
              type = types.str;
              description = lib.mdDoc
                "The pattern of files to run on, see [https://pre-commit.com/#hooks-files](https://pre-commit.com/#hooks-files).";
              default = "\\.js$";
            };
        };
      typos =
        {
          write =
            mkOption {
              type = types.bool;
              description = lib.mdDoc "Whether to write fixes out.";
              default = false;
            };

          diff =
            mkOption {
              type = types.bool;
              description = lib.mdDoc "Wheter to print a diff of what would change.";
              default = false;
            };

          format =
            mkOption {
              type = types.enum [ "silent" "brief" "long" "json" ];
              description = lib.mdDoc "Output format.";
              default = "long";
            };
        };

      revive =
        {
          configPath =
            mkOption {
              type = types.str;
              description = lib.mdDoc "Path to the configuration TOML file.";
              # an empty string translates to use default configuration of the
              # underlying revive binary
              default = "";
            };

        };
    };

  config.hooks =
    {
      actionlint =
        {
          name = "actionlint";
          description = "Static checker for GitHub Actions workflow files.";
          files = "^.github/workflows/";
          types = [ "yaml" ];
          entry = "${tools.actionlint}/bin/actionlint";
        };
      ansible-lint =
        {
          name = "ansible-lint";
          description =
            "Ansible linter.";
          entry = "${tools.ansible-lint}/bin/ansible-lint";
        };
      black =
        {
          name = "black";
          description = "The uncompromising Python code formatter.";
          entry = "${pkgs.python3Packages.black}/bin/black";
          types = [ "file" "python" ];
        };
      cabal2nix =
        {
          name = "cabal2nix";
          description = "Run `cabal2nix` on all `*.cabal` files to generate corresponding `default.nix` files.";
          files = "\\.cabal$";
          entry = "${tools.cabal2nix-dir}/bin/cabal2nix-dir";
        };
      clang-format =
        {
          name = "clang-format";
          description = "Format your code using `clang-format`.";
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
        description = "Dhall code formatter.";
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
            "`hpack` converts package definitions in the hpack format (`package.yaml`) to Cabal files.";
          entry = "${tools.hpack-dir}/bin/hpack-dir --${if settings.hpack.silent then "silent" else "verbose"}";
          files = "(\\.l?hs$)|(^[^/]+\\.cabal$)|(^package\\.yaml$)";
          # We don't pass filenames because they can only be misleading.
          # Indeed, we need to rerun `hpack` in every directory:
          # 1. In which there is a *.cabal file, or
          # 2. Below which there are haskell files, or
          # 3. In which there is a package.yaml that references haskell files
          #    that have been changed at arbitrary locations specified in that
          #    file. 
          # In other words: We have no choice but to always run `hpack` on every `package.yaml` directory.
          pass_filenames = false;
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
          description = "Perl script to add indentation to LaTeX files.";
          types = [ "file" "tex" ];
          entry = "${tools.latexindent}/bin/latexindent --local --silent --modifyIfDifferent";
        };
      luacheck =
        {
          name = "luacheck";
          description = "A tool for linting and static analysis of Lua code.";
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
          description = "The Uncompromising Nix Code Formatter.";
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
              toArg = string: "--" + (lib.concatMapStringsSep "-" lib.toLower (lib.filter (x: x != "") (lib.flatten (builtins.split "([[:upper:]]+[[:lower:]]+)" string))));
              args = lib.concatMapStringsSep " " toArg (lib.filter (attr: settings.deadnix."${attr}") (lib.attrNames settings.deadnix));
            in
            "${tools.deadnix}/bin/deadnix ${args} --fail --";
          files = "\\.nix$";
        };
      mdsh =
        let
          script = pkgs.writeShellScript "precommit-mdsh" ''
            for file in $(echo "$@"); do
                ${tools.mdsh}/bin/mdsh -i "$file"
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
          entry = "${tools.nixfmt}/bin/nixfmt ${lib.optionalString (settings.nixfmt.width != null) "--width=${toString settings.nixfmt.width}"}";
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
          description = "Format Elm files.";
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
          description = "Run unit tests and fuzz tests for Elm code.";
          entry = "${tools.elm-test}/bin/elm-test";
          files = "\\.elm$";
          pass_filenames = false;
        };
      shellcheck =
        {
          name = "shellcheck";
          description = "Format shell files.";
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
          description = "An Opinionated Lua Code Formatter.";
          types = [ "file" "lua" ];
          entry = "${tools.stylua}/bin/stylua";
        };
      shfmt =
        {
          name = "shfmt";
          description = "Format shell files.";
          types = [ "shell" ];
          entry = "${tools.shfmt}/bin/shfmt -w -s -l";
        };
      terraform-format =
        {
          name = "terraform-format";
          description = "Format terraform (`.tf`) files.";
          entry = "${tools.terraform-fmt}/bin/terraform-fmt";
          files = "\\.tf$";
        };
      yamllint =
        {
          name = "yamllint";
          description = "Yaml linter.";
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
          description = "Check the cargo package for errors.";
          entry = "${tools.cargo}/bin/cargo check";
          files = "\\.rs$";
          pass_filenames = false;
        };
      purty =
        {
          name = "purty";
          description = "Format purescript files.";
          entry = "${tools.purty}/bin/purty";
          files = "\\.purs$";
        };
      purs-tidy =
        {
          name = "purs-tidy";
          description = "Format purescript files.";
          entry = "${tools.purs-tidy}/bin/purs-tidy format-in-place";
          files = "\\.purs$";
        };
      prettier =
        {
          name = "prettier";
          description = "Opinionated multi-language code formatter.";
          entry = with settings.prettier;
            "${binPath} ${lib.optionalString write "--write"} ${lib.optionalString (output != null) "--${output}"} --ignore-unknown";
          types = [ "text" ];
        };
      hunspell =
        {
          name = "hunspell";
          description = "Spell checker and morphological analyzer.";
          entry = "${tools.hunspell}/bin/hunspell -l";
          files = "\\.((txt)|(html)|(xml)|(md)|(rst)|(tex)|(odf)|\\d)$";
        };
      typos =
        {
          name = "typos";
          description = "Source code spell checker";
          entry = with settings.typos;
            "${tools.typos}/bin/typos --format ${format} ${lib.optionalString write "-w"} ${lib.optionalString diff "--diff"}";
        };
      html-tidy =
        {
          name = "html-tidy";
          description = "HTML linter.";
          entry = "${tools.html-tidy}/bin/tidy -quiet -errors";
          files = "\\.html$";
        };

      eslint =
        {
          name = "eslint";
          description = "Find and fix problems in your JavaScript code.";
          entry = "${settings.eslint.binPath} --fix";
          files = "${settings.eslint.extensions}";
        };

      hadolint =
        {
          name = "hadolint";
          description = "Dockerfile linter, validate inline bash.";
          entry = "${tools.hadolint}/bin/hadolint";
          files = "Dockerfile$";
        };

      markdownlint =
        {
          name = "markdownlint";
          description = "Style checker and linter for markdown files.";
          entry = "${tools.markdownlint-cli}/bin/markdownlint -c ${pkgs.writeText "markdownlint.json" (builtins.toJSON settings.markdownlint.config)}";
          files = "\\.md$";
        };

      govet =
        {
          name = "govet";
          description = "Checks correctness of Go programs.";
          entry =
            let
              # go vet requires package (directory) names as inputs.
              script = pkgs.writeShellScript "precommit-govet" ''
                set -e
                for dir in $(echo "$@" | xargs -n1 dirname | sort -u); do
                  ${tools.go}/bin/go vet ./"$dir"
                done
              '';
            in
            builtins.toString script;
          raw = {
            # to avoid multiple invocations of the same directory input, provide
            # all file names in a single run.
            require_serial = true;
          };
          files = "\\.go$";
        };

      revive =
        {
          name = "revive";
          description = "A linter for Go source code.";
          entry =
            let
              cmdArgs =
                lib.concatStringsSep
                  " "
                  (builtins.concatLists [
                    [ "-set_exit_status" ]
                    (if settings.revive.configPath != "" then
                      [ "-config ${settings.revive.configPath}" ]
                    else
                      [ ])
                  ]
                  );
              # revive works with both files and directories; however some lints
              # may fail (e.g. package-comment) if they run on an individual file
              # rather than a package/directory scope; given this let's get the
              # directories from each individual file.
              script = pkgs.writeShellScript "precommit-revive" ''
                set -e
                for dir in $(echo "$@" | xargs -n1 dirname | sort -u); do
                  ${tools.revive}/bin/revive ${cmdArgs} ./"$dir"
                done
              '';
            in
            builtins.toString script;
          files = "\\.go$";
          raw = {
            # to avoid multiple invocations of the same directory input, provide
            # all file names in a single run.
            require_serial = true;
          };
        };

    };
}
