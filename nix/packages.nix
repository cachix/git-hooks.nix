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
  run = callPackage ./run.nix { inherit tools; };

  # A pre-commit-check for nix-pre-commit itself
  pre-commit-check = run {
    src = ../.;
    hooks = {
      shellcheck.enable = true;
      canonix.enable = true;
    };
  };
}
