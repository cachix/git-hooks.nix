{ config, lib, pkgs, ... }:

let

  inherit (lib)
    attrNames
    concatStringsSep
    filterAttrs
    literalExample
    mapAttrsToList
    mkIf
    mkOption
    types
    ;
  inherit (import ../nix/lazyAttrsOf.nix { inherit lib; }) lazyAttrsOf;

  inherit (pkgs) runCommand writeText git;

  cfg = config.pre-commit;

  hookType =
    types.submodule (
      { config, name, ... }:
        {
          options =
            {
              enable =
                mkOption {
                  type = types.bool;
                  description = "Whether to enable this pre-commit hook.";
                  default = false;
                };
              raw =
                mkOption {
                  type = types.attrsOf types.unspecified;
                  description =
                    ''
                      Raw fields of a pre-commit hook. This is mostly for internal use but
                      exposed in case you need to work around something.

                      Default: taken from the other hook options.
                    '';
                };
              name =
                mkOption {
                  type = types.str;
                  default = name;
                  defaultText = literalExample "internal name, same as id";
                  description =
                    ''
                      The name of the hook - shown during hook execution.
                    '';
                };
              entry =
                mkOption {
                  type = types.str;
                  description =
                    ''
                      The entry point - the executable to run. entry can also contain arguments that will not be overridden such as entry: autopep8 -i.
                    '';
                };
              language =
                mkOption {
                  type = types.str;
                  description =
                    ''
                      The language of the hook - tells pre-commit how to install the hook.
                    '';
                  default = "system";
                };
              files =
                mkOption {
                  type = types.str;
                  description =
                    ''
                      The pattern of files to run on.
                    '';
                  default = "";
                };
              types =
                mkOption {
                  type = types.listOf types.str;
                  description =
                    ''
                      List of file types to run on. See Filtering files with types (https://pre-commit.com/#plugins).
                    '';
                  default = [ "file" ];
                };
              description =
                mkOption {
                  type = types.str;
                  description =
                    ''
                      Description of the hook. used for metadata purposes only.
                    '';
                  default = "";
                };
              excludes =
                mkOption {
                  type = types.listOf types.str;
                  description =
                    ''
                      Exclude files that were matched by these patterns.
                    '';
                  default = [];
                };
            };
          config =
            {
              raw =
                {
                  inherit (config) name entry language files types;
                  id = name;
                  exclude =
                    if config.excludes == [] then "^$" else
                      "(${concatStringsSep "|" config.excludes})";
                };
            };
        }
    );

  enabledHooks = filterAttrs ( id: value: value.enable ) cfg.hooks;
  processedHooks =
    mapAttrsToList ( id: value: value.raw // { inherit id; } ) enabledHooks;

  precommitConfig =
    {
      repos =
        [
          {
            repo = ".pre-commit-hooks/";
            rev = "master";
            hooks =
              mapAttrsToList ( id: _value: { inherit id; } ) enabledHooks;
          }
        ];
    };

  hooksFile =
    writeText "pre-commit-hooks.json" ( builtins.toJSON processedHooks );
  configFile =
    writeText "pre-commit-config.json" ( builtins.toJSON precommitConfig );

  hooks =
    runCommand "pre-commit-hooks-dir" { buildInputs = [ git ]; } ''
      HOME=$PWD
      mkdir -p $out
      ln -s ${hooksFile} $out/.pre-commit-hooks.yaml
      cd $out
      git config --global user.email "you@example.com"
      git config --global user.name "Your Name"
      git init
      git add .
      git commit -m "init"
    '';

  run =
    runCommand "pre-commit-run" { buildInputs = [ git ]; } ''
      set +e
      HOME=$PWD
      cp --no-preserve=mode -R ${cfg.rootSrc} src
      unlink src/.pre-commit-hooks || true
      ln -fs ${hooks} src/.pre-commit-hooks
      cd src
      rm -rf src/.git
      git init
      git add .
      git config --global user.email "you@example.com"
      git config --global user.name "Your Name"
      git commit -m "init"
      echo "Running: $ pre-commit run --all-files"
      ${cfg.package}/bin/pre-commit run --all-files
      exitcode=$?
      git --no-pager diff --color
      touch $out
      [ $? -eq 0 ] && exit $exitcode
    '';

  # TODO: provide a default pin that the user may override
  inherit (import (import ../nix/sources.nix).gitignore { inherit lib; })
    gitignoreSource
    ;
in {
  options.pre-commit =
    {

      package =
        mkOption {
          type = types.package;
          description =
            ''
              The pre-commit package to use.
            '';
          default = pkgs.pre-commit;
          defaultText =
            literalExample ''
        pkgs.pre-commit
      '';
        };

      tools =
        mkOption {
          type = lazyAttrsOf { elemType = types.package; };

          description =
            ''
              Tool set from which nix-pre-commit will pick binaries.

              nix-pre-commit comes with its own set of packages for this purpose.
            '';
          # This default is for when the module is the entry point rather than
          # /default.nix. /default.nix will override this for efficiency.
          default = (import ../nix {}).callPackage ../nix/tools.nix {};
          defaultText =
            literalExample ''nix-pre-commit-hooks-pkgs.callPackage tools-dot-nix {}'';
        };

      hooks =
        mkOption {
          type = types.attrsOf hookType;
          description =
            ''
              The hook definitions.
            '';
          default = {};
        };

      run =
        mkOption {
          type = types.package;
          description =
            ''
              A derivation that tests whether the pre-commit hooks run cleanly on
              the entire project.
            '';
          readOnly = true;
          default = run;
        };

      installationScript =
        mkOption {
          type = types.str;
          description =
            ''
              A bash snippet that installs nix-pre-commit in the current directory
            '';
          readOnly = true;
        };

      rootSrc =
        mkOption {
          type = types.package;
          description =
            ''
              The source of the project to be checked.
            '';
          defaultText = literalExample ''gitignoreSource config.root'';
          default = gitignoreSource config.root;
        };

    };

  config =
    {

      pre-commit.installationScript =
        ''
          export PATH=$PATH:${cfg.package}/bin
          if ! type -t git >/dev/null; then
            # This happens in pure shells, including lorri
            echo 1>&2 "WARNING: nix-pre-commit-hooks: git command not found; skipping installation."
          else
            # Avoid filesystem churn. We may be watched!
            # This prevents lorri from looping after every interactive shell command.
            if readlink .pre-commit-hooks >/dev/null \
              && [[ $(readlink .pre-commit-hooks) == ${hooks} ]]; then
              echo 1>&2 "nix-pre-commit-hooks: hooks up to date"
            else
              echo 1>&2 "nix-pre-commit-hooks: updating $PWD"

              [ -L .pre-commit-hooks ] && unlink .pre-commit-hooks
              ln -s ${hooks} .pre-commit-hooks

              # This can't be a symlink because its path is not constant,
              # thus can not be committed and is invisible to pre-commit.
              unlink .pre-commit-config.yaml
              { echo '# DO NOT MODIFY';
                echo '# This file was generated by nix-pre-commit-hooks';
                ${pkgs.jq}/bin/jq . <${configFile}
              } >.pre-commit-config.yaml

              pre-commit install
              # this is needed as the hook repo configuration is cached
              pre-commit clean
            fi
          fi
        '';
    };
}
