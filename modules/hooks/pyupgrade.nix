{ lib, ... }:
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
          "''${tools.pyupgrade}/bin/pyupgrade"
        '';
      };
  };
}
