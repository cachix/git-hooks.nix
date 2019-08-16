{ hlint, shellcheck, ormolu, cabal-fmt, canonix, elmPackages
, gitAndTools, runCommand, writeText, writeScript, git
}:

let
  tools = {
    inherit hlint shellcheck ormolu cabal-fmt canonix;
    inherit (elmPackages) elm-format;
  };
in tools // rec {
  inherit (gitAndTools) pre-commit;
  run = import ./run.nix { inherit tools pre-commit runCommand writeText writeScript git; };
}
