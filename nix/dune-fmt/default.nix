{ writeShellApplication, dune, ocaml }:

writeShellApplication {
  name = "dune-fmt";
  runtimeInputs = [ ocaml ];
  text = "${dune}/bin/dune build @fmt \"$@\"";
}
