{ config, lib, pkgs, hookModule, ... }:
let
  cfg = config;
  inherit (lib) flatten mapAttrsToList mkOption mkRemovedOptionModule mkRenamedOptionModule types;

  # Helper function to create hook options with unified descriptions
  # Takes an attribute set: { name, description, modules, [specialArgs], [visible], ... }
  mkHook = module: description:
    mkOption {
      inherit description;
      type = types.submoduleWith ({
        modules = [ hookModule ] ++ [
          module
          # Set name and description
          ({ name, ... }: { config = { inherit name description; }; })
        ];
      });
      default = { };
    };
in
{
  imports =
    # Rename `settings.<name>.package` to `hooks.<name>.package`
    map (name: mkRenamedOptionModule [ "settings" name "package" ] [ "hooks" name "package" ]) [ "alejandra" "eclint" "flynt" "mdl" "treefmt" ]
    # These options were renamed in 20fbe2c9731810b1020572a2cb6cbf64e3dd3873 to avoid shadowing
    ++ map (name: mkRenamedOptionModule [ "settings" name "config" ] [ "hooks" name "settings" "configuration" ]) [ "lua-ls" "markdownlint" "typos" "vale" ]
    ++ [
      (mkRemovedOptionModule [ "settings" "yamllint" "relaxed" ] ''
        This option has been removed. Use `hooks.yamllint.settings.preset = "relaxed"`.
      '')
    ]
    # Manually rename options that had a package or a config option
    ++ flatten (mapAttrsToList (name: map (o: mkRenamedOptionModule [ "settings" name o ] [ "hooks" name "settings" o ])) {
      "alejandra" = [ "check" "exclude" "threads" "verbosity" ];
      "eclint" = [ "fix" "summary" "color" "exclude" "verbosity" ];
      "flynt" = [ "aggressive" "binPath" "dry-run" "exclude" "fail-on-change" "line-length" "no-multiline" "quiet" "string" "transform-concats" "verbose" ];
      "mdl" = [ "configPath" "git-recurse" "ignore-front-matter" "json" "rules" "rulesets" "show-aliases" "warnings" "skip-default-ruleset" "style" "tags" "verbose" ];
      "lua-ls" = [ "checklevel" ];
      "typos" = [ "binary" "color" "configPath" "diff" "exclude" "format" "hidden" "ignored-words" "locale" "no-check-filenames" "no-check-files" "no-unicode" "quiet" "verbose" "write" ];
      "vale" = [ "configPath" "flags" ];
      "yamllint" = [ "configPath" ];
    })
    # Rename `rome` hook to `biome`, since `biome` was being used in both hooks
    ++ [ (mkRenamedOptionModule [ "settings" "rome" ] [ "hooks" "biome" "settings" ]) ]
    # Rename the remaining `settings.<name>` to `hooks.<name>.settings`
    ++ map (name: mkRenamedOptionModule [ "settings" name ] [ "hooks" name "settings" ])
      [ "ansible-lint" "autoflake" "biome" "clippy" "cmake-format" "credo" "deadnix" "denofmt" "denolint" "dune-fmt" "eslint" "flake8" "headache" "hlint" "hpack" "isort" "latexindent" "lychee" "mkdocs-linkcheck" "mypy" "nixfmt" "ormolu" "php-cs-fixer" "phpcbf" "phpcs" "phpstan" "prettier" "psalm" "pylint" "pyright" "pyupgrade" "revive" "statix" ];

  options.hookModule = lib.mkOption {
    type = types.deferredModule;
    internal = true;
    description = ''
      Base module that must be loaded into each hook.
    '';
  };

  config.hookModule = {
    imports = [ ./hook.nix ];
    config._module.args = {
      inherit (cfg) default_stages settings tools;
      mkCmdArgs = predActionList:
        lib.concatStringsSep
          " "
          (builtins.foldl'
            (acc: entry:
              acc ++ lib.optional (builtins.elemAt entry 0) (builtins.elemAt entry 1))
            [ ]
            predActionList);

      migrateBinPathToPackage = hook: binPath:
        if hook.settings.binPath == null
        then "${hook.package}${binPath}"
        else hook.settings.binPath;

    };
  };
  config._module.args.hookModule = config.hookModule;

  # PLEASE keep this sorted alphabetically.
  options.settings = {
    rust = {
      check.cargoDeps = mkOption {
        type = types.nullOr types.attrs;
        description = "Cargo dependencies needed to run the checks.";
        example = "pkgs.rustPlatform.importCargoLock { lockFile = ./Cargo.lock; }";
        default = null;
      };
      cargoManifestPath = mkOption {
        type = types.nullOr types.str;
        description = "Path to Cargo.toml";
        default = null;
      };
    };
  };

  # PLEASE keep this sorted alphabetically.
  options.hooks =
    {
      actionlint = mkHook ./hooks/actionlint.nix "Static checker for GitHub Actions workflow files";
      alejandra = mkHook ./hooks/alejandra.nix "The Uncompromising Nix Code Formatter";
      annex = mkHook ./hooks/annex.nix "Runs the git-annex hook for large file support";
      ansible-lint = mkHook ./hooks/ansible-lint.nix "Ansible linter";
      autoflake = mkHook ./hooks/autoflake.nix "Remove unused imports and variables from Python code";
      bats = mkHook ./hooks/bats.nix "Run bash unit tests";
      beautysh = mkHook ./hooks/beautysh.nix "Format shell files";
      biome = mkHook ./hooks/biome.nix "A toolchain for web projects, aimed to provide functionalities to maintain them";
      black = mkHook ./hooks/black.nix "The uncompromising Python code formatter";
      cabal-fmt = mkHook ./hooks/cabal-fmt.nix "Format Cabal files";
      cabal-gild = mkHook ./hooks/cabal-gild.nix "Format Cabal files";
      cabal2nix = mkHook ./hooks/cabal2nix.nix "Run `cabal2nix` on all `*.cabal` files to generate corresponding `.nix` files";
      cargo-check = mkHook ./hooks/cargo-check.nix "Check the cargo package for errors";
      check-added-large-files = mkHook ./hooks/check-added-large-files.nix "Prevent very large files to be committed (e.g. binaries).";
      check-builtin-literals = mkHook ./hooks/check-builtin-literals.nix "Require literal syntax when initializing empty or zero builtin types in Python.";
      check-case-conflicts = mkHook ./hooks/check-case-conflicts.nix "Check for files that would conflict in case-insensitive filesystems.";
      check-docstring-first = mkHook ./hooks/check-docstring-first.nix "Check that all docstrings appear above the code.";
      check-executables-have-shebangs = mkHook ./hooks/check-executables-have-shebangs.nix "Ensure that all non-binary executables have shebangs.";
      check-json = mkHook ./hooks/check-json.nix "Check syntax of JSON files.";
      check-merge-conflicts = mkHook ./hooks/check-merge-conflicts.nix "Check for files that contain merge conflict strings.";
      check-python = mkHook ./hooks/check-python.nix "Check syntax of Python file by parsing Python abstract syntax tree.";
      check-shebang-scripts-are-executable = mkHook ./hooks/check-shebang-scripts-are-executable.nix "Ensure that all (non-binary) files with a shebang are executable.";
      check-symlinks = mkHook ./hooks/check-symlinks.nix "Find broken symlinks.";
      check-toml = mkHook ./hooks/check-toml.nix "Check syntax of TOML files.";
      check-vcs-permalinks = mkHook ./hooks/check-vcs-permalinks.nix "Ensure that links to VCS websites are permalinks.";
      check-xml = mkHook ./hooks/check-xml.nix "Check syntax of XML files.";
      check-yaml = mkHook ./hooks/check-yaml.nix "Check syntax of YAML files.";
      checkmake = mkHook ./hooks/checkmake.nix "Experimental linter/analyzer for Makefiles";
      chktex = mkHook ./hooks/chktex.nix "LaTeX semantic checker";
      cljfmt = mkHook ./hooks/cljfmt.nix "A tool for formatting Clojure code.";
      circleci = mkHook ./hooks/circleci.nix "Validate CircleCI config files.";
      clang-format = mkHook ./hooks/clang-format.nix "Format your code using `clang-format`.";
      clang-tidy = mkHook ./hooks/clang-tidy.nix "Static analyzer for C++ code.";
      clippy = mkHook ./hooks/clippy.nix "Lint Rust code.";
      cmake-format = mkHook ./hooks/cmake-format.nix "A tool for formatting CMake-files.";
      commitizen = mkHook ./hooks/commitizen.nix "Check whether the current commit message follows committing rules.";
      conform = mkHook ./hooks/conform.nix "Policy enforcement for commits.";
      convco = mkHook ./hooks/convco.nix "A tool for checking and creating conventional commits";
      credo = mkHook ./hooks/credo.nix "Runs a static code analysis using Credo";
      crystal = mkHook ./hooks/crystal.nix "A tool that automatically formats Crystal source code";
      cspell = mkHook ./hooks/cspell.nix "A Spell Checker for Code";
      dart-analyze = mkHook ./hooks/dart-analyze.nix "Dart analyzer";
      dart-format = mkHook ./hooks/dart-format.nix "Dart formatter";
      deadnix = mkHook ./hooks/deadnix.nix "Scan Nix files for dead code (unused variable bindings).";
      detect-aws-credentials = mkHook ./hooks/detect-aws-credentials.nix "Detect AWS credentials from the AWS cli credentials file.";
      detect-private-keys = mkHook ./hooks/detect-private-keys.nix "Detect the presence of private keys.";
      dhall-format = mkHook ./hooks/dhall-format.nix "Dhall code formatter.";
      dialyzer = mkHook ./hooks/dialyzer.nix "Runs a static code analysis using Dialyzer";
      denofmt = mkHook ./hooks/denofmt.nix "Auto-format JavaScript, TypeScript, Markdown, and JSON files.";
      denolint = mkHook ./hooks/denolint.nix "Lint JavaScript/TypeScript source code.";
      dune-fmt = mkHook ./hooks/dune-fmt.nix "Runs dune-build-opam-files to ensure OCaml and Dune are in sync";
      dune-opam-sync = mkHook ./hooks/dune-opam-sync.nix "Check that Dune-generated OPAM files are in sync.";
      eclint = mkHook ./hooks/eclint.nix "EditorConfig linter written in Go.";
      editorconfig-checker = mkHook ./hooks/editorconfig-checker.nix "Verify that the files are in harmony with the `.editorconfig`.";
      elm-format = mkHook ./hooks/elm-format.nix "Format Elm files.";
      elm-review = mkHook ./hooks/elm-review.nix "Analyzes Elm projects, to help find mistakes before your users find them.";
      elm-test = mkHook ./hooks/elm-test.nix "Run unit tests and fuzz tests for Elm code.";
      end-of-file-fixer = mkHook ./hooks/end-of-file-fixer.nix "Ensures that a file is either empty, or ends with a single newline.";
      eslint = mkHook ./hooks/eslint.nix "Find and fix problems in your JavaScript code.";
      flake8 = mkHook ./hooks/flake8.nix "Check the style and quality of Python files.";
      fix-byte-order-marker = mkHook ./hooks/fix-byte-order-marker.nix "Remove UTF-8 byte order marker.";
      fix-encoding-pragma = mkHook ./hooks/fix-encoding-pragma.nix "Adds # -*- coding: utf-8 -*- to the top of Python files.";
      flake-checker = mkHook ./hooks/flake-checker.nix "Run health checks on your flake-powered Nix projects.";
      flynt = mkHook ./hooks/flynt.nix "CLI tool to convert a python project's %-formatted strings to f-strings.";
      fourmolu = mkHook ./hooks/fourmolu.nix "Haskell code prettifier.";
      forbid-new-submodules = mkHook ./hooks/forbid-new-submodules.nix "Prevent addition of new Git submodules.";
      fprettify = mkHook ./hooks/fprettify.nix "Auto-formatter for modern Fortran code.";
      gitlint = mkHook ./hooks/gitlint.nix "Linting for your git commit messages";
      gofmt = mkHook ./hooks/gofmt.nix "A tool that automatically formats Go source code";
      golangci-lint = mkHook ./hooks/golangci-lint.nix "Fast linters runner for Go.";
      golines = mkHook ./hooks/golines.nix "A golang formatter that fixes long lines";
      gotest = mkHook ./hooks/gotest.nix "Run go tests";
      govet = mkHook ./hooks/govet.nix "Checks correctness of Go programs.";
      gptcommit = mkHook ./hooks/gptcommit.nix "Generate a commit message using GPT3.";
      hadolint = mkHook ./hooks/hadolint.nix "Dockerfile linter, validate inline bash.";
      headache = mkHook ./hooks/headache.nix "Lightweight tool for managing headers in source code files.";
      hlint = mkHook ./hooks/hlint.nix "Haskell linter";
      hpack = mkHook ./hooks/hpack.nix "A modern format for Haskell packages";
      isort = mkHook ./hooks/isort.nix "A Python utility/library to sort imports.";
      lacheck = mkHook ./hooks/lacheck.nix "LaTeX checker";
      latexindent = mkHook ./hooks/latexindent.nix "Perl script to add indentation to LaTeX files";
      lua-ls = mkHook ./hooks/lua-ls.nix "Lua language server";
      lychee = mkHook ./hooks/lychee.nix "Fast, async, stream-based link checker";
      markdownlint = mkHook ./hooks/markdownlint.nix "Markdown linter";
      mdl = mkHook ./hooks/mdl.nix "Markdown linter";
      mkdocs-linkcheck = mkHook ./hooks/mkdocs-linkcheck.nix "MkDocs link checker";
      mypy = mkHook ./hooks/mypy.nix "Optional static type checker for Python";
      nixfmt = (mkHook ./hooks/nixfmt.nix "Deprecated nixfmt hook. Use nixfmt-classic or nixfmt-rfc-style instead.") // { visible = false; };
      nixfmt-classic = mkHook ./hooks/nixfmt-classic.nix "nixfmt (classic)";
      nixfmt-rfc-style = mkHook ./hooks/nixfmt-rfc-style.nix "nixfmt (RFC 166 style)";
      nixpkgs-fmt = mkHook ./hooks/nixpkgs-fmt.nix "Nix code formatter for nixpkgs.";
      no-commit-to-branch = mkHook ./hooks/no-commit-to-branch.nix "Protect specific branches from direct checkins";
      ormolu = mkHook ./hooks/ormolu.nix "Haskell source code formatter";
      php-cs-fixer = mkHook ./hooks/php-cs-fixer.nix "PHP coding standards fixer";
      phpcbf = mkHook ./hooks/phpcbf.nix "PHP code beautifier and fixer";
      phpcs = mkHook ./hooks/phpcs.nix "PHP code sniffer";
      phpstan = mkHook ./hooks/phpstan.nix "PHP static analysis tool";
      # See all CLI flags for prettier [here](https://prettier.io/docs/en/cli.html).
      # See all options for prettier [here](https://prettier.io/docs/en/options.html).
      prettier = mkHook ./hooks/prettier.nix "Prettier code formatter";
      pretty-format-json = mkHook ./hooks/pretty-format-json.nix "Pretty format JSON";
      proselint = mkHook ./hooks/proselint.nix "A linter for prose";
      psalm = mkHook ./hooks/psalm.nix "PHP static analysis tool";
      pylint = mkHook ./hooks/pylint.nix "Python static code analysis tool";
      pyright = mkHook ./hooks/pyright.nix "Static type checker for Python";
      pyupgrade = mkHook ./hooks/pyupgrade.nix "Upgrade syntax for newer versions of Python";
      reuse = mkHook ./hooks/reuse.nix "REUSE is a tool for compliance with the REUSE recommendations";
      revive = mkHook ./hooks/revive.nix "Fast, configurable, extensible, flexible, and beautiful linter for Go";
      ripsecrets = mkHook ./hooks/ripsecrets.nix "Prevent committing secret keys into your source code";
      rome = (mkHook ./hooks/rome.nix "Deprecated rome hook. Use biome instead.") // { visible = false; };
      rustfmt = mkHook ./hooks/rustfmt.nix ''
        Rust code formatter

        Override the `rustfmt` and `cargo` packages by setting `hooks.rustfmt.packageOverrides`.

        ```
        hooks.rustfmt.packageOverrides.cargo = pkgs.cargo;
        hooks.rustfmt.packageOverrides.rustfmt = pkgs.rustfmt;
        ```
      '';
      shfmt = mkHook ./hooks/shfmt.nix "A shell parser, formatter, and interpreter";
      sort-file-contents = mkHook ./hooks/sort-file-contents.nix "Sort file contents";
      statix = mkHook ./hooks/statix.nix "Lints and suggestions for the Nix programming language";
      treefmt = mkHook ./hooks/treefmt.nix ''
        One CLI to format the code tree

        Include any additional formatters configured by treefmt as `hooks.treefmt.settings.formatters`.

        ```
        hooks.treefmt.settings.formatters = [
          pkgs.nixpkgs-fmt
          pkgs.black
        ];
        ```

        Override `treefmt` itself by setting `hooks.treefmt.packageOverrides.treefmt`.

        ```
        hooks.treefmt.packageOverrides.treefmt = pkgs.treefmt;
        ```
      '';
      typos = mkHook ./hooks/typos.nix "Source code spell checker";
      vale = mkHook ./hooks/vale.nix "A command-line tool that brings code-like linting to prose";
      yamlfmt = mkHook ./hooks/yamlfmt.nix "YAML formatter";
      yamllint = mkHook ./hooks/yamllint.nix "YAML linter";
    };

  config.warnings =
    lib.optional cfg.hooks.rome.enable ''
      The hook `hooks.rome` has been renamed to `hooks.biome`.
    ''
    ++ lib.optional cfg.hooks.nixfmt.enable ''
      The hook `hooks.nixfmt` has been renamed to `hooks.nixfmt-classic`.

      The new RFC 166-style nixfmt is available as `hooks.nixfmt-rfc-style`.
    '';
}
