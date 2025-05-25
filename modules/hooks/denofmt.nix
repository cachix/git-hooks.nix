{ tools, config, lib, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    write =
      mkOption {
        type = types.bool;
        description = "Whether to edit files inplace.";
        default = true;
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
    name = "denofmt";
    description = "Auto-format JavaScript, TypeScript, Markdown, and JSON files.";
    types_or = [ "javascript" "jsx" "ts" "tsx" "markdown" "json" ];
    package = tools.deno;
    entry =
      let
        cmdArgs =
          mkCmdArgs [
            [ (!config.settings.write) "--check" ]
            [ (config.settings.configPath != "") "-c ${config.settings.configPath}" ]
          ];
      in
      "${tools.deno}/bin/deno fmt ${cmdArgs}";
  };
}
