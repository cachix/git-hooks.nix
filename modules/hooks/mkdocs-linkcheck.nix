{ lib, config, tools, migrateBinPathToPackage, mkCmdArgs, ... }:
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
          "''${config.package}/bin/mkdocs-linkcheck"
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

  config = {
    name = "mkdocs-linkcheck";
    description = "Validate links associated with markdown-based, statically generated websites.";
    package = tools.mkdocs-linkcheck;
    entry =
      let
        binPath = migrateBinPathToPackage config "/bin/mkdocs-linkcheck";
        cmdArgs =
          mkCmdArgs
            (with config.settings; [
              [ local-only " --local" ]
              [ recurse " --recurse" ]
              [ (extension != "") " --ext ${extension}" ]
              [ (method != "") " --method ${method}" ]
              [ (path != "") " ${path}" ]
            ]);
      in
      "${binPath}${cmdArgs}";
    types = [ "text" "markdown" ];
  };

}
