{ hlint, shellcheck, ormolu, cabal-fmt, canonix, elmPackages
, gitAndTools, runCommand, writeText, writeScript, git, nixpkgs-fmt
}:

let
  tools =
    {
      inherit hlint shellcheck ormolu cabal-fmt canonix nixpkgs-fmt;
      inherit (elmPackages) elm-format;
    };
in
  tools // rec {
  inherit (gitAndTools) pre-commit;
  run = import ./run.nix { inherit tools pre-commit runCommand writeText writeScript git; };
  pre-commit-check = run { src = ../.; };
}
