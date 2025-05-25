{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    checklevel = mkOption {
      type = types.enum [ "Error" "Warning" "Information" "Hint" ];
      description =
        "The diagnostic check level";
      default = "Warning";
    };
    configuration = mkOption {
      type = types.attrs;
      description =
        "See https://github.com/LuaLS/lua-language-server/wiki/Configuration-File#luarcjson";
      default = { };
    };
  };
}
