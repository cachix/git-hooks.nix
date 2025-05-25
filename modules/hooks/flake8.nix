{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binPath =
      mkOption {
        type = types.nullOr types.str;
        description = "flake8 binary path. Should be used to specify flake8 binary from your Python environment.";
        default = null;
        defaultText = lib.literalExpression ''
          "''${tools.flake8}/bin/flake8"
        '';
      };
    extendIgnore =
      mkOption {
        type = types.listOf types.str;
        description = "List of additional ignore codes";
        default = [ ];
        example = [ "E501" ];
      };
    format =
      mkOption {
        type = types.str;
        description = "Output format.";
        default = "default";
      };
  };
}
