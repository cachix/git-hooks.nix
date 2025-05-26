{ lib, config, tools, migrateBinPathToPackage, ... }:
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
          "''${config.package}/bin/php-cs-fixer"
        '';
      };
  };

  config = {
    package = tools.php-cs-fixer;
    entry =
      let
        binPath = migrateBinPathToPackage config "/bin/php-cs-fixer";
      in
      "${binPath} fix";
    types = [ "php" ];
  };
}
