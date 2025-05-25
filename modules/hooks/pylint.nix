{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binPath =
      mkOption {
        type = types.nullOr types.str;
        description = "Pylint binary path. Should be used to specify Pylint binary from your Python environment.";
        default = null;
        defaultText = lib.literalExpression ''
          "''${tools.pylint}/bin/pylint"
        '';
      };
    reports =
      mkOption {
        type = types.bool;
        description = "Whether to display a full report.";
        default = false;
      };
    score =
      mkOption {
        type = types.bool;
        description = "Whether to activate the evaluation score.";
        default = true;
      };
  };
}
