{ config, lib, pkgs, hookModule, ... }:
let
  inherit (config) hooks tools settings;
  cfg = config;
  inherit (lib) flatten mapAttrs mapAttrsToList mkDefault mkOption mkRemovedOptionModule mkRenamedOptionModule types;

  cargoManifestPathArg =
    lib.optionalString
      (settings.rust.cargoManifestPath != null)
      "--manifest-path ${lib.escapeShellArg settings.rust.cargoManifestPath}";

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
    config._module.args.default_stages = cfg.default_stages;
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
      };
      alejandra = mkOption {
        description = "alejandra hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/alejandra.nix ];
        };
      };
      annex = mkOption {
        description = "annex hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/annex.nix ];
        };
      };
      ansible-lint = mkOption {
        description = "ansible-lint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/ansible-lint.nix ];
        };
      };
      autoflake = mkOption {
        description = "autoflake hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/autoflake.nix ];
        };
      };
      bats = mkOption {
        description = "bats hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/bats.nix ];
        };
      };
      beautysh = mkOption {
        description = "beautysh hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/beautysh.nix ];
        };
      };
      biome = mkOption {
        description = "biome hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/biome.nix ];
        };
      };
      black = mkOption {
        description = "black hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/black.nix ];
        };
      };
      cabal-fmt = mkOption {
        description = "cabal-fmt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/cabal-fmt.nix ];
        };
      };
      cabal-gild = mkOption {
        description = "cabal-gild hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/cabal-gild.nix ];
        };
      };
      cabal2nix = mkOption {
        description = "cabal2nix hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/cabal2nix.nix ];
        };
      };
      cargo-check = mkOption {
        description = "cargo-check hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/cargo-check.nix ];
        };
      };
      check-added-large-files = mkOption {
        description = "check-added-large-files hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-added-large-files.nix ];
        };
      };
      check-builtin-literals = mkOption {
        description = "check-builtin-literals hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-builtin-literals.nix ];
        };
      };
      check-case-conflicts = mkOption {
        description = "check-case-conflicts hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-case-conflicts.nix ];
        };
      };
      check-docstring-first = mkOption {
        description = "check-docstring-first hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-docstring-first.nix ];
        };
      };
      check-executables-have-shebangs = mkOption {
        description = "check-executables-have-shebangs hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-executables-have-shebangs.nix ];
        };
      };
      check-json = mkOption {
        description = "check-json hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-json.nix ];
        };
      };
      check-merge-conflicts = mkOption {
        description = "check-merge-conflicts hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-merge-conflicts.nix ];
        };
      };
      check-python = mkOption {
        description = "check-python hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-python.nix ];
        };
      };
      check-shebang-scripts-are-executable = mkOption {
        description = "check-shebang-scripts-are-executable hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-shebang-scripts-are-executable.nix ];
        };
      };
      check-symlinks = mkOption {
        description = "check-symlinks hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-symlinks.nix ];
        };
      };
      check-toml = mkOption {
        description = "check-toml hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-toml.nix ];
        };
      };
      check-vcs-permalinks = mkOption {
        description = "check-vcs-permalinks hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-vcs-permalinks.nix ];
        };
      };
      check-xml = mkOption {
        description = "check-xml hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-xml.nix ];
        };
      };
      check-yaml = mkOption {
        description = "check-yaml hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/check-yaml.nix ];
        };
      };
      checkmake = mkOption {
        description = "checkmake hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/checkmake.nix ];
        };
      };
      chktex = mkOption {
        description = "chktex hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/chktex.nix ];
        };
      };
      circleci = mkOption {
        description = "circleci hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/circleci.nix ];
        };
      };
      clang-format = mkOption {
        description = "clang-format hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/clang-format.nix ];
        };
      };
      clang-tidy = mkOption {
        description = "clang-tidy hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/clang-tidy.nix ];
        };
      };
      clippy = mkOption {
        description = "clippy hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/clippy.nix ];
        };
      };
      cmake-format = mkOption {
        description = "cmake-format hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/cmake-format.nix ];
        };
      };
      credo = mkOption {
        description = "credo hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/credo.nix ];
        };
      };
      deadnix = mkOption {
        description = "deadnix hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/deadnix.nix ];
        };
      };
      denofmt = mkOption {
        description = "denofmt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/denofmt.nix ];
        };
      };
      denolint = mkOption {
        description = "denolint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/denolint.nix ];
        };
      };
      dune-fmt = mkOption {
        description = "dune-fmt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/dune-fmt.nix ];
        };
      };
      eclint = mkOption {
        description = "eclint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/eclint.nix ];
        };
      };
      eslint = mkOption {
        description = "eslint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/eslint.nix ];
        };
      };
      flake8 = mkOption {
        description = "flake8 hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/flake8.nix ];
        };
      };
      flynt = mkOption {
        description = "flynt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/flynt.nix ];
        };
      };
      fourmolu = mkOption {
        description = "fourmolu hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/fourmolu.nix ];
        };
      };
      golines = mkOption {
        description = "golines hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/golines.nix ];
        };
      };
      headache = mkOption {
        description = "headache hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/headache.nix ];
        };
      };
      hlint = mkOption {
        description = "hlint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/hlint.nix ];
        };
      };
      hpack = mkOption {
        description = "hpack hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/hpack.nix ];
        };
      };
      isort = mkOption {
        description = "isort hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/isort.nix ];
        };
      };
      latexindent = mkOption {
        description = "latexindent hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/latexindent.nix ];
        };
      };
      lacheck = mkOption {
        description = "lacheck hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/lacheck.nix ];
        };
      };
      lua-ls = mkOption {
        description = "lua-ls hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/lua-ls.nix ];
        };
      };
      lychee = mkOption {
        description = "lychee hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/lychee.nix ];
        };
      };
      markdownlint = mkOption {
        description = "markdownlint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/markdownlint.nix ];
        };
      };
      mdl = mkOption {
        description = "mdl hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/mdl.nix ];
        };
      };
      mkdocs-linkcheck = mkOption {
        description = "mkdocs-linkcheck hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/mkdocs-linkcheck.nix ];
        };
      };
      mypy = mkOption {
        description = "mypy hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/mypy.nix ];
        };
      };
      nixfmt = mkOption {
        description = "Deprecated nixfmt hook. Use nixfmt-classic or nixfmt-rfc-style instead.";
        visible = false;
        type = types.submodule {
          imports = [ hookModule ./hooks/nixfmt.nix ];
        };
      };
      nixfmt-classic = mkOption {
        description = "nixfmt (classic) hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/nixfmt-classic.nix ];
        };
      };
      nixfmt-rfc-style = mkOption {
        description = "nixfmt (RFC 166 style) hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/nixfmt-rfc-style.nix ];
        };
      };
      no-commit-to-branch = mkOption {
        description = "no-commit-to-branch-hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/no-commit-to-branch.nix ];
        };
      };
      ormolu = mkOption {
        description = "ormolu hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/ormolu.nix ];
        };
      };
      php-cs-fixer = mkOption {
        description = "php-cs-fixer hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/php-cs-fixer.nix ];
        };
      };
      phpcbf = mkOption {
        description = "phpcbf hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/phpcbf.nix ];
        };
      };
      phpcs = mkOption {
        description = "phpcs hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/phpcs.nix ];
        };
      };
      phpstan = mkOption {
        description = "phpstan hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/phpstan.nix ];
        };
      };
      # See all CLI flags for prettier [here](https://prettier.io/docs/en/cli.html).
      # See all options for prettier [here](https://prettier.io/docs/en/options.html).
      prettier = mkOption {
        description = "prettier hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/prettier.nix ];
        };
      };
      pretty-format-json = mkOption
        {
          description = "pretty-format-json hook";
          type = types.submodule {
            imports = [ hookModule ./hooks/pretty-format-json.nix ];
          };
        };
      proselint = mkOption {
        description = "proselint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/proselint.nix ];
        };
      };
      psalm = mkOption {
        description = "psalm hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/psalm.nix ];
        };
      };
      pylint = mkOption {
        description = "pylint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/pylint.nix ];
        };
      };
      pyright = mkOption {
        description = "pyright hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/pyright.nix ];
        };
      };
      pyupgrade = mkOption {
        description = "pyupgrade hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/pyupgrade.nix ];
        };
      };
      reuse = mkOption {
        description = "reuse hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/reuse.nix ];
        };
      };
      revive = mkOption {
        description = "revive hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/revive.nix ];
        };
      };
      ripsecrets = mkOption {
        description = "ripsecrets hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/ripsecrets.nix ];
        };
      };
      rome = mkOption {
        description = "Deprecated rome hook. Use biome instead.";
        visible = false;
        type = types.submodule {
          imports = [ hookModule ./hooks/rome.nix ];
        };
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
      };
      shfmt = mkOption {
        description = "shfmt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/shfmt.nix ];
        };
      };
      statix = mkOption {
        description = "statix hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/statix.nix ];
        };
      };
      sort-file-contents = mkOption {
        description = "sort-file-contents-hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/sort-file-contents.nix ];
        };
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
      };
      typos = mkOption {
        description = "typos hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/typos.nix ];
        };
      };
      vale = mkOption {
        description = "vale hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/vale.nix ];
        };
      };
      yamlfmt = mkOption {
        description = "yamlfmt hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/yamlfmt.nix ];
        };
      };
      yamllint = mkOption {
        description = "yamllint hook";
        type = types.submodule {
          imports = [ hookModule ./hooks/yamllint.nix ];
        };
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
