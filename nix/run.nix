builtinStuff@{ lib, pkgs, tools, isFlakes }:

options@
{ src
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
            config = lib.mkMerge [
              moduleOptions
              {
                _module.args = { inherit pkgs; };
                tools = lib.mkDefault (builtinStuff.tools // tools);
                rootSrc =
                  if isFlakes
                  then src
                  else pkgs.nix-gitignore.gitignoreSource [ ] src;
              }
            ];
          }
        ] ++ imports;
    };

in
project.config.run // {
  inherit (project) config;
  inherit (project.config) enabledPackages shellHook;
}
