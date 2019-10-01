{ pkgs, tools, pre-commit, git, runCommand, writeText, writeScript, lib }:

{ src
, hooks ? {}
}:

let
  sources = import ./sources.nix;

  project =
    lib.evalModules {
      modules =
        [
          ./project-module.nix
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
                pre-commit.hooks = hooks;
                pre-commit.tools = lib.mkDefault tools;
              };
          }
        ];
    };
  inherit (project.config.pre-commit) installationScript;

in
  project.config.pre-commit.run // {
    shellHook = installationScript;
  }
