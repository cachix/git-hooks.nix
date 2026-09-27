# Force a runnable all-files script, including its configuration and packages.
{ nixpkgs
, source ? toString ../..
, nixhooks ? null
, backend ? "pre-commit"
, scenario ? "two"
, target ? "eval"
}:
let
  pkgs = import (/. + nixpkgs) { config = { }; overlays = [ ]; };
  inherit (pkgs) lib;
  sourcePath = /. + source;
  package = pkgs.${if backend == "prek-parallel" then "prek" else backend};
  common = lib.optionalAttrs (scenario == "two") {
    nixfmt = {
      entry = "${pkgs.nixfmt}/bin/nixfmt";
      args = [ "--check" ];
      files = "\\.nix$";
    };
    shellcheck = {
      entry = "${pkgs.shellcheck}/bin/shellcheck";
      args = [ ];
      files = "\\.sh$";
    };
  };
  ours = (import (sourcePath + /nix/run.nix) {
    inherit lib pkgs;
    tools = import (sourcePath + /nix/call-tools.nix) pkgs;
    isFlakes = false;
  }) {
    src = ./fixture;
    inherit package;
    addGcRoot = false;
    hooks = lib.mapAttrs
      (_: hook: hook // {
        enable = true;
        types = [ "file" ];
        require_serial = true;
      } // lib.optionalAttrs (backend == "prek-parallel") {
        priority = 0;
      })
      common;
  };
  theirs = (import (/. + nixhooks) { inherit pkgs; }).mkHooks {
    hooks = common;
  };
  runner =
    if backend == "nixhooks" then theirs.run-hooks
    else
      pkgs.writeShellScriptBin "run-hooks" ''
        exec ${lib.getExe package} run --all-files --config ${ours.config.configFile}
      '';
  staged =
    if backend == "nixhooks" then theirs.pre-commit-hook
    else
      pkgs.writeShellScriptBin "staged-hooks" ''
        exec ${lib.getExe package} run --config ${ours.config.configFile}
      '';
in
assert builtins.elem backend [ "pre-commit" "prek" "prek-parallel" "nixhooks" ];
assert builtins.elem scenario [ "empty" "two" ];
assert backend != "nixhooks" || nixhooks != null;
if target == "eval" then runner.drvPath
else if target == "run" then runner
else if target == "staged" then staged
else if target == "tools" then
  pkgs.buildEnv
  {
    name = "hook-benchmark-tools";
    paths = with pkgs; [ gitMinimal coreutils gnugrep findutils bash shellcheck nixfmt ];
  }
else if target == "versions" then {
  nixpkgs = lib.version;
  pre-commit = pkgs.pre-commit.version;
  prek = pkgs.prek.version;
  nixfmt = pkgs.nixfmt.version;
  shellcheck = pkgs.shellcheck.version;
}
else throw "Unknown benchmark target: ${target}"
