builtinStuff@{ pkgs, tools, isFlakes, pre-commit, git, runCommand, writeText, writeScript, lib, gitignore-nix-src }:

options@{ src
, imports ? [ ]
, tools ? { }
, ...
}:
let
  moduleOptions = builtins.removeAttrs options [ "imports" "tools" ];

  project =
    lib.evalModules {
      modules =
        [
          ../modules/all-modules.nix
          {
            config = moduleOptions //
            {
              _module.args.pkgs = pkgs;
              _module.args.gitignore-nix-src = gitignore-nix-src;
              package = lib.mkDefault (if builtins.hasAttr "prek" pkgs then pkgs.prek else pkgs.pre-commit);
              tools = lib.mkDefault (builtinStuff.tools // tools);
            } // (if isFlakes
            then { rootSrc = src; }
            else {
              rootSrc = gitignore-nix-src.lib.gitignoreSource src;
            });
          }
        ] ++ imports;
    };
  inherit (project.config) installationScript;

in
project.config.run // {
  inherit (project) config;
  inherit (project.config) enabledPackages;
  shellHook = installationScript;
}
