{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    branch =
      mkOption {
        description = "Branches to disallow commits to.";
        type = types.listOf types.str;
        default = [ "main" ];
        example = [ "main" "master" ];
      };
    pattern =
      mkOption {
        description = "RegEx patterns for branch names to disallow commits to.";
        type = types.listOf types.str;
        default = [ ];
        example = [ "ma.*" ];
      };
  };
}
