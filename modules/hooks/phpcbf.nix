{ lib, ... }:
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
          "''${tools.phpcbf}/bin/phpcbf"
        '';
      };
  };
}
