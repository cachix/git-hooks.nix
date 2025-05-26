{ lib, config, tools, migrateBinPathToPackage, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binPath =
      mkOption {
        type = types.nullOr types.str;
        description = "Pyright binary path. Should be used to specify the pyright executable in an environment containing your typing stubs.";
        default = null;
        defaultText = lib.literalExpression ''
          "''${config.package}/bin/pyright"
        '';
      };
  };

  config = {
    name = "pyright";
    description = "Static type checker for Python";
    package = tools.pyright;
    entry = migrateBinPathToPackage config "/bin/pyright";
    files = "\\.py$";
  };
}
