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
      inherit pkgs;
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
      circleci = mkHook ./hooks/circleci.nix "Validate CircleCI config files.";
      clang-format = mkHook ./hooks/clang-format.nix "Format your code using `clang-format`.";
      clang-tidy = mkHook ./hooks/clang-tidy.nix "Static analyzer for C++ code.";
      clippy = mkHook ./hooks/clippy.nix "Lint Rust code.";
      cljfmt = mkHook ./hooks/cljfmt.nix "A tool for formatting Clojure code.";
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
      denofmt = mkHook ./hooks/denofmt.nix "Auto-format JavaScript, TypeScript, Markdown, and JSON files.";
      denolint = mkHook ./hooks/denolint.nix "Lint JavaScript/TypeScript source code.";
      detect-aws-credentials = mkHook ./hooks/detect-aws-credentials.nix "Detect AWS credentials from the AWS cli credentials file.";
      detect-private-keys = mkHook ./hooks/detect-private-keys.nix "Detect the presence of private keys.";
      dhall-format = mkHook ./hooks/dhall-format.nix "Dhall code formatter.";
      dialyzer = mkHook ./hooks/dialyzer.nix "Runs a static code analysis using Dialyzer";
      dune-fmt = mkHook ./hooks/dune-fmt.nix "Runs dune-build-opam-files to ensure OCaml and Dune are in sync";
      dune-opam-sync = mkHook ./hooks/dune-opam-sync.nix "Check that Dune-generated OPAM files are in sync.";
      eclint = mkHook ./hooks/eclint.nix "EditorConfig linter written in Go.";
      editorconfig-checker = mkHook ./hooks/editorconfig-checker.nix "Verify that the files are in harmony with the `.editorconfig`.";
      elm-format = mkHook ./hooks/elm-format.nix "Format Elm files.";
      elm-review = mkHook ./hooks/elm-review.nix "Analyzes Elm projects, to help find mistakes before your users find them.";
      elm-test = mkHook ./hooks/elm-test.nix "Run unit tests and fuzz tests for Elm code.";
      end-of-file-fixer = mkHook ./hooks/end-of-file-fixer.nix "Ensures that a file is either empty, or ends with a single newline.";
      eslint = mkHook ./hooks/eslint.nix "Find and fix problems in your JavaScript code.";
      fix-byte-order-marker = mkHook ./hooks/fix-byte-order-marker.nix "Remove UTF-8 byte order marker.";
      fix-encoding-pragma = mkHook ./hooks/fix-encoding-pragma.nix "Adds # -*- coding: utf-8 -*- to the top of Python files.";
      flake8 = mkHook ./hooks/flake8.nix "Check the style and quality of Python files.";
      flake-checker = mkHook ./hooks/flake-checker.nix "Run health checks on your flake-powered Nix projects.";
      flynt = mkHook ./hooks/flynt.nix "CLI tool to convert a python project's %-formatted strings to f-strings.";
      forbid-new-submodules = mkHook ./hooks/forbid-new-submodules.nix "Prevent addition of new Git submodules.";
      fourmolu = mkHook ./hooks/fourmolu.nix "Haskell code prettifier.";
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
      html-tidy = mkHook ./hooks/html-tidy.nix "HTML linter.";
      hunspell = mkHook ./hooks/hunspell.nix "Spell checker and morphological analyzer.";
      isort = mkHook ./hooks/isort.nix "A Python utility/library to sort imports.";
      juliaformatter = mkHook ./hooks/juliaformatter.nix "Run JuliaFormatter.jl against Julia source files";
      lacheck = mkHook ./hooks/lacheck.nix "LaTeX checker";
      latexindent = mkHook ./hooks/latexindent.nix "Perl script to add indentation to LaTeX files";
      lua-ls = mkHook ./hooks/lua-ls.nix "Lua language server";
      luacheck = mkHook ./hooks/luacheck.nix "A tool for linting and static analysis of Lua code.";
      lychee = mkHook ./hooks/lychee.nix "A fast, async, stream-based link checker that finds broken hyperlinks and mail addresses inside Markdown, HTML, reStructuredText, or any other text file or website.";
      markdownlint = mkHook ./hooks/markdownlint.nix "Style checker and linter for markdown files.";
      mdformat = mkHook ./hooks/mdformat.nix "CommonMark compliant Markdown formatter";
      mdl = mkHook ./hooks/mdl.nix "A tool to check markdown files and flag style issues.";
      mdsh = mkHook ./hooks/mdsh.nix "Markdown shell pre-processor.";
      mix-format = mkHook ./hooks/mix-format.nix "Runs the built-in Elixir syntax formatter";
      mix-test = mkHook ./hooks/mix-test.nix "Runs the built-in Elixir test framework";
      mixed-line-endings = mkHook ./hooks/mixed-line-endings.nix "Resolve mixed line endings.";
      mkdocs-linkcheck = mkHook ./hooks/mkdocs-linkcheck.nix "Validate links associated with markdown-based, statically generated websites";
      mypy = mkHook ./hooks/mypy.nix "Static type checker for Python";
      name-tests-test = mkHook ./hooks/name-tests-test.nix "Verify that Python test files are named correctly.";
      nil = mkHook ./hooks/nil.nix "Incremental analysis assistant for writing in Nix.";
      nixfmt = (mkHook ./hooks/nixfmt.nix "Deprecated Nix code prettifier. Use nixfmt-classic or nixfmt-rfc-style instead.") // { visible = false; };
      nixfmt-classic = mkHook ./hooks/nixfmt-classic.nix "Nix code prettifier (classic)";
      nixfmt-rfc-style = mkHook ./hooks/nixfmt-rfc-style.nix "Nix code prettifier (RFC 166 style).";
      nixpkgs-fmt = mkHook ./hooks/nixpkgs-fmt.nix "Nix code prettifier.";
      no-commit-to-branch = mkHook ./hooks/no-commit-to-branch.nix "Disallow committing to certain branch/branches.";
      ocp-indent = mkHook ./hooks/ocp-indent.nix "A tool to indent OCaml code.";
      opam-lint = mkHook ./hooks/opam-lint.nix "OCaml package manager configuration checker";
      openapi-spec-validator = mkHook ./hooks/openapi-spec-validator.nix "Validate OpenAPI specifications.";
      ormolu = mkHook ./hooks/ormolu.nix "Haskell source code formatter";
      php-cs-fixer = mkHook ./hooks/php-cs-fixer.nix "Lint PHP files.";
      phpcbf = mkHook ./hooks/phpcbf.nix "Lint PHP files.";
      phpcs = mkHook ./hooks/phpcs.nix "Lint PHP files.";
      phpstan = mkHook ./hooks/phpstan.nix "Static analysis of PHP files.";
      poetry-check = mkHook ./hooks/poetry-check.nix "Check the validity of the pyproject.toml file.";
      poetry-lock = mkHook ./hooks/poetry-lock.nix "Update the poetry.lock file.";
      pre-commit-hook-ensure-sops = mkHook ./hooks/pre-commit-hook-ensure-sops.nix "Ensure that sops files are encrypted.";
      prettier = mkHook ./hooks/prettier.nix "Opinionated multi-language code formatter.";
      pretty-format-json = mkHook ./hooks/pretty-format-json.nix "Pretty format JSON";
      proselint = mkHook ./hooks/proselint.nix "A linter for prose";
      psalm = mkHook ./hooks/psalm.nix "PHP static analysis tool";
      purs-tidy = mkHook ./hooks/purs-tidy.nix "Format purescript files.";
      purty = mkHook ./hooks/purty.nix "Format purescript files";
      pylint = mkHook ./hooks/pylint.nix "Lint Python files.";
      pyright = mkHook ./hooks/pyright.nix "Static type checker for Python";
      python-debug-statements = mkHook ./hooks/python-debug-statements.nix "Check for debugger imports and py37+ `breakpoint()` calls in python source.";
      pyupgrade = mkHook ./hooks/pyupgrade.nix "Upgrade syntax for newer versions of Python.";
      reuse = mkHook ./hooks/reuse.nix "reuse is a tool for compliance with the REUSE recommendations.";
      revive = mkHook ./hooks/revive.nix "A linter for Go source code.";
      ripsecrets = mkHook ./hooks/ripsecrets.nix "Prevent committing secret keys into your source code";
      rome = (mkHook ./hooks/rome.nix "Deprecated rome hook. Use biome instead.") // { visible = false; };
      ruff = mkHook ./hooks/ruff.nix "An extremely fast Python linter, written in Rust.";
      ruff-format = mkHook ./hooks/ruff-format.nix "An extremely fast Python code formatter, written in Rust.";
      rustfmt = mkHook ./hooks/rustfmt.nix ''
        Rust code formatter

        Override the `rustfmt` and `cargo` packages by setting `hooks.rustfmt.packageOverrides`.

        ```
        hooks.rustfmt.packageOverrides.cargo = pkgs.cargo;
        hooks.rustfmt.packageOverrides.rustfmt = pkgs.rustfmt;
        ```
      '';
      selene = mkHook ./hooks/selene.nix "A blazing-fast modern Lua linter written in Rust.";
      shellcheck = mkHook ./hooks/shellcheck.nix "Format shell files.";
      shfmt = mkHook ./hooks/shfmt.nix "Format shell files.";
      single-quoted-strings = mkHook ./hooks/single-quoted-strings.nix "Replace double quoted strings with single quoted strings.";
      sort-file-contents = mkHook ./hooks/sort-file-contents.nix "Sort the lines in specified files (defaults to alphabetical).";
      sort-requirements-txt = mkHook ./hooks/sort-requirements-txt.nix "Sort requirements in requirements.txt and constraints.txt files.";
      sort-simple-yaml = mkHook ./hooks/sort-simple-yaml.nix "Sort simple YAML files which consist only of top-level keys, preserving comments and blocks.";
      staticcheck = mkHook ./hooks/staticcheck.nix "State of the art linter for the Go programming language.";
      statix = mkHook ./hooks/statix.nix "Lints and suggestions for the Nix programming language";
      stylish-haskell = mkHook ./hooks/stylish-haskell.nix "A simple Haskell code prettifier.";
      stylua = mkHook ./hooks/stylua.nix "An opinionated code formatter for Lua.";
      tagref = mkHook ./hooks/tagref.nix "Have tagref check all references and tags.";
      taplo = mkHook ./hooks/taplo.nix "Format TOML files with taplo fmt";
      terraform-format = mkHook ./hooks/terraform-format.nix "Format Terraform (`.tf`) files.";
      terraform-validate = mkHook ./hooks/terraform-validate.nix "Validates terraform configuration files (`.tf`).";
      tflint = mkHook ./hooks/tflint.nix "A pluggable Terraform linter.";
      topiary = mkHook ./hooks/topiary.nix "A universal formatter engine within the Tree-sitter ecosystem, with support for many languages.";
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
      trim-trailing-whitespace = mkHook ./hooks/trim-trailing-whitespace.nix "Trim trailing whitespace.";
      trufflehog = mkHook ./hooks/trufflehog.nix "Secrets scanner.";
      typos = mkHook ./hooks/typos.nix "Source code spell checker";
      typstfmt = mkHook ./hooks/typstfmt.nix "Format Typst files.";
      typstyle = mkHook ./hooks/typstyle.nix "Beautiful and reliable typst code formatter.";
      vale = mkHook ./hooks/vale.nix "A markup-aware linter for prose built with speed and extensibility in mind.";
      yamlfmt = mkHook ./hooks/yamlfmt.nix "Formatter for YAML files.";
      yamllint = mkHook ./hooks/yamllint.nix "Linter for YAML files.";
      zprint = mkHook ./hooks/zprint.nix "Beautifully format Clojure and Clojurescript source code and s-expressions.";
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
