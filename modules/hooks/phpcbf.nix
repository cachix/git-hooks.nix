{ lib, config, ... }:
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
          "''${config.package}/bin/phpcbf"
        '';
      };
  };
}
