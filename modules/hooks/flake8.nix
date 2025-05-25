{ tools, config, lib, migrateBinPathToPackage, ... }:
let
  inherit (lib) mkOption types;

  extendIgnoreStr =
    if lib.lists.length config.settings.extendIgnore > 0
    then "--extend-ignore " + builtins.concatStringsSep "," config.settings.extendIgnore
    else "";
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

  config = {
    name = "flake8";
    description = "Check the style and quality of Python files.";
    package = tools.flake8;
    entry =
      let
        binPath = migrateBinPathToPackage config "/bin/flake8";
      in
      "${binPath} --format ${config.settings.format} ${extendIgnoreStr}";
    types = [ "python" ];
  };
}
