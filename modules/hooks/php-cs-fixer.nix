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
    name = "php-cs-fixer";
    description = "Lint PHP files.";
    package = tools.php-cs-fixer;
    entry =
      let
        binPath = migrateBinPathToPackage config "/bin/php-cs-fixer";
      in
      "${binPath} fix";
    types = [ "php" ];
  };
}
