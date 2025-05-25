{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binPath =
      mkOption {
        type = types.nullOr types.str;
        description = "PHP-CS-Fixer binary path.";
        default = null;
        defaultText = lib.literalExpression ''
          "''${tools.php-cs-fixer}/bin/php-cs-fixer"
        '';
      };
  };
}
