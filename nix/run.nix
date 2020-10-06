builtinStuff@{ pkgs, tools, pre-commit, git, runCommand, writeText, writeScript, lib }:

{ src
, hooks ? { }
, excludes ? [ ]
, tools ? { }
, settings ? { }
}:
let
  sources = import ./sources.nix;

  project =
    lib.evalModules {
      modules =
        [
          ../modules/all-modules.nix
          {
            options =
              {
                root =
                  lib.mkOption {
                    description = "Internal option";
                    default = src;
                    internal = true;
                    readOnly = true;
                    type = lib.types.unspecified;
                  };
              };
            config =
              {
                _module.args.pkgs = pkgs;
                pre-commit =
                  {
                    inherit hooks excludes settings;
                    tools = builtinStuff.tools // tools;
                  };
              };
          }
        ];
    };
  inherit (project.config.pre-commit) installationScript;

in
project.config.pre-commit.run // {
  shellHook = installationScript;
}
