{ lib, config, tools, migrateBinPathToPackage, mkCmdArgs, ... }:
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
          "''${config.package}/bin/pylint"
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

  config = {
    package = tools.pylint;
    entry =
      let
        binPath = migrateBinPathToPackage config "/bin/pylint";
        cmdArgs =
          mkCmdArgs
            (with config.settings; [
              [ reports "-ry" ]
              [ (! score) "-sn" ]
            ]);
      in
      "${binPath} ${cmdArgs}";
    types = [ "python" ];
  };
}
