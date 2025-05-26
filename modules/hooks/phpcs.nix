{ lib, config, tools, migrateBinPathToPackage, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binPath =
      mkOption {
        type = types.nullOr types.str;
        description = "PHP_CodeSniffer binary path.";
        default = null;
        defaultText = lib.literalExpression ''
          "''${config.package}/bin/phpcs"
        '';
      };
  };

  config = {
    name = "phpcs";
    description = "Lint PHP files.";
    package = tools.phpcs;
    entry = migrateBinPathToPackage config "/bin/phpcs";
    types = [ "php" ];
  };
}
