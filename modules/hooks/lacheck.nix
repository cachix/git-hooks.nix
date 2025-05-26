{ config, lib, pkgs, tools, ... }:
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

  config =
    let
      script = pkgs.writeShellScript "precommit-mdsh" ''
        for file in $(echo "$@"); do
            "${config.package}/bin/lacheck" "$file"
        done
      '';
    in
    {
      name = "lacheck";
      description = "A consistency checker for LaTeX documents.";
      types = [ "file" "tex" ];
      package = tools.lacheck;
      entry = "${script}";
    };
}
