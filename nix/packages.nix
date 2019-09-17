{ hlint, shellcheck, ormolu, hindent, cabal-fmt, canonix, elmPackages, niv
, gitAndTools, runCommand, writeText, writeScript, git, nixpkgs-fmt, nixfmt
, callPackage
}:

let
  tools =
    {
      inherit hlint shellcheck ormolu hindent cabal-fmt canonix nixpkgs-fmt nixfmt;
      inherit (elmPackages) elm-format;
      terraform-fmt = callPackage ./terraform-fmt {};
    };
in
  tools // rec {
  inherit niv;
  inherit (gitAndTools) pre-commit;
  run = import ./run.nix { inherit tools pre-commit runCommand writeText writeScript git; };
  pre-commit-check = run { src = ../.; };
}
