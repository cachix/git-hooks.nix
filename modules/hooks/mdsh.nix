{ config, tools, lib, pkgs, ... }:
{
  config = {
    package = tools.mdsh;
    entry =
      let
        script = pkgs.writeShellScript "precommit-mdsh" ''
          for file in $(echo "$@"); do
              ${config.package}/bin/mdsh -i "$file"
          done
        '';
      in
      toString script;
    files = "\.md$";
    pass_filenames = false;
  };
}
