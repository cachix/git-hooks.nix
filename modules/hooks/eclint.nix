{ tools, config, lib, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    fix =
      mkOption {
        type = types.bool;
        description = "Modify files in place rather than showing the errors.";
        default = false;
      };
    summary =
      mkOption {
        type = types.bool;
        description = "Only show number of errors per file.";
        default = false;
      };
    color =
      mkOption {
        type = types.enum [ "auto" "always" "never" ];
        description = "When to generate colored output.";
        default = "auto";
      };
    exclude =
      mkOption {
        type = types.listOf types.str;
        description = "Filter to exclude files.";
        default = [ ];
      };
    verbosity =
      mkOption {
        type = types.enum [ 0 1 2 3 4 ];
        description = "Log level verbosity";
        default = 0;
      };
  };

  config = {
    name = "eclint";
    description = "EditorConfig linter written in Go.";
    types = [ "file" ];
    package = tools.eclint;
    entry =
      let
        cmdArgs =
          mkCmdArgs
            (with config.settings; [
              [ fix "-fix" ]
              [ summary "-summary" ]
              [ (color != "auto") "-color ${color}" ]
              [ (exclude != [ ]) "-exclude ${lib.escapeShellArgs exclude}" ]
              [ (verbosity != 0) "-verbosity ${toString verbosity}" ]
            ]);
      in
      "${config.package}/bin/eclint ${cmdArgs}";
  };
}
