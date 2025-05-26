{ lib, config, tools, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    ignore-case =
      mkOption {
        type = types.bool;
        description = "Fold lower case to upper case characters.";
        default = false;
      };
    unique =
      mkOption {
        type = types.bool;
        description = "Ensure each line is unique.";
        default = false;
      };
  };

  config = {
    name = "sort-file-contents";
    description = "Sort the lines in specified files (defaults to alphabetical).";
    types = [ "text" ];
    package = tools.pre-commit-hooks;
    entry =
      let
        cmdArgs =
          mkCmdArgs
            (with config.settings;
            [
              [ ignore-case "--ignore-case" ]
              [ unique "--unique" ]
            ]);
      in
      "${config.package}/bin/file-contents-sorter ${cmdArgs}";
  };
}
