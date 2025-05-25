{ lib, ... }:
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
}
