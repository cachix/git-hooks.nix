{ config, lib, pkgs, hookModule, ... }:
let
  cfg = config;
  inherit (lib) flatten mapAttrsToList mkOption mkRemovedOptionModule mkRenamedOptionModule types;

  # Helper function to create hook options with unified descriptions
  # Takes an attribute set: { name, description, modules, [specialArgs], [visible], ... }
  mkHook = { name, description, modules, specialArgs ? { }, ... }@args:
    let
      optionArgs = builtins.removeAttrs args [ "name" "description" "modules" "specialArgs" ];
    in
    mkOption ({
      inherit description;
      type = types.submoduleWith ({
        inherit specialArgs;
        modules = [ hookModule ] ++ modules ++ [
          { config.description = lib.mkDefault description; }
        ];
      });
      default = { };
    } // optionArgs);
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
      inherit (cfg) default_stages tools;
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
      actionlint = mkHook { name = "actionlint"; description = "Static checker for GitHub Actions workflow files"; modules = [ ./hooks/actionlint.nix ]; };
      alejandra = mkHook { name = "alejandra"; description = "The Uncompromising Nix Code Formatter"; modules = [ ./hooks/alejandra.nix ]; };
      annex = mkHook { name = "annex"; description = "Runs the git-annex hook for large file support"; modules = [ ./hooks/annex.nix ]; };
      ansible-lint = mkHook { name = "ansible-lint"; description = "Ansible linter"; modules = [ ./hooks/ansible-lint.nix ]; };
      autoflake = mkHook { name = "autoflake"; description = "Remove unused imports and variables from Python code"; modules = [ ./hooks/autoflake.nix ]; };
      bats = mkHook { name = "bats"; description = "Run bash unit tests"; modules = [ ./hooks/bats.nix ]; };
      beautysh = mkHook { name = "beautysh"; description = "Format shell files"; modules = [ ./hooks/beautysh.nix ]; };
      biome = mkHook { name = "biome"; description = "A toolchain for web projects, aimed to provide functionalities to maintain them"; modules = [ ./hooks/biome.nix ]; };
      black = mkHook { name = "black"; description = "The uncompromising Python code formatter"; modules = [ ./hooks/black.nix ]; };
      cabal-fmt = mkHook { name = "cabal-fmt"; description = "Format Cabal files"; modules = [ ./hooks/cabal-fmt.nix ]; };
      cabal-gild = mkHook { name = "cabal-gild"; description = "Format Cabal files"; modules = [ ./hooks/cabal-gild.nix ]; };
      cabal2nix = mkHook { name = "cabal2nix"; description = "Run `cabal2nix` on all `*.cabal` files to generate corresponding `.nix` files"; modules = [ ./hooks/cabal2nix.nix ]; };
      cargo-check = mkHook { name = "cargo-check"; description = "Check the cargo package for errors"; modules = [ ./hooks/cargo-check.nix ]; };
      check-added-large-files = mkHook { name = "check-added-large-files"; description = "Prevent very large files to be committed (e.g. binaries)."; modules = [ ./hooks/check-added-large-files.nix ]; };
      check-builtin-literals = mkHook { name = "check-builtin-literals"; description = "Require literal syntax when initializing empty or zero builtin types in Python."; modules = [ ./hooks/check-builtin-literals.nix ]; };
      check-case-conflicts = mkHook { name = "check-case-conflicts"; description = "Check for files that would conflict in case-insensitive filesystems."; modules = [ ./hooks/check-case-conflicts.nix ]; };
      check-docstring-first = mkHook { name = "check-docstring-first"; description = "Check that all docstrings appear above the code."; modules = [ ./hooks/check-docstring-first.nix ]; };
      check-executables-have-shebangs = mkHook { name = "check-executables-have-shebangs"; description = "Ensure that all non-binary executables have shebangs."; modules = [ ./hooks/check-executables-have-shebangs.nix ]; };
      check-json = mkHook { name = "check-json"; description = "Check syntax of JSON files."; modules = [ ./hooks/check-json.nix ]; };
      check-merge-conflicts = mkHook { name = "check-merge-conflicts"; description = "Check for files that contain merge conflict strings."; modules = [ ./hooks/check-merge-conflicts.nix ]; };
      check-python = mkHook { name = "check-python"; description = "Check syntax of Python file by parsing Python abstract syntax tree."; modules = [ ./hooks/check-python.nix ]; };
      check-shebang-scripts-are-executable = mkHook { name = "check-shebang-scripts-are-executable"; description = "Ensure that all (non-binary) files with a shebang are executable."; modules = [ ./hooks/check-shebang-scripts-are-executable.nix ]; };
      check-symlinks = mkHook { name = "check-symlinks"; description = "Find broken symlinks."; modules = [ ./hooks/check-symlinks.nix ]; };
      check-toml = mkHook { name = "check-toml"; description = "Check syntax of TOML files."; modules = [ ./hooks/check-toml.nix ]; };
      check-vcs-permalinks = mkHook { name = "check-vcs-permalinks"; description = "Ensure that links to VCS websites are permalinks."; modules = [ ./hooks/check-vcs-permalinks.nix ]; };
      check-xml = mkHook { name = "check-xml"; description = "Check syntax of XML files."; modules = [ ./hooks/check-xml.nix ]; };
      check-yaml = mkHook { name = "check-yaml"; description = "Check syntax of YAML files."; modules = [ ./hooks/check-yaml.nix ]; };
      checkmake = mkHook { name = "checkmake"; description = "Experimental linter/analyzer for Makefiles"; modules = [ ./hooks/checkmake.nix ]; };
      chktex = mkHook { name = "chktex"; description = "LaTeX semantic checker"; modules = [ ./hooks/chktex.nix ]; };
      cljfmt = mkHook { name = "cljfmt"; description = "A tool for formatting Clojure code."; modules = [ ./hooks/cljfmt.nix ]; };
      circleci = mkHook { name = "circleci"; description = "Validate CircleCI config files."; modules = [ ./hooks/circleci.nix ]; };
      clang-format = mkHook { name = "clang-format"; description = "Format your code using `clang-format`."; modules = [ ./hooks/clang-format.nix ]; };
      clang-tidy = mkHook { name = "clang-tidy"; description = "Static analyzer for C++ code."; modules = [ ./hooks/clang-tidy.nix ]; };
      clippy = mkHook { name = "clippy"; description = "Lint Rust code."; modules = [ ./hooks/clippy.nix ]; };
      cmake-format = mkHook { name = "cmake-format"; description = "A tool for formatting CMake-files."; modules = [ ./hooks/cmake-format.nix ]; };
      commitizen = mkHook { name = "commitizen"; description = "Check whether the current commit message follows committing rules."; modules = [ ./hooks/commitizen.nix ]; };
      conform = mkHook { name = "conform"; description = "Policy enforcement for commits."; modules = [ ./hooks/conform.nix ]; };
      convco = mkHook { name = "convco"; description = "A tool for checking and creating conventional commits"; modules = [ ./hooks/convco.nix ]; };
      credo = mkHook { name = "credo"; description = "Runs a static code analysis using Credo"; modules = [ ./hooks/credo.nix ]; };
      crystal = mkHook { name = "crystal"; description = "A tool that automatically formats Crystal source code"; modules = [ ./hooks/crystal.nix ]; };
      cspell = mkHook { name = "cspell"; description = "A Spell Checker for Code"; modules = [ ./hooks/cspell.nix ]; };
      dart-analyze = mkHook { name = "dart-analyze"; description = "Dart analyzer"; modules = [ ./hooks/dart-analyze.nix ]; };
      dart-format = mkHook { name = "dart-format"; description = "Dart formatter"; modules = [ ./hooks/dart-format.nix ]; };
      deadnix = mkHook { name = "deadnix"; description = "Scan Nix files for dead code (unused variable bindings)."; modules = [ ./hooks/deadnix.nix ]; };
      detect-aws-credentials = mkHook { name = "detect-aws-credentials"; description = "Detect AWS credentials from the AWS cli credentials file."; modules = [ ./hooks/detect-aws-credentials.nix ]; };
      detect-private-keys = mkHook { name = "detect-private-keys"; description = "Detect the presence of private keys."; modules = [ ./hooks/detect-private-keys.nix ]; };
      dhall-format = mkHook { name = "dhall-format"; description = "Dhall code formatter."; modules = [ ./hooks/dhall-format.nix ]; };
      dialyzer = mkHook { name = "dialyzer"; description = "Runs a static code analysis using Dialyzer"; modules = [ ./hooks/dialyzer.nix ]; };
      denofmt = mkHook { name = "denofmt"; description = "Auto-format JavaScript, TypeScript, Markdown, and JSON files."; modules = [ ./hooks/denofmt.nix ]; };
      denolint = mkHook { name = "denolint"; description = "Lint JavaScript/TypeScript source code."; modules = [ ./hooks/denolint.nix ]; };
      dune-fmt = mkHook { name = "dune-fmt"; description = "Runs dune-build-opam-files to ensure OCaml and Dune are in sync"; modules = [ ./hooks/dune-fmt.nix ]; };
      dune-opam-sync = mkHook { name = "dune-opam-sync"; description = "Check that Dune-generated OPAM files are in sync."; modules = [ ./hooks/dune-opam-sync.nix ]; };
      eclint = mkHook { name = "eclint"; description = "EditorConfig linter written in Go."; modules = [ ./hooks/eclint.nix ]; };
      editorconfig-checker = mkHook { name = "editorconfig-checker"; description = "Verify that the files are in harmony with the `.editorconfig`."; modules = [ ./hooks/editorconfig-checker.nix ]; };
      elm-format = mkHook { name = "elm-format"; description = "Format Elm files."; modules = [ ./hooks/elm-format.nix ]; };
      elm-review = mkHook { name = "elm-review"; description = "Analyzes Elm projects, to help find mistakes before your users find them."; modules = [ ./hooks/elm-review.nix ]; };
      elm-test = mkHook { name = "elm-test"; description = "Run unit tests and fuzz tests for Elm code."; modules = [ ./hooks/elm-test.nix ]; };
      end-of-file-fixer = mkHook { name = "end-of-file-fixer"; description = "Ensures that a file is either empty, or ends with a single newline."; modules = [ ./hooks/end-of-file-fixer.nix ]; };
      eslint = mkHook { name = "eslint"; description = "Find and fix problems in your JavaScript code."; modules = [ ./hooks/eslint.nix ]; };
      flake8 = mkHook { name = "flake8"; description = "Check the style and quality of Python files."; modules = [ ./hooks/flake8.nix ]; };
      fix-byte-order-marker = mkHook { name = "fix-byte-order-marker"; description = "Remove UTF-8 byte order marker."; modules = [ ./hooks/fix-byte-order-marker.nix ]; };
      fix-encoding-pragma = mkHook { name = "fix-encoding-pragma"; description = "Adds # -*- coding: utf-8 -*- to the top of Python files."; modules = [ ./hooks/fix-encoding-pragma.nix ]; };
      flake-checker = mkHook { name = "flake-checker"; description = "Run health checks on your flake-powered Nix projects."; modules = [ ./hooks/flake-checker.nix ]; };
      flynt = mkHook { name = "flynt"; description = "CLI tool to convert a python project's %-formatted strings to f-strings."; modules = [ ./hooks/flynt.nix ]; };
      fourmolu = mkHook { name = "fourmolu"; description = "Haskell code prettifier."; modules = [ ./hooks/fourmolu.nix ]; };
      forbid-new-submodules = mkHook { name = "forbid-new-submodules"; description = "Prevent addition of new Git submodules."; modules = [ ./hooks/forbid-new-submodules.nix ]; };
      fprettify = mkHook { name = "fprettify"; description = "Auto-formatter for modern Fortran code."; modules = [ ./hooks/fprettify.nix ]; };
      gitlint = mkHook { name = "gitlint"; description = "Linting for your git commit messages"; modules = [ ./hooks/gitlint.nix ]; };
      gofmt = mkHook { name = "gofmt"; description = "A tool that automatically formats Go source code"; modules = [ ./hooks/gofmt.nix ]; };
      golangci-lint = mkHook { name = "golangci-lint"; description = "Fast linters runner for Go."; modules = [ ./hooks/golangci-lint.nix ]; };
      golines = mkHook { name = "golines"; description = "A golang formatter that fixes long lines"; modules = [ ./hooks/golines.nix ]; };
      gotest = mkHook { name = "gotest"; description = "Run go tests"; modules = [ ./hooks/gotest.nix ]; };
      govet = mkHook { name = "govet"; description = "Checks correctness of Go programs."; modules = [ ./hooks/govet.nix ]; };
      gptcommit = mkHook { name = "gptcommit"; description = "Generate a commit message using GPT3."; modules = [ ./hooks/gptcommit.nix ]; };
      hadolint = mkHook { name = "hadolint"; description = "Dockerfile linter, validate inline bash."; modules = [ ./hooks/hadolint.nix ]; };
      headache = mkHook { name = "headache"; description = "Lightweight tool for managing headers in source code files."; modules = [ ./hooks/headache.nix ]; };
      hlint = mkHook { name = "hlint"; description = "Haskell linter"; modules = [ ./hooks/hlint.nix ]; };
      hpack = mkHook { name = "hpack"; description = "A modern format for Haskell packages"; modules = [ ./hooks/hpack.nix ]; };
      isort = mkHook { name = "isort"; description = "A Python utility/library to sort imports."; modules = [ ./hooks/isort.nix ]; };
      lacheck = mkHook { name = "lacheck"; description = "LaTeX checker"; modules = [ ./hooks/lacheck.nix ]; };
      latexindent = mkHook { name = "latexindent"; description = "Perl script to add indentation to LaTeX files"; modules = [ ./hooks/latexindent.nix ]; };
      lua-ls = mkHook { name = "lua-ls"; description = "Lua language server"; modules = [ ./hooks/lua-ls.nix ]; };
      lychee = mkHook { name = "lychee"; description = "Fast, async, stream-based link checker"; modules = [ ./hooks/lychee.nix ]; };
      markdownlint = mkHook { name = "markdownlint"; description = "Markdown linter"; modules = [ ./hooks/markdownlint.nix ]; };
      mdl = mkHook { name = "mdl"; description = "Markdown linter"; modules = [ ./hooks/mdl.nix ]; };
      mkdocs-linkcheck = mkHook { name = "mkdocs-linkcheck"; description = "MkDocs link checker"; modules = [ ./hooks/mkdocs-linkcheck.nix ]; };
      mypy = mkHook { name = "mypy"; description = "Optional static type checker for Python"; modules = [ ./hooks/mypy.nix ]; };
      nixfmt = mkHook {
        name = "nixfmt";
        description = "Deprecated nixfmt hook. Use nixfmt-classic or nixfmt-rfc-style instead.";
        modules = [ ./hooks/nixfmt.nix ];
        visible = false;
      };
      nixfmt-classic = mkHook { name = "nixfmt-classic"; description = "nixfmt (classic)"; modules = [ ./hooks/nixfmt-classic.nix ]; };
      nixfmt-rfc-style = mkHook { name = "nixfmt-rfc-style"; description = "nixfmt (RFC 166 style)"; modules = [ ./hooks/nixfmt-rfc-style.nix ]; };
      nixpkgs-fmt = mkHook { name = "nixpkgs-fmt"; description = "Nix code formatter for nixpkgs."; modules = [ ./hooks/nixpkgs-fmt.nix ]; };
      no-commit-to-branch = mkHook { name = "no-commit-to-branch"; description = "Protect specific branches from direct checkins"; modules = [ ./hooks/no-commit-to-branch.nix ]; };
      ormolu = mkHook { name = "ormolu"; description = "Haskell source code formatter"; modules = [ ./hooks/ormolu.nix ]; };
      php-cs-fixer = mkHook { name = "php-cs-fixer"; description = "PHP coding standards fixer"; modules = [ ./hooks/php-cs-fixer.nix ]; };
      phpcbf = mkHook { name = "phpcbf"; description = "PHP code beautifier and fixer"; modules = [ ./hooks/phpcbf.nix ]; };
      phpcs = mkHook { name = "phpcs"; description = "PHP code sniffer"; modules = [ ./hooks/phpcs.nix ]; };
      phpstan = mkHook { name = "phpstan"; description = "PHP static analysis tool"; modules = [ ./hooks/phpstan.nix ]; };
      # See all CLI flags for prettier [here](https://prettier.io/docs/en/cli.html).
      # See all options for prettier [here](https://prettier.io/docs/en/options.html).
      prettier = mkHook { name = "prettier"; description = "Prettier code formatter"; modules = [ ./hooks/prettier.nix ]; };
      pretty-format-json = mkHook { name = "pretty-format-json"; description = "Pretty format JSON"; modules = [ ./hooks/pretty-format-json.nix ]; };
      proselint = mkHook { name = "proselint"; description = "A linter for prose"; modules = [ ./hooks/proselint.nix ]; };
      psalm = mkHook { name = "psalm"; description = "PHP static analysis tool"; modules = [ ./hooks/psalm.nix ]; };
      pylint = mkHook { name = "pylint"; description = "Python static code analysis tool"; modules = [ ./hooks/pylint.nix ]; };
      pyright = mkHook { name = "pyright"; description = "Static type checker for Python"; modules = [ ./hooks/pyright.nix ]; };
      pyupgrade = mkHook { name = "pyupgrade"; description = "Upgrade syntax for newer versions of Python"; modules = [ ./hooks/pyupgrade.nix ]; };
      reuse = mkHook { name = "reuse"; description = "REUSE is a tool for compliance with the REUSE recommendations"; modules = [ ./hooks/reuse.nix ]; };
      revive = mkHook { name = "revive"; description = "Fast, configurable, extensible, flexible, and beautiful linter for Go"; modules = [ ./hooks/revive.nix ]; };
      ripsecrets = mkHook { name = "ripsecrets"; description = "Prevent committing secret keys into your source code"; modules = [ ./hooks/ripsecrets.nix ]; };
      rome = mkHook {
        name = "rome";
        description = "Deprecated rome hook. Use biome instead.";
        modules = [ ./hooks/rome.nix ];
        visible = false;
      };
      rustfmt = mkHook {
        name = "rustfmt";
        description = ''
          Rust code formatter

          Override the `rustfmt` and `cargo` packages by setting `hooks.rustfmt.packageOverrides`.

          ```
          hooks.rustfmt.packageOverrides.cargo = pkgs.cargo;
          hooks.rustfmt.packageOverrides.rustfmt = pkgs.rustfmt;
          ```
        '';
        modules = [ ./hooks/rustfmt.nix ];
        specialArgs = { rustSettings = config.settings.rust; };
      };
      shfmt = mkHook { name = "shfmt"; description = "A shell parser, formatter, and interpreter"; modules = [ ./hooks/shfmt.nix ]; };
      sort-file-contents = mkHook { name = "sort-file-contents"; description = "Sort file contents"; modules = [ ./hooks/sort-file-contents.nix ]; };
      statix = mkHook { name = "statix"; description = "Lints and suggestions for the Nix programming language"; modules = [ ./hooks/statix.nix ]; };
      treefmt = mkHook {
        name = "treefmt";
        description = ''
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
        modules = [ ./hooks/treefmt.nix ];
      };
      typos = mkHook { name = "typos"; description = "Source code spell checker"; modules = [ ./hooks/typos.nix ]; };
      vale = mkHook { name = "vale"; description = "A command-line tool that brings code-like linting to prose"; modules = [ ./hooks/vale.nix ]; };
      yamlfmt = mkHook { name = "yamlfmt"; description = "YAML formatter"; modules = [ ./hooks/yamlfmt.nix ]; };
      yamllint = mkHook { name = "yamllint"; description = "YAML linter"; modules = [ ./hooks/yamllint.nix ]; };
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
