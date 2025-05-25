{ config, lib, tools, mkCmdArgs, migrateBinPathToPackage, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binPath =
      mkOption {
        type = types.nullOr (types.oneOf [ types.str types.path ]);
        description = ''
          `rome` binary path.
          For example, if you want to use the `rome` binary from `node_modules`, use `"./node_modules/.bin/rome"`.
          Use a string instead of a path to avoid having to Git track the file in projects that use Nix flakes.
        '';
        default = null;
        defaultText = lib.literalExpression ''
          "''${tools.rome}/bin/rome"
        '';
        example = lib.literalExpression ''
          "./node_modules/.bin/rome"
        '';
      };

    write =
      mkOption {
        type = types.bool;
        description = "Whether to edit files inplace.";
        default = true;
      };

    configPath = mkOption {
      type = types.str;
      description = "Path to the configuration JSON file";
      # an empty string translates to use default configuration of the
      # underlying biome binary (i.e biome.json if exists)
      default = "";
    };
  };

  config = {
    name = "rome-deprecated";
    description = "";
    types_or = [ "javascript" "jsx" "ts" "tsx" "json" ];
    package = tools.biome;
    entry =
      let
        binPath = migrateBinPathToPackage config "/bin/biome";
        cmdArgs =
          mkCmdArgs [
            [ (config.settings.write) "--apply" ]
            [ (config.settings.configPath != "") "--config-path ${config.settings.configPath}" ]
          ];
      in
      "${binPath} check ${cmdArgs}";
  };
}
