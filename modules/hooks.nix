{ config, lib, pkgs, hookModule, ... }:
let
  cfg = config;
  inherit (lib) flatten mapAttrsToList mkOption mkRemovedOptionModule mkRenamedOptionModule types;

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
      inherit mkCmdArgs migrateBinPathToPackage;
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
      actionlint = mkOption {
        description = "actionlint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/actionlint.nix ];
        };
        default = { };
      };
      alejandra = mkOption {
        description = "alejandra hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/alejandra.nix ];
        };
        default = { };
      };
      annex = mkOption {
        description = "annex hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/annex.nix ];
        };
        default = { };
      };
      ansible-lint = mkOption {
        description = "ansible-lint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/ansible-lint.nix ];
        };
        default = { };
      };
      autoflake = mkOption {
        description = "autoflake hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/autoflake.nix ];
        };
        default = { };
      };
      bats = mkOption {
        description = "bats hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/bats.nix ];
        };
        default = { };
      };
      beautysh = mkOption {
        description = "beautysh hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/beautysh.nix ];
        };
        default = { };
      };
      biome = mkOption {
        description = "biome hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/biome.nix ];
        };
        default = { };
      };
      black = mkOption {
        description = "black hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/black.nix ];
        };
        default = { };
      };
      cabal-fmt = mkOption {
        description = "cabal-fmt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/cabal-fmt.nix ];
        };
        default = { };
      };
      cabal-gild = mkOption {
        description = "cabal-gild hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/cabal-gild.nix ];
        };
        default = { };
      };
      cabal2nix = mkOption {
        description = "cabal2nix hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/cabal2nix.nix ];
        };
        default = { };
      };
      cargo-check = mkOption {
        description = "cargo-check hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/cargo-check.nix ];
        };
        default = { };
      };
      check-added-large-files = mkOption {
        description = "check-added-large-files hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-added-large-files.nix ];
        };
        default = { };
      };
      check-builtin-literals = mkOption {
        description = "check-builtin-literals hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-builtin-literals.nix ];
        };
        default = { };
      };
      check-case-conflicts = mkOption {
        description = "check-case-conflicts hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-case-conflicts.nix ];
        };
        default = { };
      };
      check-docstring-first = mkOption {
        description = "check-docstring-first hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-docstring-first.nix ];
        };
        default = { };
      };
      check-executables-have-shebangs = mkOption {
        description = "check-executables-have-shebangs hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-executables-have-shebangs.nix ];
        };
        default = { };
      };
      check-json = mkOption {
        description = "check-json hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-json.nix ];
        };
        default = { };
      };
      check-merge-conflicts = mkOption {
        description = "check-merge-conflicts hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-merge-conflicts.nix ];
        };
        default = { };
      };
      check-python = mkOption {
        description = "check-python hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-python.nix ];
        };
        default = { };
      };
      check-shebang-scripts-are-executable = mkOption {
        description = "check-shebang-scripts-are-executable hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-shebang-scripts-are-executable.nix ];
        };
        default = { };
      };
      check-symlinks = mkOption {
        description = "check-symlinks hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-symlinks.nix ];
        };
        default = { };
      };
      check-toml = mkOption {
        description = "check-toml hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-toml.nix ];
        };
        default = { };
      };
      check-vcs-permalinks = mkOption {
        description = "check-vcs-permalinks hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-vcs-permalinks.nix ];
        };
        default = { };
      };
      check-xml = mkOption {
        description = "check-xml hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-xml.nix ];
        };
        default = { };
      };
      check-yaml = mkOption {
        description = "check-yaml hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-yaml.nix ];
        };
        default = { };
      };
      checkmake = mkOption {
        description = "checkmake hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/checkmake.nix ];
        };
        default = { };
      };
      chktex = mkOption {
        description = "chktex hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/chktex.nix ];
        };
        default = { };
      };
      cljfmt = mkOption {
        description = "cljfmt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/cljfmt.nix ];
        };
        default = { };
      };
      circleci = mkOption {
        description = "circleci hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/circleci.nix ];
        };
        default = { };
      };
      clang-format = mkOption {
        description = "clang-format hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/clang-format.nix ];
        };
        default = { };
      };
      clang-tidy = mkOption {
        description = "clang-tidy hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/clang-tidy.nix ];
        };
        default = { };
      };
      clippy = mkOption {
        description = "clippy hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/clippy.nix ];
        };
        default = { };
      };
      cmake-format = mkOption {
        description = "cmake-format hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/cmake-format.nix ];
        };
        default = { };
      };
      commitizen = mkOption {
        description = "commitizen hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/commitizen.nix ];
        };
        default = { };
      };
      conform = mkOption {
        description = "conform hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/conform.nix ];
        };
        default = { };
      };
      convco = mkOption {
        description = "convco hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/convco.nix ];
        };
        default = { };
      };
      credo = mkOption {
        description = "credo hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/credo.nix ];
        };
        default = { };
      };
      crystal = mkOption {
        description = "crystal hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/crystal.nix ];
        };
        default = { };
      };
      cspell = mkOption {
        description = "cspell hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/cspell.nix ];
        };
        default = { };
      };
      dart-analyze = mkOption {
        description = "dart-analyze hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/dart-analyze.nix ];
        };
        default = { };
      };
      dart-format = mkOption {
        description = "dart-format hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/dart-format.nix ];
        };
        default = { };
      };
      deadnix = mkOption {
        description = "deadnix hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/deadnix.nix ];
        };
        default = { };
      };
      detect-aws-credentials = mkOption {
        description = "detect-aws-credentials hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/detect-aws-credentials.nix ];
        };
        default = { };
      };
      detect-private-keys = mkOption {
        description = "detect-private-keys hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/detect-private-keys.nix ];
        };
        default = { };
      };
      dhall-format = mkOption {
        description = "dhall-format hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/dhall-format.nix ];
        };
        default = { };
      };
      dialyzer = mkOption {
        description = "dialyzer hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/dialyzer.nix ];
        };
        default = { };
      };
      denofmt = mkOption {
        description = "denofmt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/denofmt.nix ];
        };
        default = { };
      };
      denolint = mkOption {
        description = "denolint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/denolint.nix ];
        };
        default = { };
      };
      dune-fmt = mkOption {
        description = "dune-fmt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/dune-fmt.nix ];
        };
        default = { };
      };
      dune-opam-sync = mkOption {
        description = "dune-opam-sync hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/dune-opam-sync.nix ];
        };
        default = { };
      };
      eclint = mkOption {
        description = "eclint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/eclint.nix ];
        };
        default = { };
      };
      editorconfig-checker = mkOption {
        description = "editorconfig-checker hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/editorconfig-checker.nix ];
        };
        default = { };
      };
      elm-format = mkOption {
        description = "elm-format hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/elm-format.nix ];
        };
        default = { };
      };
      elm-review = mkOption {
        description = "elm-review hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/elm-review.nix ];
        };
        default = { };
      };
      elm-test = mkOption {
        description = "elm-test hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/elm-test.nix ];
        };
        default = { };
      };
      end-of-file-fixer = mkOption {
        description = "end-of-file-fixer hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/end-of-file-fixer.nix ];
        };
        default = { };
      };
      eslint = mkOption {
        description = "eslint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/eslint.nix ];
        };
        default = { };
      };
      flake8 = mkOption {
        description = "flake8 hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/flake8.nix ];
        };
        default = { };
      };
      fix-byte-order-marker = mkOption {
        description = "fix-byte-order-marker hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/fix-byte-order-marker.nix ];
        };
        default = { };
      };
      fix-encoding-pragma = mkOption {
        description = "fix-encoding-pragma hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/fix-encoding-pragma.nix ];
        };
        default = { };
      };
      flake-checker = mkOption {
        description = "flake-checker hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/flake-checker.nix ];
        };
        default = { };
      };
      flynt = mkOption {
        description = "flynt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/flynt.nix ];
        };
        default = { };
      };
      fourmolu = mkOption {
        description = "fourmolu hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/fourmolu.nix ];
        };
        default = { };
      };
      forbid-new-submodules = mkOption {
        description = "forbid-new-submodules hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/forbid-new-submodules.nix ];
        };
        default = { };
      };
      fprettify = mkOption {
        description = "fprettify hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/fprettify.nix ];
        };
        default = { };
      };
      gitlint = mkOption {
        description = "gitlint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/gitlint.nix ];
        };
        default = { };
      };
      gofmt = mkOption {
        description = "gofmt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/gofmt.nix ];
        };
        default = { };
      };
      golangci-lint = mkOption {
        description = "golangci-lint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/golangci-lint.nix ];
        };
        default = { };
      };
      golines = mkOption {
        description = "golines hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/golines.nix ];
        };
        default = { };
      };
      gotest = mkOption {
        description = "gotest hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/gotest.nix ];
        };
        default = { };
      };
      govet = mkOption {
        description = "govet hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/govet.nix ];
        };
        default = { };
      };
      gptcommit = mkOption {
        description = "gptcommit hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/gptcommit.nix ];
        };
        default = { };
      };
      hadolint = mkOption {
        description = "hadolint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/hadolint.nix ];
        };
        default = { };
      };
      headache = mkOption {
        description = "headache hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/headache.nix ];
        };
        default = { };
      };
      hlint = mkOption {
        description = "hlint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/hlint.nix ];
        };
        default = { };
      };
      hpack = mkOption {
        description = "hpack hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/hpack.nix ];
        };
        default = { };
      };
      isort = mkOption {
        description = "isort hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/isort.nix ];
        };
        default = { };
      };
      lacheck = mkOption {
        description = "lacheck hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/lacheck.nix ];
        };
        default = { };
      };
      latexindent = mkOption {
        description = "latexindent hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/latexindent.nix ];
        };
        default = { };
      };
      lua-ls = mkOption {
        description = "lua-ls hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/lua-ls.nix ];
        };
        default = { };
      };
      lychee = mkOption {
        description = "lychee hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/lychee.nix ];
        };
        default = { };
      };
      markdownlint = mkOption {
        description = "markdownlint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/markdownlint.nix ];
        };
        default = { };
      };
      mdl = mkOption {
        description = "mdl hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/mdl.nix ];
        };
        default = { };
      };
      mkdocs-linkcheck = mkOption {
        description = "mkdocs-linkcheck hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/mkdocs-linkcheck.nix ];
        };
        default = { };
      };
      mypy = mkOption {
        description = "mypy hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/mypy.nix ];
        };
        default = { };
      };
      nixfmt = mkOption {
        description = "Deprecated nixfmt hook. Use nixfmt-classic or nixfmt-rfc-style instead.";
        visible = false;
        type = types.submodule {
          imports = [ hookModule ./hooks/nixfmt.nix ];
        };
        default = { };
      };
      nixfmt-classic = mkOption {
        description = "nixfmt (classic) hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/nixfmt-classic.nix ];
        };
        default = { };
      };
      nixfmt-rfc-style = mkOption {
        description = "nixfmt (RFC 166 style) hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/nixfmt-rfc-style.nix ];
        };
        default = { };
      };
      nixpkgs-fmt = mkOption {
        description = "nixpkgs-fmt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/nixpkgs-fmt.nix ];
        };
        default = { };
      };
      no-commit-to-branch = mkOption {
        description = "no-commit-to-branch-hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/no-commit-to-branch.nix ];
        };
        default = { };
      };
      ormolu = mkOption {
        description = "ormolu hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/ormolu.nix ];
        };
        default = { };
      };
      php-cs-fixer = mkOption {
        description = "php-cs-fixer hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/php-cs-fixer.nix ];
        };
        default = { };
      };
      phpcbf = mkOption {
        description = "phpcbf hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/phpcbf.nix ];
        };
        default = { };
      };
      phpcs = mkOption {
        description = "phpcs hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/phpcs.nix ];
        };
        default = { };
      };
      phpstan = mkOption {
        description = "phpstan hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/phpstan.nix ];
        };
        default = { };
      };
      # See all CLI flags for prettier [here](https://prettier.io/docs/en/cli.html).
      # See all options for prettier [here](https://prettier.io/docs/en/options.html).
      prettier = mkOption {
        description = "prettier hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/prettier.nix ];
        };
        default = { };
      };
      pretty-format-json = mkOption
        {
          description = "pretty-format-json hook";
          type = types.submodule {
            imports = [ hookModule ./hooks/pretty-format-json.nix ];
          };
          default = { };
        };
      proselint = mkOption {
        description = "proselint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/proselint.nix ];
        };
        default = { };
      };
      psalm = mkOption {
        description = "psalm hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/psalm.nix ];
        };
        default = { };
      };
      pylint = mkOption {
        description = "pylint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/pylint.nix ];
        };
        default = { };
      };
      pyright = mkOption {
        description = "pyright hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/pyright.nix ];
        };
        default = { };
      };
      pyupgrade = mkOption {
        description = "pyupgrade hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/pyupgrade.nix ];
        };
        default = { };
      };
      reuse = mkOption {
        description = "reuse hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/reuse.nix ];
        };
        default = { };
      };
      revive = mkOption {
        description = "revive hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/revive.nix ];
        };
        default = { };
      };
      ripsecrets = mkOption {
        description = "ripsecrets hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/ripsecrets.nix ];
        };
        default = { };
      };
      rome = mkOption {
        description = "Deprecated rome hook. Use biome instead.";
        visible = false;
        type = types.submodule {
          imports = [ hookModule ./hooks/rome.nix ];
        };
        default = { };
      };
      rustfmt = mkOption {
        description = ''
          Additional rustfmt settings

          Override the `rustfmt` and `cargo` packages by setting `hooks.rustfmt.packageOverrides`.

          ```
          hooks.rustfmt.packageOverrides.cargo = pkgs.cargo;
          hooks.rustfmt.packageOverrides.rustfmt = pkgs.rustfmt;
          ```
        '';
        type = types.submoduleWith {
          modules = [ hookModule ./hooks/rustfmt.nix ];
          specialArgs = { rustSettings = config.settings.rust; };
        };
        default = { };
      };
      shfmt = mkOption {
        description = "shfmt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/shfmt.nix ];
        };
        default = { };
      };
      sort-file-contents = mkOption {
        description = "sort-file-contents-hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/sort-file-contents.nix ];
        };
        default = { };
      };
      statix = mkOption {
        description = "statix hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/statix.nix ];
        };
        default = { };
      };
      treefmt = mkOption {
        description = ''
          Treefmt hook.

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
        type = types.submodule {
          imports = [ hookModule ./hooks/treefmt.nix ];
        };
        default = { };
      };
      typos = mkOption {
        description = "typos hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/typos.nix ];
        };
        default = { };
      };
      vale = mkOption {
        description = "vale hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/vale.nix ];
        };
        default = { };
      };
      yamlfmt = mkOption {
        description = "yamlfmt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/yamlfmt.nix ];
        };
        default = { };
      };
      yamllint = mkOption {
        description = "yamllint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/yamllint.nix ];
        };
        default = { };
      };
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
