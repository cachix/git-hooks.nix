builtinStuff@{ pkgs, tools, pre-commit, git, runCommand, writeText, writeScript, lib }:

{ src
, hooks ? { }
, excludes ? [ ]
, tools ? { }
, settings ? { }
, default_stages ? [ ]
}:
let
  sources = import ./sources.nix;

  project =
    lib.evalModules {
      modules =
        [
          ../modules/all-modules.nix
          {
            config =
              {
                _module.args.pkgs = pkgs;
                inherit hooks excludes settings src default_stages;
                tools = builtinStuff.tools // tools;
              };
          }
        ];
    };
  inherit (project.config) installationScript;

in
project.config.run // {
  shellHook = installationScript;
}
