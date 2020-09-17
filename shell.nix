with { pkgs = import ./nix { }; };

pkgs.mkShell {
  buildInputs = [ pkgs.niv ];
  inherit ((import ./.).pre-commit-check) shellHook;
}
