{ config, lib, pkgs, ... }:
let
  inherit (lib)
    attrNames
    concatStringsSep
    compare
    filterAttrs
    literalExample
    mapAttrsToList
    mkIf
    mkOption
    types
    ;

  inherit (pkgs) runCommand writeText git;

  cfg = config;
  install_stages = lib.unique (cfg.default_stages ++ (builtins.concatLists (lib.mapAttrsToList (_: h: h.stages) enabledHooks)));

  hookType =
    types.submodule (
      { config, name, ... }:
      {
        options =
          {
            enable =
              mkOption {
                type = types.bool;
                description = lib.mdDoc "Whether to enable this pre-commit hook.";
                default = false;
              };
            raw =
              mkOption {
                type = types.attrsOf types.unspecified;
                description = lib.mdDoc
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
                defaultText = lib.literalDocBook or literalExample "internal name, same as id";
                description = lib.mdDoc
                  ''
                    The name of the hook - shown during hook execution.
                  '';
              };
            entry =
              mkOption {
                type = types.str;
                description = lib.mdDoc
                  ''
                    The entry point - the executable to run. {option}`entry` can also contain arguments that will not be overridden, such as `entry = "autopep8 -i";`.
                  '';
              };
            language =
              mkOption {
                type = types.str;
                description = lib.mdDoc
                  ''
                    The language of the hook - tells pre-commit how to install the hook.
                  '';
                default = "system";
              };
            files =
              mkOption {
                type = types.str;
                description = lib.mdDoc
                  ''
                    The pattern of files to run on.
                  '';
                default = "";
              };
            types =
              mkOption {
                type = types.listOf types.str;
                description = lib.mdDoc
                  ''
                    List of file types to run on. See [Filtering files with types](https://pre-commit.com/#plugins).
                  '';
                default = [ "file" ];
              };
            types_or =
              mkOption {
                type = types.listOf types.str;
                description = lib.mdDoc
                  ''
                    List of file types to run on, where only a single type needs to match.
                  '';
                default = [ ];
              };
            description =
              mkOption {
                type = types.str;
                description = lib.mdDoc
                  ''
                    Description of the hook. used for metadata purposes only.
                  '';
                default = "";
              };
            excludes =
              mkOption {
                type = types.listOf types.str;
                description = lib.mdDoc
                  ''
                    Exclude files that were matched by these patterns.
                  '';
                default = [ ];
              };
            pass_filenames =
              mkOption {
                type = types.bool;
                description = lib.mdDoc ''
                  Whether to pass filenames as arguments to the entry point.
                '';
                default = true;
              };
            fail_fast = mkOption {
              type = types.bool;
              description = lib.mdDoc ''
                if true pre-commit will stop running hooks if this hook fails.
              '';
            };
            require_serial = mkOption {
              type = types.bool;
              description = lib.mdDoc ''
                if true this hook will execute using a single process instead of in parallel.
              '';
            };
            stages =
              mkOption {
                type = types.listOf types.str;
                description = lib.mdDoc ''
                  Confines the hook to run at a particular stage.
                '';
                default = cfg.default_stages;
                defaultText = (lib.literalExpression or lib.literalExample) "default_stages";
              };
          };
        config =
          {
            raw =
              {
                inherit (config) name entry language files stages types types_or pass_filenames;
                id = name;
                exclude = mergeExcludes config.excludes;
              };
          };
      }
    );

  mergeExcludes =
    excludes:
    if excludes == [ ] then "^$" else "(${concatStringsSep "|" excludes})";

  enabledHooks = filterAttrs (id: value: value.enable) cfg.hooks;
  processedHooks =
    mapAttrsToList (id: value: value.raw // { inherit id; }) enabledHooks;

  configFile =
    runCommand "pre-commit-config.json"
      {
        buildInputs = [ pkgs.jq ];
        passAsFile = [ "rawJSON" ];
        rawJSON = builtins.toJSON cfg.rawConfig;
      } ''
      {
        echo '# DO NOT MODIFY';
        echo '# This file was generated by pre-commit-hooks.nix';
        jq . <"$rawJSONPath"
      } >$out
    '';

  run =
    runCommand "pre-commit-run" { buildInputs = [ git ]; } ''
      set +e
      HOME=$PWD
      # Use `chmod +w` instead of `cp --no-preserve=mode` to be able to write and to
      # preserve the executable bit at the same time
      cp -R ${cfg.rootSrc} src
      chmod -R +w src
      ln -fs ${configFile} src/.pre-commit-config.yaml
      cd src
      rm -rf src/.git
      git init
      git add .
      git config --global user.email "you@example.com"
      git config --global user.name "Your Name"
      git commit -m "init"
      if [[ ${toString (compare install_stages [ "manual" ])} -eq 0 ]]
      then
        echo "Running: $ pre-commit run --hook-stage manual --all-files"
        ${cfg.package}/bin/pre-commit run --hook-stage manual --all-files
      else
        echo "Running: $ pre-commit run --all-files"
        ${cfg.package}/bin/pre-commit run --all-files
      fi
      exitcode=$?
      git --no-pager diff --color
      touch $out
      [ $? -eq 0 ] && exit $exitcode
    '';
in
{
  options =
    {

      package =
        mkOption {
          type = types.package;
          description = lib.mdDoc
            ''
              The `pre-commit` package to use.
            '';
          defaultText =
            lib.literalExpression or literalExample ''
              pkgs.pre-commit
            '';
        };

      tools =
        mkOption {
          type = types.lazyAttrsOf types.package;
          description = lib.mdDoc
            ''
              Tool set from which `nix-pre-commit-hooks` will pick binaries.

              `nix-pre-commit-hooks` comes with its own set of packages for this purpose.
            '';
          defaultText =
            lib.literalExpression or literalExample ''pre-commit-hooks.nix-pkgs.callPackage tools-dot-nix { inherit (pkgs) system; }'';
        };

      hooks =
        mkOption {
          type = types.attrsOf hookType;
          description = lib.mdDoc
            ''
              The hook definitions.

              Pre-defined hooks can be enabled by, for example:

              ```nix
              hooks.nixpkgs-fmt.enable = true;
              ```

              The pre-defined hooks are:

              ${
                lib.concatStringsSep
                  "\n" 
                  (lib.mapAttrsToList
                    (hookName: hookConf:
                      ''
                        **`${hookName}`**

                        ${hookConf.description}

                      '')
                    config.hooks)
              }
            '';
          default = { };
        };

      run =
        mkOption {
          type = types.package;
          description = lib.mdDoc
            ''
              A derivation that tests whether the pre-commit hooks run cleanly on
              the entire project.
            '';
          readOnly = true;
          default = run;
          defaultText = "<derivation>";
        };

      installationScript =
        mkOption {
          type = types.str;
          description = lib.mdDoc
            ''
              A bash snippet that installs nix-pre-commit-hooks in the current directory
            '';
          readOnly = true;
        };

      src =
        lib.mkOption {
          description = lib.mdDoc ''
            Root of the project. By default this will be filtered with the `gitignoreSource`
            function later, unless `rootSrc` is specified.

            If you use the `flakeModule`, the default is `self.outPath`; the whole flake
            sources.
          '';
          type = lib.types.path;
        };

      rootSrc =
        mkOption {
          type = types.path;
          description = lib.mdDoc
            ''
              The source of the project to be checked.

              This is used in the derivation that performs the check.

              If you use the `flakeModule`, the default is `self.outPath`; the whole flake
              sources.
            '';
          defaultText = lib.literalExpression or literalExample ''gitignoreSource config.src'';
        };

      excludes =
        mkOption {
          type = types.listOf types.str;
          description = lib.mdDoc
            ''
              Exclude files that were matched by these patterns.
            '';
          default = [ ];
        };

      default_stages =
        mkOption {
          type = types.listOf types.str;
          description = lib.mdDoc
            ''
              A configuration wide option for the stages property.
              Installs hooks to the defined stages.
              See [https://pre-commit.com/#confining-hooks-to-run-at-certain-stages](https://pre-commit.com/#confining-hooks-to-run-at-certain-stages).
            '';
          default = [ "commit" ];
        };

      rawConfig =
        mkOption {
          type = types.attrs;
          description = lib.mdDoc
            ''
              The raw configuration before writing to file.

              This option does not have an appropriate merge function.
              It is accessible in case you need to set an attribute that doesn't have an option.
            '';
          internal = true;
        };
    };

  config =
    {

      rawConfig =
        {
          repos =
            [
              {
                repo = "local";
                hooks = processedHooks;
              }
            ];
        } // lib.optionalAttrs (cfg.excludes != [ ]) {
          exclude = mergeExcludes cfg.excludes;
        } // lib.optionalAttrs (cfg.default_stages != [ ]) {
          default_stages = cfg.default_stages;
        };

      installationScript =
        ''
          export PATH=${cfg.package}/bin:$PATH
          if ! type -t git >/dev/null; then
            # This happens in pure shells, including lorri
            echo 1>&2 "WARNING: pre-commit-hooks.nix: git command not found; skipping installation."
          elif ! ${git}/bin/git rev-parse --git-dir &> /dev/null; then
            echo 1>&2 "WARNING: pre-commit-hooks.nix: .git not found; skipping installation."
          else
            # These update procedures compare before they write, to avoid
            # filesystem churn. This improves performance with watch tools like lorri
            # and prevents installation loops by via lorri.

            YAML_PATH="''${FLAKE_ROOT:-.}"/.pre-commit-config.yaml

            if readlink "''$YAML_PATH" >/dev/null \
              && [[ $(readlink "''$YAML_PATH") == ${configFile} ]]; then
              echo 1>&2 "pre-commit-hooks.nix: hooks up to date"
            else
              echo 1>&2 "pre-commit-hooks.nix: updating $PWD repo"

              [ -L "''$YAML_PATH" ] && unlink "''$YAML_PATH"

              if [ -e "''$YAML_PATH" ]; then
                echo 1>&2 "pre-commit-hooks.nix: WARNING: Refusing to install because of pre-existing .pre-commit-config.yaml"
                echo 1>&2 "    1. Translate .pre-commit-config.yaml contents to the new syntax in your Nix file"
                echo 1>&2 "        see https://github.com/cachix/pre-commit-hooks.nix#getting-started"
                echo 1>&2 "    2. remove .pre-commit-config.yaml"
                echo 1>&2 "    3. add .pre-commit-config.yaml to .gitignore"
              else
                ln -s ${configFile} "''$YAML_PATH"
                # Remove any previously installed hooks (since pre-commit itself has no convergent design)
                hooks="pre-commit pre-merge-commit pre-push prepare-commit-msg commit-msg post-checkout post-commit"
                for hook in $hooks; do
                  pre-commit uninstall -t $hook
                done
                # Add hooks for configured stages (only) ...
                if [ ! -z "${concatStringsSep " " install_stages}" ]; then
                  for stage in ${concatStringsSep " " install_stages}; do
                    if [[ "$stage" == "manual" ]]; then
                      continue
                    fi
                    case $stage in
                      # if you amend these switches please also review $hooks above
                      commit | merge-commit | push)
                        stage="pre-"$stage
                        pre-commit install -t $stage
                        ;;
                      prepare-commit-msg | commit-msg | post-checkout | post-commit)
                        pre-commit install -t $stage
                        ;;
                      *)
                        echo 1>&2 "ERROR: pre-commit-hooks.nix: either $stage is not a valid stage or pre-commit-hooks.nix doesn't yet support it."
                        exit 1
                        ;;
                    esac
                  done
                # ... or default 'pre-commit' hook
                else
                  pre-commit install
                fi
              fi
            fi
          fi
        '';
    };
}
