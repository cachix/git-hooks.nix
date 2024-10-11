builtinStuff@{ pkgs, tools, isFlakes, pre-commit, git, runCommand, writeText, writeScript, lib, gitignore-nix-src }:

{ src
, settings ? { }
, hooks ? { }
, excludes ? [ ]
, tools ? { }
, default_stages ? [ "commit" ]
, addGcRoot ? true
, imports ? [ ]
}:
let
  project =
    lib.evalModules {
      modules =
        [
          ../modules/all-modules.nix
          {
            config =
              {
                _module.args.pkgs = pkgs;
                _module.args.gitignore-nix-src = gitignore-nix-src;
                inherit hooks excludes default_stages settings addGcRoot;
                tools = builtinStuff.tools // tools;
                package = pre-commit;
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
