{ tools, lib, config, pkgs, ... }:
{
  config = {
    package = tools.topiary;
    entry =
      let
        topiary-inplace = pkgs.writeShellApplication {
          name = "topiary-inplace";
          text = ''
            for file; do
              ${config.package}/bin/topiary --in-place --input-file "$file"
            done
          '';
        };
      in
      "${topiary-inplace}/bin/topiary-inplace";
    files = "(\\.json$)|(\\.toml$)|(\\.mli?$)";
  };
}
