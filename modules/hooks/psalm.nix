{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binPath =
      mkOption {
        type = types.nullOr types.str;
        description = "Psalm binary path.";
        default = null;
        defaultText = lib.literalExpression ''
          "''${tools.psalm}/bin/psalm"
        '';
      };
  };
}
