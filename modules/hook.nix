{ config, name, lib, default_stages, ... }:

let
  inherit (lib) concatStringsSep mkOption types;
  mergeExcludes =
    excludes:
    if excludes == [ ] then "^$" else "(${concatStringsSep "|" excludes})";
in
{
  options = {
    enable = mkOption {
      type = types.bool;
      description = "Whether to enable this pre-commit hook.";
      default = false;
    };

    raw = mkOption {
      type = types.attrsOf types.unspecified;
      description =
        ''
          Raw fields of a pre-commit hook. This is mostly for internal use but
          exposed in case you need to work around something.

          Default: taken from the other hook options.
        '';
    };

    id = mkOption {
      type = types.str;
      default = name;
      defaultText = "the attribute name the hook submodule is bound to";
      description =
        ''
          The unique identifier for the hook.

          You do not need to set or modify this value.

          The `id` is used to reference a hook when using `pre-commit run <id>`.
          It can also be used to reference the hook in other hooks' `before` and `after` fields to define the order in which hooks run.

          The `id` is set to the attribute name the hook submodule is bound to in the parent module.
          For example, the `id` of following hook would be `my-hook`.

          ```nix
          {
            hooks = {
              my-hook = {
                enable = true;
                entry = "my-hook";
              };
            }
          }
          ```
        '';
    };

    alias = mkOption {
      type = types.nullOr types.str;
      description =
        ''
          An optional alias for the hook.

          Allows the hook to referenced using an additional id.
          ```
        '';
      default = null;
    };

    name = mkOption {
      type = types.str;
      default = name;
      defaultText = lib.literalMD "the attribute name the hook submodule is bound to, same as `id`";
      description =
        ''
          The name of the hook. Shown during hook execution.
        '';
    };

    description = mkOption {
      type = types.str;
      description =
        ''
          Description of the hook. Used for metadata purposes only.
        '';
      default = "";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description =
        ''
          An optional package that provides the hook.
        '';
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description =
        ''
          Additional packages required to run the hook.

          These are propagated to `enabledPackages` for constructing developer
          environments.
        '';
    };

    entry = mkOption {
      type = types.str;
      description =
        ''
          The entry point - the executable to run. {option}`entry` can also contain arguments that will not be overridden, such as `entry = "autopep8 -i";`.
        '';
    };

    language = mkOption {
      type = types.str;
      description =
        ''
          The language of the hook - tells pre-commit how to install the hook.
        '';
      default = "system";
    };

    files = mkOption {
      type = types.str;
      description =
        ''
          The pattern of files to run on.
        '';
      default = "";
    };

    types = mkOption {
      type = types.listOf types.str;
      description =
        ''
          List of file types to run on. See [Filtering files with types](https://pre-commit.com/#filtering-files-with-types).
        '';
      default = [ "file" ];
    };

    types_or = mkOption {
      type = types.listOf types.str;
      description =
        ''
          List of file types to run on, where only a single type needs to match.
        '';
      default = [ ];
    };

    excludes = mkOption {
      type = types.listOf types.str;
      description =
        ''
          Exclude files that were matched by these patterns.
        '';
      default = [ ];
    };

    exclude_types = mkOption {
      type = types.listOf types.str;
      description =
        ''
          List of file types to exclude. See [Filtering files with types](https://pre-commit.com/#filtering-files-with-types).
        '';
      default = [ ];
    };

    pass_filenames = mkOption {
      type = types.bool;
      description = ''
        Whether to pass filenames as arguments to the entry point.
      '';
      default = true;
    };

    fail_fast = mkOption {
      type = types.bool;
      description = ''
        if true pre-commit will stop running hooks if this hook fails.
      '';
      default = false;
    };

    require_serial = mkOption {
      type = types.bool;
      description = ''
        if true this hook will execute using a single process instead of in parallel.
      '';
      default = false;
    };

    stages = mkOption {
      type = (import ./supported-hooks.nix { inherit lib; }).supportedHooksType;
      description = ''
        Confines the hook to run at a particular stage.
      '';
      default = default_stages;
      defaultText = (lib.literalExpression or lib.literalExample) "default_stages";
    };

    verbose = mkOption {
      type = types.bool;
      default = false;
      description = ''
        forces the output of the hook to be printed even when the hook passes.
      '';
    };

    always_run = mkOption {
      type = types.bool;
      default = false;
      description = ''
        if true this hook will run even if there are no matching files.
      '';
    };

    args = mkOption {
      type = types.listOf types.str;
      description =
        ''
          List of additional parameters to pass to the hook.
        '';
      default = [ ];
    };

    before = mkOption {
      type = types.listOf types.str;
      description =
        ''
          List of hooks that should run after this hook.
        '';
      default = [ ];
    };

    after = mkOption {
      type = types.listOf types.str;
      description =
        ''
          List of hooks that should run before this hook.
        '';
      default = [ ];
    };
  };

  config = {
    raw =
      {
        inherit (config)
          always_run
          args
          entry
          exclude_types
          fail_fast
          files
          id
          language
          name
          pass_filenames
          require_serial
          stages
          types
          types_or
          verbose;
        exclude = mergeExcludes config.excludes;
      } // lib.optionalAttrs (config.alias != null) { alias = config.alias; };
  };
}
