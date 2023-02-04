{ writeShellApplication, dune, ocaml }:

writeShellApplication {
  name = "dune-build-opam-files";
  runtimeInputs = [ ocaml ];
  text = ''
    find . -type f -name '*.opam' | while read -r file; do
      ${dune}/bin/dune build "$file"
    done
  '';
}
