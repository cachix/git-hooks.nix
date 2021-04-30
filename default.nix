let
  pkgs = import ./nix { };
in
pkgs.packages // pkgs.checks // { inherit (pkgs) run; }
