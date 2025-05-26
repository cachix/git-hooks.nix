{ lib, config, tools, migrateBinPathToPackage, ... }:
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
          "''${config.package}/bin/psalm"
        '';
      };
  };

  config = {
    name = "psalm";
    description = "Static Analysis of PHP files.";
    package = tools.psalm;
    entry = migrateBinPathToPackage config "/bin/psalm";
    types = [ "php" ];
  };
}
