{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binPath =
      mkOption {
        type = types.nullOr types.str;
        description = "PHPStan binary path.";
        default = null;
        defaultText = lib.literalExpression ''
          "''${tools.phpstan}/bin/phpstan"
        '';
      };
  };
}
