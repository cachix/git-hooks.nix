{ tools, config, lib, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    format =
      mkOption {
        type = types.enum [ "default" "compact" "json" ];
        description = "Output format.";
        default = "default";
      };

    configPath =
      mkOption {
        type = types.str;
        description = "Path to the configuration JSON file";
        # an empty string translates to use default configuration of the
        # underlying deno binary (i.e deno.json or deno.jsonc)
        default = "";
      };
  };

  config = {
    name = "denolint";
    description = "Lint JavaScript/TypeScript source code.";
    types_or = [ "javascript" "jsx" "ts" "tsx" ];
    package = tools.deno;
    entry =
      let
        cmdArgs =
          mkCmdArgs [
            [ (config.settings.format == "compact") "--compact" ]
            [ (config.settings.format == "json") "--json" ]
            [ (config.settings.configPath != "") "-c ${config.settings.configPath}" ]
          ];
      in
      "${tools.deno}/bin/deno lint ${cmdArgs}";
  };
}
