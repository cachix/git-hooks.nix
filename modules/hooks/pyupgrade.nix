{ lib, config, tools, migrateBinPathToPackage, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binPath =
      mkOption {
        type = types.nullOr types.str;
        description = "pyupgrade binary path. Should be used to specify the pyupgrade binary from your Python environment.";
        default = null;
        defaultText = lib.literalExpression ''
          "''${config.package}/bin/pyupgrade"
        '';
      };
  };

  config = {
    name = "pyupgrade";
    description = "Upgrade syntax for newer versions of Python.";
    package = tools.pyupgrade;
    entry = migrateBinPathToPackage config "/bin/pyupgrade";
    types = [ "python" ];
  };
}
