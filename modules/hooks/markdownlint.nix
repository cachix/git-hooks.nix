{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    configuration =
      mkOption {
        type = types.attrs;
        description =
          "See https://github.com/DavidAnson/markdownlint/blob/main/schema/.markdownlint.jsonc";
        default = { };
      };
  };
}
