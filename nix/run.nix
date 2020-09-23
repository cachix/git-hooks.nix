builtinStuff@{ pkgs, tools, pre-commit, git, runCommand, writeText, writeScript, lib, pre-commit-hooks-module }:

{ src
, hooks ? {}
, excludes ? []
, tools ? {}
, settings ? {}
}:

let
  project =
    lib.evalModules {
      modules =
        [
          pre-commit-hooks-module
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
