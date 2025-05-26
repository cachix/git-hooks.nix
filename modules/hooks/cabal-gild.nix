{ tools, config, lib, pkgs, ... }:
{
  config = {
    package = tools.cabal-gild;
    entry =
      let
        script = pkgs.writeShellScript "precommit-cabal-gild" ''
          for file in "$@"; do
              ${config.package}/bin/cabal-gild --io="$file"
          done
        '';
      in
      builtins.toString script;
    files = "\\.cabal$";
  };
}
