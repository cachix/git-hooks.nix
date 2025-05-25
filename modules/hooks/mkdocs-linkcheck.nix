{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binPath =
      mkOption {
        type = types.nullOr (types.oneOf [ types.str types.path ]);
        description = "mkdocs-linkcheck binary path. Should be used to specify the mkdocs-linkcheck binary from your Python environment.";
        default = null;
        defaultText = lib.literalExpression ''
          "''${tools.mkdocs-linkcheck}/bin/mkdocs-linkcheck"
        '';
      };

    path =
      mkOption {
        type = types.str;
        description = "Path to check";
        default = "";
      };

    local-only =
      mkOption {
        type = types.bool;
        description = "Whether to only check local links.";
        default = false;
      };

    recurse =
      mkOption {
        type = types.bool;
        description = "Whether to recurse directories under path.";
        default = false;
      };

    extension =
      mkOption {
        type = types.str;
        description = "File extension to scan for.";
        default = "";
      };

    method =
      mkOption {
        type = types.enum [ "get" "head" ];
        description = "HTTP method to use when checking external links.";
        default = "get";
      };
  };
}
