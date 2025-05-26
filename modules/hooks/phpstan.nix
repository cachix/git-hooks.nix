{ lib, config, tools, migrateBinPathToPackage, ... }:
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
          "''${config.package}/bin/phpstan"
        '';
      };
  };

  config = {
    name = "phpstan";
    description = "Static Analysis of PHP files.";
    package = tools.phpstan;
    entry =
      let
        binPath = migrateBinPathToPackage config "/bin/phpstan";
      in
      "${binPath} analyse";
    types = [ "php" ];
  };
}
