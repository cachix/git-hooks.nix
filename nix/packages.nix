{ gitAndTools, callPackage, pre-commit-hooks-module }:

let
  tools = callPackage ./tools.nix {};
in
tools // rec {
  inherit (gitAndTools) pre-commit;
  run = callPackage ./run.nix { inherit tools pre-commit-hooks-module; };
}
