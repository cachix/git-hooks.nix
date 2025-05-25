{ lib, ... }:
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
}
