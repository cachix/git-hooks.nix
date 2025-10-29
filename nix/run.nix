builtinStuff@{ lib, pkgs, tools, gitignore-nix-src, isFlakes }:

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
                _module.args = { inherit pkgs gitignore-nix-src; };
                tools = lib.mkDefault (builtinStuff.tools // tools);
                rootSrc =
                  if isFlakes
                  then src
                  else gitignore-nix-src.lib.gitignoreSource src;
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
