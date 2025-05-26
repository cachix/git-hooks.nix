{ lib, config, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binPath =
      mkOption {
        type = types.nullOr types.str;
        description = "Mypy binary path. Should be used to specify the mypy executable in an environment containing your typing stubs.";
        default = null;
        defaultText = lib.literalExpression ''
          "''${config.package}/bin/mypy"
        '';
      };
  };
}
