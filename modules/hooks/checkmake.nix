{ tools, config, lib, ... }:
{
  config = {
    name = "checkmake";
    description = "Experimental linter/analyzer for Makefiles";
    types = [ "makefile" ];
    package = tools.checkmake;
    entry =
      ## NOTE: `checkmake` 0.2.2 landed in nixpkgs on 12 April 2023. Once
      ## this gets into a NixOS release, the following code will be useless.
      lib.throwIf
        (config.package == null)
        "The version of nixpkgs used by git-hooks.nix must have `checkmake` in version at least 0.2.2 for it to work on non-Linux systems."
        "${config.package}/bin/checkmake";
  };
}
