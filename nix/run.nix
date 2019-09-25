{ pkgs, tools, pre-commit, git, runCommand, writeText, writeScript, lib }:

{ src
, hooks ? {}
}:

let
  sources = import ./sources.nix;

  # TODO upstream this and add tests to support this use case
  project-nix-core =
    map ( f: sources."project.nix" + ("/" + f) ) [
      "modules/root.nix"
      "modules/activation.nix"
      "modules/shell.nix"
      "modules/nixpkgs.nix"
    ];

  project =
    lib.evalModules {
      modules =
        project-nix-core ++ [
          {
            root = src;
            nixpkgs.pkgs = pkgs;
            pre-commit.tools = lib.mkDefault tools;
            pre-commit.enable = true;
            pre-commit.hooks = hooks;
          }
          ../modules/pre-commit.nix
          ../modules/hooks.nix
      ];
    };
  inherit (project.config.shell.shell) shellHook activationHook;

in
  project.config.pre-commit.run // {
    shellHook = ''
      activationHook=${lib.escapeShellArg activationHook}
      ${shellHook}
    '';
  }
