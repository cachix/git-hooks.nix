{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    hintFile =
      mkOption {
        type = types.nullOr (types.oneOf [ types.str types.path ]);
        description = "Path to hlint.yaml. By default, hlint searches for .hlint.yaml in the project root.";
        default = null;
      };
  };
}
