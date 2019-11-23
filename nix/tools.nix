{ ansible-lint, hlint, shellcheck, ormolu, hindent, cabal-fmt, canonix, elmPackages, niv
, gitAndTools, runCommand, writeText, writeScript, git, nixpkgs-fmt, nixfmt, callPackage
}:

{
  inherit ansible-lint hlint shellcheck ormolu hindent cabal-fmt canonix nixpkgs-fmt nixfmt;
  inherit (elmPackages) elm-format;
  terraform-fmt = callPackage ./terraform-fmt {};
}
