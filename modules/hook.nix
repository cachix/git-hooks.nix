{ config, name, lib, default_stages, default_language, ... }:

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

    name = mkOption {
      type = types.str;
      default = name;
      defaultText = lib.literalExpression "the attribute name the hook submodule is bound to, same as `id`";
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

          Defaults to `"system"`, or `"unsupported"` when using pre-commit >= 4.4.0.

          Note: `"unsupported"` does not mean deprecated.
          Pre-commit >= 4.4.0 renamed `"system"` to `"unsupported"` because
          when using this language pre-commit does not provision the tools, and using externally
          managed tools (e.g. via Nix) is not an officially supported workflow.
          Both values are functionally equivalent.
        '';
      default = default_language;
      defaultText = lib.literalExpression ''"system" or "unsupported" depending on pre-commit version'';
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
      defaultText = lib.literalExpression "default_stages";
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

    priority = mkOption {
      type = types.nullOr types.ints.u32;
      description = ''
        Defines the order in which the hooks are executed. Default priority is set by the order in the list of hooks.
        Evaluation goes from 0 and up.
        If two hooks have the same priority, they’ll run in parallel.
        This works only if cfg.package is set to prek.
      '';
      default = null;
    };
  };

  config = {
    raw =
      {
        inherit (config) id name entry language files types types_or exclude_types pass_filenames fail_fast require_serial stages verbose always_run args;
        exclude = mergeExcludes config.excludes;
        priority = lib.mkIf (config.priority != null) config.priority;
      };
  };
}
