{ hlint, shellcheck, ormolu, cabal-fmt, canonix, elmPackages, niv
, gitAndTools, runCommand, writeText, writeScript, git, nixpkgs-fmt, nixfmt
, callPackage
}:

let
  tools =
    {
      inherit hlint shellcheck ormolu cabal-fmt canonix nixpkgs-fmt nixfmt;
      inherit (elmPackages) elm-format;
      terraform-fmt = callPackage ./terraform-fmt {};
      terraform-docs-updater-wrapper =
        callPackage ./terraform-docs-updater/wrapper.nix {
          terraform-docs-updater = callPackage ./terraform-docs-updater {};
        };

    };
in
  tools // rec {
  inherit niv;
  inherit (gitAndTools) pre-commit;
  run = import ./run.nix { inherit tools pre-commit runCommand writeText writeScript git; };
  pre-commit-check = run { src = ../.; };
}
