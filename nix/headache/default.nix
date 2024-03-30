{ stdenv, lib, darwin, headache ? null, ocamlPackages }:

## NOTE: `headache` moved from `ocamlPackages.headache` to top-level on 8 June
## 2023. Once this gets into a NixOS release, the following code will be
## useless.
let
  the-headache =
    (if headache != null then headache else ocamlPackages.headache).overrideAttrs (drv: {
      nativeBuildInputs = (drv.nativeBuildInputs or [ ]) ++ lib.optionals stdenv.isDarwin [
        darwin.sigtool
      ];
    });
in

## NOTE: The following derivation seems rather trivial, but it is used here to
  ## get rid of a runtime dependency in the whole OCaml compiler (~420M).
stdenv.mkDerivation {
  name = "headache-stripped";
  src = the-headache.src;
  phases = [ "installPhase" ];
  installPhase = "install -Dm 555 -t $out/bin ${the-headache}/bin/headache";
}
