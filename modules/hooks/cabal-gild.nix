{ tools, config, lib, pkgs, ... }:
{
  config = {
    name = "cabal-gild";
    description = "Format Cabal files";
    package = tools.cabal-gild;
    entry =
      let
        script = pkgs.writeShellScript "precommit-cabal-gild" ''
          for file in "$@"; do
              ${tools.cabal-gild}/bin/cabal-gild --io="$file"
          done
        '';
      in
      builtins.toString script;
    files = "\\.cabal$";
  };
}