{ config, tools, lib, pkgs, ... }:
{
  config = {
    package = tools.convco;
    entry =
      let
        convco = config.package;
        script = pkgs.writeShellScript "precommit-convco" ''
          cat $1 | ${convco}/bin/convco check --from-stdin
        '';
        # need version >= 0.4.0 for the --from-stdin flag
        toolVersionCheck = lib.versionAtLeast convco.version "0.4.0";
      in
      lib.throwIf (convco == null || !toolVersionCheck) "The version of Nixpkgs used by git-hooks.nix does not have the `convco` package (>=0.4.0). Please use a more recent version of Nixpkgs."
        builtins.toString
        script;
    stages = [ "commit-msg" ];
  };
}
