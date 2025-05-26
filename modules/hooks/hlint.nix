{ config, lib, tools, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    hintFile =
      mkOption {
        type = types.nullOr (types.oneOf [ types.str types.path ]);
        description = "Path to hlint.yaml. By default, hlint searches for .hlint.yaml in the project root.";
        default = null;
      };
  };
  config = {
    name = "hlint";
    description = "HLint gives suggestions on how to improve your source code.";
    package = tools.hlint;
    entry = "${config.package}/bin/hlint${if config.settings.hintFile == null then "" else " --hint=${config.settings.hintFile}"}";
    files = "\\.l?hs(-boot)?$";
  };
}
